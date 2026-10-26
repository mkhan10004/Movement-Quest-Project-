"""Runs actual CREATE statements extracted from Dart against host SQLite.
This does NOT run Flutter, sqflite, SharedPreferences, or the Dart repository.
"""
import re, sqlite3, json
from pathlib import Path
source=(Path(__file__).resolve().parents[1]/'lib/data/quest_repository.dart').read_text()
statements=re.findall(r"await db\.execute\(\s*'''(.*?)'''\s*,?\s*\);",source,re.S)
statements+=re.findall(r"await db\.execute\(\s*'(CREATE INDEX[^'\n]*)'\s*,?\s*\);",source)
statements+=re.findall(r'await db\.execute\(\s*"(CREATE UNIQUE INDEX[^"]*)"\s*,?\s*\);',source)
assert len(statements)==4,statements
c=sqlite3.connect(':memory:');c.execute('PRAGMA foreign_keys=ON')
for sql in statements:c.execute(sql)
results=[]
def check(name,fn):
 try: fn();results.append({'check':name,'passed':True})
 except Exception as e:results.append({'check':name,'passed':False,'error':str(e)})
def rejects(sql,args=()):
 try:c.execute(sql,args)
 except sqlite3.IntegrityError:return
 raise AssertionError('Expected constraint rejection')
p="INSERT INTO workout_plans(name,exercise_key,equipment,target_sets,target_reps,intensity,created_at,updated_at) VALUES (?,?,?,?,?,?,?,?)"
c.execute(p,('Quest','squat','bodyweight',2,10,3,0,0))
l="INSERT INTO training_logs(plan_id,session_token,status,started_at,completed_at,target_sets_snapshot,target_reps_snapshot,exercise_name_snapshot,actual_sets_json) VALUES (?,?,?,?,?,?,?,?,?)"
check('empty name rejected',lambda:rejects(p,(' ','squat','bodyweight',2,10,3,0,0)))
check('set lower bound rejected',lambda:rejects(p,('Q','squat','bodyweight',0,10,3,0,0)))
check('repetition upper bound rejected',lambda:rejects(p,('Q','squat','bodyweight',2,101,3,0,0)))
check('unknown equipment rejected',lambda:rejects(p,('Q','squat','other',2,10,3,0,0)))
check('orphan log rejected',lambda:rejects(l,(999,'orphan','draft',0,None,2,10,'Squat','[]')))
c.execute(l,(1,'a','draft',0,None,2,10,'Squat','[]'))
check('second draft rejected',lambda:rejects(l,(1,'b','draft',0,None,2,10,'Squat','[]')))
check('duplicate session token rejected',lambda:rejects(l,(1,'a','completed',0,1,2,10,'Squat','[10,10]')))
check('invalid status date rejected',lambda:rejects(l,(1,'c','completed',0,None,2,10,'Squat','[10,10]')))
c.execute(l,(1,'done','completed',0,1,2,10,'Squat','[10,10]'))
def cascade():
 c.execute('DELETE FROM workout_plans WHERE id=1')
 assert c.execute('SELECT COUNT(*) FROM training_logs').fetchone()[0]==0
check('cascade removes all children',cascade)
print(json.dumps({'scope':'Host SQLite DDL audit only','sqlite_version':sqlite3.sqlite_version,'results':results},indent=2))
if not all(r['passed'] for r in results):raise SystemExit(1)
