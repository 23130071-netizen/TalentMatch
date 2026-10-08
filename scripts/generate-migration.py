from pathlib import Path
import re
schema=Path('/mnt/data/TalentMatch_Complete/backend/prisma/schema.prisma').read_text()
out=Path('/mnt/data/TalentMatch_Complete/backend/prisma/migrations/202610080001_init/migration.sql')

def blocks(kind):
    pat=re.compile(rf'{kind}\s+(\w+)\s*\{{(.*?)\n\}}',re.S)
    return [(m.group(1),m.group(2)) for m in pat.finditer(schema)]
enums=blocks('enum'); models=blocks('model')
enum_names={n for n,_ in enums}; model_names={n for n,_ in models}
sql=['-- TalentMatch initial migration generated from schema.prisma\n-- Prisma target: 6.19.0\n']
for name,body in enums:
    vals=[ln.strip() for ln in body.splitlines() if ln.strip() and not ln.strip().startswith('//')]
    sql.append(f'CREATE TYPE "{name}" AS ENUM ('+', '.join("'%s'"%v for v in vals)+');\n')

foreign=[]; indexes=[]
for name,body in models:
    lines=[ln.strip() for ln in body.splitlines() if ln.strip() and not ln.strip().startswith('//')]
    fields=[]; directives=[]; relations=[]
    for ln in lines:
        if ln.startswith('@@'): directives.append(ln); continue
        m=re.match(r'^(\w+)\s+([A-Za-z_]\w*(?:\[\])?\??)(?:\s+(.*))?$',ln)
        if not m: continue
        fname,typ,attrs=m.group(1),m.group(2),m.group(3) or ''
        base=typ.replace('[]','').rstrip('?')
        if base in model_names:
            if '@relation' in attrs and 'fields:' in attrs:
                fm=re.search(r'fields:\s*\[([^\]]+)\]',attrs); rm=re.search(r'references:\s*\[([^\]]+)\]',attrs); dm=re.search(r'onDelete:\s*(\w+)',attrs)
                if fm and rm:
                    flds=[x.strip() for x in fm.group(1).split(',')]; refs=[x.strip() for x in rm.group(1).split(',')]
                    relations.append((base,flds,refs,dm.group(1) if dm else 'Restrict'))
            continue
        optional=typ.endswith('?'); arr='[]' in typ
        sqltype='TEXT'
        if base=='String': sqltype='TEXT[]' if arr else 'TEXT'
        elif base=='Int': sqltype='INTEGER'
        elif base=='Float': sqltype='DOUBLE PRECISION'
        elif base=='Boolean': sqltype='BOOLEAN'
        elif base=='DateTime': sqltype='TIMESTAMP(3)'
        elif base=='Json': sqltype='JSONB'
        elif base=='Decimal':
            dm=re.search(r'@db\.Decimal\((\d+)\s*,\s*(\d+)\)',attrs);sqltype=f'DECIMAL({dm.group(1)},{dm.group(2)})' if dm else 'DECIMAL(65,30)'
        elif base in enum_names: sqltype=f'"{base}"'
        col=f'  "{fname}" {sqltype}'
        if not optional: col+=' NOT NULL'
        if '@default(now())' in attrs: col+=' DEFAULT CURRENT_TIMESTAMP'
        elif '@default(true)' in attrs: col+=' DEFAULT true'
        elif '@default(false)' in attrs: col+=' DEFAULT false'
        else:
            dm=re.search(r'@default\(([^()]*)\)',attrs)
            if dm:
                d=dm.group(1).strip()
                if d not in ('cuid','uuid') and not d.startswith('cuid') and not d.startswith('uuid'):
                    if d.startswith('"') and d.endswith('"'): col+=f" DEFAULT '{d[1:-1].replace(chr(39), chr(39)*2)}'"
                    elif re.match(r'^-?\d+(?:\.\d+)?$',d): col+=f' DEFAULT {d}'
                    elif d in enum_names: pass
                    elif base in enum_names: col+=f" DEFAULT '{d}'"
        fields.append((fname,col,'@id' in attrs,'@unique' in attrs))
    pk=[f for f,_,isid,_ in fields if isid]
    uniques=[f for f,_,_,u in fields if u]
    compound_pk=[]; compound_unique=[]; model_indexes=[]
    for d in directives:
        if d.startswith('@@id'):
            mm=re.search(r'\[([^\]]+)\]',d); compound_pk=[x.strip() for x in mm.group(1).split(',')] if mm else []
        elif d.startswith('@@unique'):
            mm=re.search(r'\[([^\]]+)\]',d); compound_unique.append([x.strip() for x in mm.group(1).split(',')] if mm else [])
        elif d.startswith('@@index'):
            mm=re.search(r'\[([^\]]+)\]',d); model_indexes.append([x.strip() for x in mm.group(1).split(',')] if mm else [])
    defs=[col for _,col,_,_ in fields]
    if pk: defs.append('  CONSTRAINT "%s_pkey" PRIMARY KEY (%s)'%(name,', '.join(f'"{x}"' for x in pk)))
    elif compound_pk: defs.append('  CONSTRAINT "%s_pkey" PRIMARY KEY (%s)'%(name,', '.join(f'"{x}"' for x in compound_pk)))
    sql.append(f'CREATE TABLE "{name}" (\n'+',\n'.join(defs)+'\n);\n')
    for f in uniques: indexes.append(f'CREATE UNIQUE INDEX "{name}_{f}_key" ON "{name}"("{f}");')
    for cols in compound_unique:
        if cols: indexes.append(f'CREATE UNIQUE INDEX "{name}_{"_".join(cols)}_key" ON "{name}"(' + ', '.join(f'"{x}"' for x in cols) + ');')
    for cols in model_indexes:
        if cols: indexes.append(f'CREATE INDEX "{name}_{"_".join(cols)}_idx" ON "{name}"(' + ', '.join(f'"{x}"' for x in cols) + ');')
    for target,flds,refs,ondelete in relations:
        delete={'Cascade':'CASCADE','Restrict':'RESTRICT','SetNull':'SET NULL','NoAction':'NO ACTION'}.get(ondelete,'RESTRICT')
        foreign.append(f'ALTER TABLE "{name}" ADD CONSTRAINT "{name}_{"_".join(flds)}_fkey" FOREIGN KEY (' + ', '.join(f'"{x}"' for x in flds) + f') REFERENCES "{target}"(' + ', '.join(f'"{x}"' for x in refs) + f') ON DELETE {delete} ON UPDATE CASCADE;')
sql.append('\n-- Indexes\n'+'\n'.join(indexes)+'\n')
sql.append('\n-- Foreign keys\n'+'\n'.join(foreign)+'\n')
out.write_text('\n'.join(sql))
print(f'models={len(models)} enums={len(enums)} indexes={len(indexes)} foreign_keys={len(foreign)} lines={len(out.read_text().splitlines())}')
