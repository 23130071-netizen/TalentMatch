import { z } from 'zod';
import { prisma } from '../config/prisma.js';
import { ok, AppError, parsePagination, paginationMeta } from '../utils/http.js';
import { scoreFreelancerForJob } from '../services/matchingService.js';

const jobInput=z.object({
  title:z.string().min(5).max(200), description:z.string().min(20), categoryId:z.string().nullable().optional(),
  skillIds:z.array(z.string()).default([]), experienceLevel:z.enum(['ENTRY','INTERMEDIATE','EXPERT']).default('INTERMEDIATE'),
  budgetType:z.enum(['FIXED','HOURLY']).default('FIXED'), budgetMin:z.coerce.number().min(0).nullable().optional(),budgetMax:z.coerce.number().min(0).nullable().optional(),
  hourlyRateMin:z.coerce.number().min(0).nullable().optional(),hourlyRateMax:z.coerce.number().min(0).nullable().optional(),currency:z.string().max(8).default('VND'),
  deadline:z.string().nullable().optional(),deliverables:z.string().nullable().optional(),revisionRequirements:z.string().nullable().optional(),preferredFreelancerLevel:z.string().nullable().optional(),
  location:z.string().nullable().optional(),isRemote:z.boolean().default(true),visibility:z.string().default('PUBLIC'),maxHires:z.coerce.number().int().min(1).max(20).default(1),
  screeningQuestions:z.array(z.object({question:z.string().min(3),required:z.boolean().default(false)})).default([]), publish:z.boolean().default(false)
}).superRefine((v,ctx)=>{if(v.budgetMin!=null&&v.budgetMax!=null&&v.budgetMin>v.budgetMax)ctx.addIssue({code:'custom',message:'Budget Min không được lớn hơn Budget Max.',path:['budgetMin']});if(v.deadline&&new Date(v.deadline)<=new Date())ctx.addIssue({code:'custom',message:'Deadline phải ở tương lai.',path:['deadline']});});

const jobInclude={category:true,skills:{include:{skill:true}},client:{select:{id:true,fullName:true,avatarUrl:true,location:true,clientProfile:true}},screeningQuestions:true,_count:{select:{applications:true}}};

export async function listJobs(req,res,next){
  try{
    const {page,limit,skip}=parsePagination(req.query); const {keyword,category,skill,budgetMin,budgetMax,budgetType,experience,location,remote,sort='newest'}=req.query;
    const and=[];
    if(keyword) and.push({OR:[{title:{contains:String(keyword),mode:'insensitive'}},{description:{contains:String(keyword),mode:'insensitive'}}]});
    if(category) and.push({category:{slug:String(category)}}); if(skill) and.push({skills:{some:{skill:{slug:String(skill)}}}});
    if(budgetType) and.push({budgetType:String(budgetType)}); if(experience) and.push({experienceLevel:String(experience)}); if(location) and.push({location:{contains:String(location),mode:'insensitive'}});
    if(remote==='true') and.push({isRemote:true}); if(budgetMin) and.push({budgetMax:{gte:Number(budgetMin)}}); if(budgetMax) and.push({budgetMin:{lte:Number(budgetMax)}});
    const where={status:'OPEN',visibility:'PUBLIC',...(and.length?{AND:and}:{})};
    const orderBy=sort==='budgetHigh'?{budgetMax:'desc'}:sort==='budgetLow'?{budgetMin:'asc'}:sort==='deadline'?{deadline:'asc'}:{publishedAt:'desc'};
    const [items,total]=await prisma.$transaction([prisma.job.findMany({where,include:jobInclude,orderBy,skip,take:limit}),prisma.job.count({where})]);
    ok(res,{items,meta:paginationMeta(page,limit,total)});
  }catch(e){next(e)}
}

export async function getJob(req,res,next){try{const job=await prisma.job.findUnique({where:{id:req.params.id},include:{...jobInclude,statusHistory:{orderBy:{createdAt:'desc'}},questions:{include:{user:{select:{id:true,fullName:true,avatarUrl:true}},answers:{include:{user:{select:{id:true,fullName:true}}}}},orderBy:{createdAt:'desc'}}}});if(!job)throw new AppError(404,'Không tìm thấy Job.');ok(res,job)}catch(e){next(e)}}

export async function myJobs(req,res,next){try{ok(res,await prisma.job.findMany({where:{clientId:req.user.id},include:jobInclude,orderBy:{createdAt:'desc'}}))}catch(e){next(e)}}

export async function createJob(req,res,next){
  try{const input=jobInput.parse(req.body);const {skillIds,screeningQuestions,publish,...rest}=input;const status=publish?'OPEN':'DRAFT';const job=await prisma.$transaction(async tx=>{const created=await tx.job.create({data:{...rest,clientId:req.user.id,deadline:rest.deadline?new Date(rest.deadline):null,status,publishedAt:publish?new Date():null,skills:{create:skillIds.map(skillId=>({skillId}))},screeningQuestions:{create:screeningQuestions}}});await tx.jobStatusHistory.create({data:{jobId:created.id,toStatus:status,changedById:req.user.id,reason:publish?'Published on creation':'Draft created'}});await tx.clientProfile.updateMany({where:{userId:req.user.id},data:{projectsPosted:{increment:1}}});return created});ok(res,job,'Job đã tạo.',201)}catch(e){next(e)}
}

export async function updateJob(req,res,next){
  try{const input=jobInput.partial().parse(req.body);const current=await prisma.job.findUnique({where:{id:req.params.id}});if(!current)throw new AppError(404,'Không tìm thấy Job.');if(current.clientId!==req.user.id)throw new AppError(403,'Bạn không sở hữu Job này.');if(['FILLED','IN_PROGRESS','COMPLETED','CANCELLED','CLOSED'].includes(current.status))throw new AppError(409,'Job ở trạng thái hiện tại không thể chỉnh sửa.');const {skillIds,screeningQuestions,publish,...rest}=input;await prisma.$transaction(async tx=>{if(skillIds){await tx.jobSkill.deleteMany({where:{jobId:current.id}});if(skillIds.length)await tx.jobSkill.createMany({data:skillIds.map(skillId=>({jobId:current.id,skillId}))});}if(screeningQuestions){await tx.screeningQuestion.deleteMany({where:{jobId:current.id}});if(screeningQuestions.length)await tx.screeningQuestion.createMany({data:screeningQuestions.map(x=>({...x,jobId:current.id}))});}await tx.job.update({where:{id:current.id},data:{...rest,deadline:rest.deadline===undefined?undefined:rest.deadline?new Date(rest.deadline):null}})});ok(res,await prisma.job.findUnique({where:{id:current.id},include:jobInclude}),'Job đã cập nhật.') }catch(e){next(e)}
}

export async function publishJob(req,res,next){try{const job=await prisma.job.findUnique({where:{id:req.params.id}});if(!job)throw new AppError(404,'Không tìm thấy Job.');if(job.clientId!==req.user.id)throw new AppError(403,'Bạn không sở hữu Job này.');if(job.status!=='DRAFT')throw new AppError(409,'Chỉ Job DRAFT mới được publish.');const updated=await prisma.$transaction(async tx=>{const x=await tx.job.update({where:{id:job.id},data:{status:'OPEN',publishedAt:new Date()}});await tx.jobStatusHistory.create({data:{jobId:job.id,fromStatus:'DRAFT',toStatus:'OPEN',changedById:req.user.id,reason:'Client published Job'}});return x});ok(res,updated,'Job đã được đăng.') }catch(e){next(e)}}

export async function closeJob(req,res,next){try{const job=await prisma.job.findUnique({where:{id:req.params.id}});if(!job)throw new AppError(404,'Không tìm thấy Job.');if(job.clientId!==req.user.id)throw new AppError(403,'Bạn không sở hữu Job này.');if(!['OPEN','IN_REVIEW','NEGOTIATING'].includes(job.status))throw new AppError(409,'Không thể đóng Job ở trạng thái hiện tại.');const updated=await prisma.$transaction(async tx=>{const x=await tx.job.update({where:{id:job.id},data:{status:'CLOSED',closedAt:new Date()}});await tx.jobStatusHistory.create({data:{jobId:job.id,fromStatus:job.status,toStatus:'CLOSED',changedById:req.user.id,reason:'Client closed Job'}});return x});ok(res,updated,'Job đã đóng.')}catch(e){next(e)}}

export async function saveJob(req,res,next){try{await prisma.savedJob.upsert({where:{userId_jobId:{userId:req.user.id,jobId:req.params.id}},create:{userId:req.user.id,jobId:req.params.id},update:{}});ok(res,null,'Đã lưu Job.')}catch(e){next(e)}}
export async function unsaveJob(req,res,next){try{await prisma.savedJob.deleteMany({where:{userId:req.user.id,jobId:req.params.id}});ok(res,null,'Đã bỏ lưu Job.')}catch(e){next(e)}}
export async function savedJobs(req,res,next){try{const rows=await prisma.savedJob.findMany({where:{userId:req.user.id},include:{job:{include:jobInclude}},orderBy:{createdAt:'desc'}});ok(res,rows.map(x=>x.job))}catch(e){next(e)}}


export async function recommendedJobs(req,res,next){try{const freelancer=await prisma.user.findUnique({where:{id:req.user.id},include:{freelancerProfile:{include:{skills:{include:{skill:true}}}}}});const jobs=await prisma.job.findMany({where:{status:'OPEN',visibility:'PUBLIC'},include:{...jobInclude,skills:{include:{skill:true}}},take:80});const ranked=jobs.map(job=>({job,match:scoreFreelancerForJob(job,freelancer)})).sort((a,b)=>b.match.score-a.match.score).slice(0,12);ok(res,ranked)}catch(e){next(e)}}

export async function matchedFreelancers(req,res,next){try{const job=await prisma.job.findUnique({where:{id:req.params.id},include:{skills:{include:{skill:true}}}});if(!job)throw new AppError(404,'Không tìm thấy Job.');if(req.user.role==='CLIENT'&&job.clientId!==req.user.id)throw new AppError(403,'Bạn không sở hữu Job này.');const freelancers=await prisma.user.findMany({where:{role:'FREELANCER',status:'ACTIVE'},include:{freelancerProfile:{include:{skills:{include:{skill:true}}}}},take:100});const result=freelancers.map(f=>({...f,match:scoreFreelancerForJob(job,f)})).sort((a,b)=>b.match.score-a.match.score).slice(0,20);ok(res,result)}catch(e){next(e)}}

export async function askQuestion(req,res,next){try{const {question}=z.object({question:z.string().min(3).max(1000)}).parse(req.body);const row=await prisma.jobQuestion.create({data:{jobId:req.params.id,userId:req.user.id,question}});ok(res,row,'Đã gửi câu hỏi.',201)}catch(e){next(e)}}
export async function answerQuestion(req,res,next){try{const {answer}=z.object({answer:z.string().min(2).max(2000)}).parse(req.body);const q=await prisma.jobQuestion.findUnique({where:{id:req.params.questionId},include:{job:true}});if(!q)throw new AppError(404,'Không tìm thấy câu hỏi.');if(req.user.id!==q.job.clientId&&req.user.role!=='ADMIN')throw new AppError(403,'Chỉ chủ Job hoặc Admin có thể trả lời.');const row=await prisma.jobQuestionAnswer.create({data:{questionId:q.id,userId:req.user.id,answer}});ok(res,row,'Đã trả lời.',201)}catch(e){next(e)}}
