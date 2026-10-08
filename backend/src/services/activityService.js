import { prisma } from '../config/prisma.js';
export const activity = (tx, {projectId,actorId,type,title,detail,metadata}) =>
  (tx || prisma).projectActivity.create({ data:{projectId,actorId,type,title,detail,metadata} });
