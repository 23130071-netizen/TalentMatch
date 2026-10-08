import fs from 'fs';import path from 'path';import multer from 'multer';import { env } from '../config/env.js';
const dir=path.resolve(env.uploadDir);fs.mkdirSync(dir,{recursive:true});
const storage=multer.diskStorage({destination:(_req,_file,cb)=>cb(null,dir),filename:(_req,file,cb)=>{const safe=file.originalname.replace(/[^a-zA-Z0-9._-]/g,'_');cb(null,`${Date.now()}-${Math.random().toString(36).slice(2,8)}-${safe}`)}});
const allowed=new Set(['application/pdf','image/png','image/jpeg','image/webp','text/plain','application/zip','application/vnd.openxmlformats-officedocument.wordprocessingml.document']);
export const upload=multer({storage,limits:{fileSize:env.maxFileMb*1024*1024},fileFilter:(_req,file,cb)=>allowed.has(file.mimetype)?cb(null,true):cb(new Error('Loại file không được hỗ trợ.'))});
