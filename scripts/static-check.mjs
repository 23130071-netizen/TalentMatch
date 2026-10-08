import fs from 'fs';
import path from 'path';
import { spawnSync } from 'child_process';
import { pathToFileURL } from 'url';

const root=path.resolve(path.dirname(new URL(import.meta.url).pathname),'..');
const errors=[];const notes=[];
const read=p=>fs.readFileSync(path.join(root,p),'utf8');
const exists=p=>fs.existsSync(path.join(root,p));
for(const f of ['package.json','backend/package.json','backend/prisma/schema.prisma','backend/prisma/seed.js','frontend/package.json','frontend/src/App.jsx','README.md','TEST_REPORT.md'])if(!exists(f))errors.push(`Missing ${f}`);
const rootPkg=JSON.parse(read('package.json'));const backPkg=JSON.parse(read('backend/package.json'));const frontPkg=JSON.parse(read('frontend/package.json'));
for(const [scope,pkg] of [['root',rootPkg],['backend',backPkg],['frontend',frontPkg]])for(const [group,deps] of Object.entries({dependencies:pkg.dependencies||{},devDependencies:pkg.devDependencies||{}}))for(const [name,ver] of Object.entries(deps))if(/latest|\^|~|\*|alpha|beta|rc/i.test(String(ver)))errors.push(`${scope} ${group} ${name} not exactly pinned: ${ver}`);
if(backPkg.dependencies['@prisma/client']!=='6.19.0'||backPkg.devDependencies.prisma!=='6.19.0')errors.push('Prisma packages must both be 6.19.0');
const schema=read('backend/prisma/schema.prisma');
const modelNames=[...schema.matchAll(/\bmodel\s+(\w+)\s*\{/g)].map(m=>m[1]);const enumNames=[...schema.matchAll(/\benum\s+(\w+)\s*\{/g)].map(m=>m[1]);
const required=['User','FreelancerProfile','ClientProfile','Cv','Portfolio','Category','Skill','Job','Application','Proposal','Quotation','Invitation','Shortlist','Negotiation','Agreement','Project','Milestone','Deliverable','RevisionRequest','ChangeRequest','Payment','Review','TalentCreditTransaction','Notification','Conversation','Message','Dispute','Report','FileAsset','ProjectActivity','AdminAudit'];
for(const m of required)if(!modelNames.includes(m))errors.push(`Missing Prisma model ${m}`);
if(/enum\s+\w+\s*\{[^\n}]+\}/.test(schema))errors.push('Found one-line enum; Prisma enums must be multiline in this project.');
const migration=read('backend/prisma/migrations/202610080001_init/migration.sql');for(const m of modelNames)if(!migration.includes(`CREATE TABLE "${m}"`))errors.push(`Migration missing table ${m}`);for(const e of enumNames)if(!migration.includes(`CREATE TYPE "${e}"`))errors.push(`Migration missing enum ${e}`);

function walk(dir,exts,out=[]){for(const name of fs.readdirSync(dir)){const p=path.join(dir,name);const st=fs.statSync(p);if(st.isDirectory())walk(p,exts,out);else if(exts.some(e=>p.endsWith(e)))out.push(p)}return out}
const jsFiles=walk(path.join(root,'backend'),['.js']);for(const f of jsFiles){const r=spawnSync(process.execPath,['--check',f],{encoding:'utf8'});if(r.status!==0)errors.push(`JS syntax: ${path.relative(root,f)}\n${r.stderr}`)}

let ts=null;try{ts=await import('typescript')}catch{try{ts=await import(pathToFileURL('/opt/nvm/versions/node/v22.16.0/lib/node_modules/typescript/lib/typescript.js').href)}catch{notes.push('TypeScript parser unavailable; JSX parse skipped')}}
if(ts){const api=ts.default||ts;for(const f of walk(path.join(root,'frontend/src'),['.jsx','.js'])){const text=fs.readFileSync(f,'utf8');const sf=api.createSourceFile(f,text,api.ScriptTarget.Latest,true,f.endsWith('.jsx')?api.ScriptKind.JSX:api.ScriptKind.JS);if(sf.parseDiagnostics.length)errors.push(`JSX parse: ${path.relative(root,f)}: ${sf.parseDiagnostics.map(d=>api.flattenDiagnosticMessageText(d.messageText,' ')).join('; ')}`)}}

const sourceFiles=walk(path.join(root,'frontend/src'),['.jsx','.js']);for(const f of sourceFiles){const text=fs.readFileSync(f,'utf8');for(const m of text.matchAll(/from\s+['"](\.[^'"]+)['"]/g)){const base=path.resolve(path.dirname(f),m[1]);const candidates=[base,base+'.js',base+'.jsx',path.join(base,'index.js'),path.join(base,'index.jsx')];if(!candidates.some(fs.existsSync))errors.push(`Broken frontend relative import: ${path.relative(root,f)} -> ${m[1]}`)}}
const backFiles=walk(path.join(root,'backend/src'),['.js']);for(const f of backFiles){const text=fs.readFileSync(f,'utf8');for(const m of text.matchAll(/from\s+['"](\.[^'"]+)['"]/g)){const base=path.resolve(path.dirname(f),m[1]);if(!fs.existsSync(base)&&!fs.existsSync(base+'.js'))errors.push(`Broken backend relative import: ${path.relative(root,f)} -> ${m[1]}`)}}
console.log(`Static audit: ${modelNames.length} Prisma models, ${enumNames.length} enums, ${jsFiles.length} backend JS files, ${sourceFiles.length} frontend source files.`);for(const n of notes)console.log('NOTE:',n);if(errors.length){console.error(`FAIL: ${errors.length} issue(s)`);for(const e of errors)console.error('-',e);process.exit(1)}console.log('PASS: static source audit');
