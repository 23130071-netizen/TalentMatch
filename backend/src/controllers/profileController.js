import { z } from 'zod';
import { prisma } from '../config/prisma.js';
import { ok, AppError } from '../utils/http.js';

const freelancerInclude={
  user:{select:{id:true,fullName:true,avatarUrl:true,bio:true,location:true,timezone:true,createdAt:true}},
  skills:{include:{skill:true}},categories:{include:{category:true}},services:true,cvs:true,portfolios:true
};

export async function getFreelancer(req,res,next){
  try{
    const profile=await prisma.freelancerProfile.findFirst({where:{OR:[{id:req.params.id},{userId:req.params.id}]},include:freelancerInclude});
    if(!profile) throw new AppError(404,'Không tìm thấy Freelancer.');
    const reviews=await prisma.review.findMany({where:{revieweeId:profile.userId},include:{reviewer:{select:{fullName:true,avatarUrl:true}}},orderBy:{createdAt:'desc'},take:10});
    ok(res,{...profile,reviews});
  }catch(e){next(e);}
}

export async function listFreelancers(req,res,next){
  try{
    const {keyword,location,availability,skill,language,sort='rating'}=req.query;
    const where={user:{status:'ACTIVE'},...(availability?{availability}:{}),...(location?{user:{status:'ACTIVE',location:{contains:String(location),mode:'insensitive'}}}:{}),
      ...(keyword?{OR:[{headline:{contains:String(keyword),mode:'insensitive'}},{professionalTitle:{contains:String(keyword),mode:'insensitive'}},{user:{fullName:{contains:String(keyword),mode:'insensitive'},status:'ACTIVE'}}]}:{}),
      ...(skill?{skills:{some:{skill:{slug:String(skill)}}}}:{}),
      ...(language?{languages:{array_contains:[String(language)]}}:{})};
    const orderBy=sort==='rate'?{hourlyRate:'asc'}:sort==='credit'?{talentCredit:'desc'}:sort==='experience'?{experienceYears:'desc'}:{rating:'desc'};
    const data=await prisma.freelancerProfile.findMany({where,include:{user:{select:{id:true,fullName:true,avatarUrl:true,location:true,bio:true}},skills:{include:{skill:true}},categories:{include:{category:true}}},orderBy,take:60});
    ok(res,data);
  }catch(e){next(e);}
}

export async function updateMyProfile(req,res,next){
  try{
    const body=z.object({fullName:z.string().min(2).optional(),avatarUrl:z.string().url().or(z.literal('')).optional(),bio:z.string().max(3000).optional(),location:z.string().max(120).optional(),timezone:z.string().max(80).optional(),phone:z.string().max(30).optional(),headline:z.string().max(160).optional(),professionalTitle:z.string().max(160).optional(),summary:z.string().max(5000).optional(),experienceYears:z.coerce.number().int().min(0).max(60).optional(),education:z.any().optional(),certifications:z.any().optional(),languages:z.any().optional(),hourlyRate:z.coerce.number().min(0).optional(),availability:z.enum(['AVAILABLE','LIMITED','UNAVAILABLE']).optional(),companyName:z.string().max(180).optional(),companyDescription:z.string().max(5000).optional(),industry:z.string().max(120).optional(),website:z.string().url().or(z.literal('')).optional(),companySize:z.string().max(80).optional(),foundedYear:z.coerce.number().int().min(1800).max(2100).optional(),contactInfo:z.string().max(500).optional()}).parse(req.body);
    const userData={}; for(const k of ['fullName','avatarUrl','bio','location','timezone','phone']) if(body[k]!==undefined) userData[k]=body[k]||null;
    const user=Object.keys(userData).length?await prisma.user.update({where:{id:req.user.id},data:userData}):await prisma.user.findUnique({where:{id:req.user.id}});
    if(req.user.role==='FREELANCER'){
      const p={}; for(const k of ['headline','professionalTitle','summary','experienceYears','education','certifications','languages','hourlyRate','availability']) if(body[k]!==undefined) p[k]=body[k];
      if(Object.keys(p).length) p.profileCompletion=Math.min(100,30+Object.keys(p).length*7);
      const profile=await prisma.freelancerProfile.upsert({where:{userId:req.user.id},create:{userId:req.user.id,...p},update:p,include:freelancerInclude});
      return ok(res,{user,profile},'Hồ sơ Freelancer đã cập nhật.');
    }
    const c={}; for(const k of ['companyName','companyDescription','industry','website','companySize','foundedYear','contactInfo']) if(body[k]!==undefined) c[k]=body[k]||null;
    const profile=await prisma.clientProfile.upsert({where:{userId:req.user.id},create:{userId:req.user.id,...c},update:c});
    ok(res,{user,profile},'Hồ sơ Client đã cập nhật.');
  }catch(e){next(e);}
}

export async function setSkills(req,res,next){
  try{
    if(req.user.role!=='FREELANCER') throw new AppError(403,'Chỉ Freelancer có thể cập nhật kỹ năng.');
    const {skillIds}=z.object({skillIds:z.array(z.string()).max(30)}).parse(req.body);
    const fp=await prisma.freelancerProfile.findUnique({where:{userId:req.user.id}});
    await prisma.$transaction(async tx=>{await tx.freelancerSkill.deleteMany({where:{freelancerId:fp.id}});if(skillIds.length)await tx.freelancerSkill.createMany({data:skillIds.map(skillId=>({freelancerId:fp.id,skillId}))});});
    ok(res,null,'Kỹ năng đã cập nhật.');
  }catch(e){next(e);}
}

export async function listCv(req,res,next){try{const fp=await prisma.freelancerProfile.findUnique({where:{userId:req.user.id}});ok(res,await prisma.cv.findMany({where:{freelancerId:fp.id},orderBy:{updatedAt:'desc'}}));}catch(e){next(e)}}
export async function saveCv(req,res,next){try{const fp=await prisma.freelancerProfile.findUnique({where:{userId:req.user.id}});const input=z.object({id:z.string().optional(),title:z.string().min(2),professionalSummary:z.string().optional(),workExperience:z.any().optional(),education:z.any().optional(),skillsText:z.string().optional(),certifications:z.any().optional(),languages:z.any().optional(),referencesText:z.string().optional(),fileUrl:z.string().optional(),isDefault:z.boolean().optional()}).parse(req.body);let cv;if(input.id){cv=await prisma.cv.update({where:{id:input.id,freelancerId:fp.id},data:{...input,id:undefined}})}else cv=await prisma.cv.create({data:{...input,freelancerId:fp.id}});ok(res,cv,'CV đã lưu.',input.id?200:201)}catch(e){next(e)}}
export async function listPortfolio(req,res,next){try{const fp=await prisma.freelancerProfile.findUnique({where:{userId:req.user.id}});ok(res,await prisma.portfolio.findMany({where:{freelancerId:fp.id},orderBy:{createdAt:'desc'}}));}catch(e){next(e)}}
export async function savePortfolio(req,res,next){try{const fp=await prisma.freelancerProfile.findUnique({where:{userId:req.user.id}});const input=z.object({id:z.string().optional(),title:z.string().min(2),description:z.string().min(5),role:z.string().optional(),technologies:z.array(z.string()).default([]),mediaUrls:z.array(z.string()).default([]),externalUrl:z.string().optional(),completedAt:z.string().optional()}).parse(req.body);const data={...input,id:undefined,completedAt:input.completedAt?new Date(input.completedAt):null};const item=input.id?await prisma.portfolio.update({where:{id:input.id,freelancerId:fp.id},data}):await prisma.portfolio.create({data:{...data,freelancerId:fp.id}});ok(res,item,'Portfolio đã lưu.',input.id?200:201)}catch(e){next(e)}}
