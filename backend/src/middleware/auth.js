import jwt from 'jsonwebtoken';
import { prisma } from '../config/prisma.js';
import { env } from '../config/env.js';
import { AppError } from '../utils/http.js';

export async function authenticate(req, _res, next) {
  try {
    const header = req.headers.authorization || '';
    const token = header.startsWith('Bearer ') ? header.slice(7) : null;
    if (!token) throw new AppError(401, 'Bạn cần đăng nhập để tiếp tục.', 'UNAUTHORIZED');
    let payload;
    try { payload = jwt.verify(token, env.jwtSecret); }
    catch { throw new AppError(401, 'Phiên đăng nhập không hợp lệ hoặc đã hết hạn.', 'INVALID_TOKEN'); }
    const user = await prisma.user.findUnique({ where: { id: payload.sub }, select: { id:true, email:true, fullName:true, role:true, status:true, avatarUrl:true } });
    if (!user || user.status !== 'ACTIVE') throw new AppError(401, 'Tài khoản không khả dụng.', 'ACCOUNT_UNAVAILABLE');
    req.user = user;
    next();
  } catch (e) { next(e); }
}

export const optionalAuth = async (req, _res, next) => {
  const header = req.headers.authorization || '';
  if (!header.startsWith('Bearer ')) return next();
  try {
    const payload = jwt.verify(header.slice(7), env.jwtSecret);
    req.user = await prisma.user.findUnique({ where: { id: payload.sub }, select:{id:true,email:true,fullName:true,role:true,status:true,avatarUrl:true} });
  } catch { req.user = null; }
  next();
};

export const authorize = (...roles) => (req, _res, next) => {
  if (!req.user) return next(new AppError(401, 'Bạn cần đăng nhập.', 'UNAUTHORIZED'));
  if (!roles.includes(req.user.role)) return next(new AppError(403, 'Bạn không có quyền thực hiện thao tác này.', 'FORBIDDEN'));
  next();
};
