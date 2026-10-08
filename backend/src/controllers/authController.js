import bcrypt from 'bcrypt';
import jwt from 'jsonwebtoken';
import { z } from 'zod';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import { ok, AppError } from '../utils/http.js';

const registerSchema = z.object({
  email: z.string().email(),
  password: z.string().min(6).max(100),
  role: z.enum(['CLIENT','FREELANCER']),
  fullName: z.string().trim().min(2).max(100),
  location: z.string().max(120).optional(),
});

const loginSchema = z.object({ email:z.string().email(), password:z.string().min(1) });

const tokenFor = user => jwt.sign({ sub:user.id, role:user.role }, env.jwtSecret, { expiresIn:env.jwtExpiresIn });
const publicUser = user => ({ id:user.id,email:user.email,fullName:user.fullName,role:user.role,avatarUrl:user.avatarUrl,status:user.status });

export async function register(req,res,next){
  try {
    const input = registerSchema.parse(req.body);
    const exists = await prisma.user.findUnique({where:{email:input.email.toLowerCase()}});
    if (exists) throw new AppError(409,'Email này đã được sử dụng.','EMAIL_EXISTS');
    const passwordHash = await bcrypt.hash(input.password,12);
    const user = await prisma.$transaction(async tx => {
      const created = await tx.user.create({data:{email:input.email.toLowerCase(),passwordHash,role:input.role,fullName:input.fullName,location:input.location}});
      if (input.role === 'FREELANCER') await tx.freelancerProfile.create({data:{userId:created.id,profileCompletion:15}});
      else await tx.clientProfile.create({data:{userId:created.id}});
      return created;
    });
    ok(res,{user:publicUser(user),token:tokenFor(user)},'Đăng ký thành công.',201);
  } catch(e){ next(e); }
}

export async function login(req,res,next){
  try {
    const input=loginSchema.parse(req.body);
    const user=await prisma.user.findUnique({where:{email:input.email.toLowerCase()}});
    if(!user || !(await bcrypt.compare(input.password,user.passwordHash))) throw new AppError(401,'Email hoặc mật khẩu không đúng.','INVALID_CREDENTIALS');
    if(user.status!=='ACTIVE') throw new AppError(403,'Tài khoản đang bị khóa hoặc vô hiệu hóa.','ACCOUNT_BLOCKED');
    await prisma.user.update({where:{id:user.id},data:{lastLoginAt:new Date()}});
    ok(res,{user:publicUser(user),token:tokenFor(user)},'Đăng nhập thành công.');
  }catch(e){next(e);}
}

export async function me(req,res,next){
  try {
    const user=await prisma.user.findUnique({where:{id:req.user.id},include:{freelancerProfile:{include:{skills:{include:{skill:true}},categories:{include:{category:true}}}},clientProfile:true}});
    const { passwordHash: _hidden, ...safeUser } = user;
    ok(res,safeUser);
  }catch(e){next(e);}
}

export function logout(_req,res){ ok(res,null,'Đăng xuất thành công. Hãy xóa token ở phía client.'); }
