import test from 'node:test';
import assert from 'node:assert/strict';
import { scoreFreelancerForJob } from '../src/services/matchingService.js';
import { assertTransition } from '../src/utils/state.js';

const job={experienceLevel:'INTERMEDIATE',budgetType:'HOURLY',hourlyRateMax:500000,skills:[{skill:{id:'react'}},{skill:{id:'node'}}]};
const good={freelancerProfile:{experienceYears:5,rating:4.8,talentCredit:850,availability:'AVAILABLE',hourlyRate:400000,skills:[{skill:{id:'react'}},{skill:{id:'node'}}]}};
const weak={freelancerProfile:{experienceYears:1,rating:3,talentCredit:300,availability:'UNAVAILABLE',hourlyRate:700000,skills:[{skill:{id:'figma'}}]}};

test('matching is deterministic and rewards business fit',()=>{const a=scoreFreelancerForJob(job,good);const b=scoreFreelancerForJob(job,good);const c=scoreFreelancerForJob(job,weak);assert.deepEqual(a,b);assert.ok(a.score>c.score);assert.ok(a.reasons.some(x=>x.includes('2/2')))});
test('valid milestone state transition is accepted',()=>assert.doesNotThrow(()=>assertTransition('milestone','PENDING','IN_PROGRESS')));
test('invalid milestone state transition is rejected',()=>assert.throws(()=>assertTransition('milestone','PENDING','ACCEPTED'),/không hợp lệ/));
test('released payment cannot transition again',()=>assert.throws(()=>assertTransition('payment','RELEASED','RELEASED'),/không hợp lệ/));
