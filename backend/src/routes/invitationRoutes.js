import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth.js';
import { createInvitation,myInvitations,respondInvitation,completeInvitation,cancelInvitation,saveFreelancer,unsaveFreelancer,savedFreelancers } from '../controllers/invitationController.js';
const r=Router();
r.get('/',authenticate,authorize('CLIENT','FREELANCER'),myInvitations);r.post('/',authenticate,authorize('CLIENT'),createInvitation);r.patch('/:id/respond',authenticate,authorize('FREELANCER'),respondInvitation);r.post('/:id/complete',authenticate,authorize('FREELANCER'),completeInvitation);r.patch('/:id/cancel',authenticate,authorize('CLIENT'),cancelInvitation);
r.get('/saved/freelancers',authenticate,authorize('CLIENT'),savedFreelancers);r.post('/saved/freelancers/:id',authenticate,authorize('CLIENT'),saveFreelancer);r.delete('/saved/freelancers/:id',authenticate,authorize('CLIENT'),unsaveFreelancer);
export default r;
