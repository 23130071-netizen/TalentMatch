import { Router } from 'express';
import { authenticate, authorize } from '../middleware/auth.js';
import { getAgreement,myAgreements,confirmAgreement } from '../controllers/agreementController.js';
const r=Router();r.get('/',authenticate,authorize('CLIENT','FREELANCER','ADMIN'),myAgreements);r.get('/:id',authenticate,getAgreement);r.patch('/:id/confirm',authenticate,authorize('CLIENT','FREELANCER'),confirmAgreement);export default r;
