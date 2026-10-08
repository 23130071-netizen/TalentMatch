import { prisma } from '../config/prisma.js';
export const notify = (tx, {userId,type,title,content,deepLink}) =>
  (tx || prisma).notification.create({ data:{ userId,type,title,content,deepLink } });
