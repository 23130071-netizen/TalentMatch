import app from './app.js';
import { env } from './config/env.js';
import { prisma } from './config/prisma.js';
const server=app.listen(env.port,()=>console.log(`TalentMatch API: http://localhost:${env.port}`));
async function shutdown(signal){console.log(`\n${signal}: shutting down`);server.close(async()=>{await prisma.$disconnect();process.exit(0)});setTimeout(()=>process.exit(1),5000).unref()}
process.on('SIGINT',()=>shutdown('SIGINT'));process.on('SIGTERM',()=>shutdown('SIGTERM'));
