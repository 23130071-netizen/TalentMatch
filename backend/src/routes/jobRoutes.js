import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth.js';
import { listJobs,getJob,myJobs,createJob,updateJob,publishJob,closeJob,saveJob,unsaveJob,savedJobs,recommendedJobs,matchedFreelancers,askQuestion,answerQuestion } from '../controllers/jobController.js';
const r=Router();
r.get('/',listJobs);r.get('/recommended',authenticate,authorize('FREELANCER'),recommendedJobs);r.get('/saved',authenticate,authorize('FREELANCER'),savedJobs);r.get('/mine',authenticate,authorize('CLIENT'),myJobs);r.get('/:id',getJob);
r.post('/',authenticate,authorize('CLIENT'),createJob);r.put('/:id',authenticate,authorize('CLIENT'),updateJob);r.patch('/:id/publish',authenticate,authorize('CLIENT'),publishJob);r.patch('/:id/close',authenticate,authorize('CLIENT'),closeJob);
r.post('/:id/save',authenticate,authorize('FREELANCER'),saveJob);r.delete('/:id/save',authenticate,authorize('FREELANCER'),unsaveJob);r.get('/:id/matches',authenticate,authorize('CLIENT','ADMIN'),matchedFreelancers);
r.post('/:id/questions',authenticate,askQuestion);r.post('/questions/:questionId/answers',authenticate,answerQuestion);
export default r;
