import { AppError } from './http.js';

const transitions = {
  application: {
    APPLIED:['SHORTLISTED','NEGOTIATING','REJECTED','WITHDRAWN'],
    SHORTLISTED:['NEGOTIATING','SELECTED','REJECTED','WITHDRAWN'],
    NEGOTIATING:['SHORTLISTED','SELECTED','REJECTED','WITHDRAWN'],
    SELECTED:[], REJECTED:[], WITHDRAWN:[],
  },
  invitation: { PENDING:['ACCEPTED','DECLINED','EXPIRED','CANCELLED'], ACCEPTED:['COMPLETED','CANCELLED'], DECLINED:[], EXPIRED:[], CANCELLED:[], COMPLETED:[] },
  milestone: {
    PENDING:['IN_PROGRESS','CANCELLED'], IN_PROGRESS:['SUBMITTED','CANCELLED'], SUBMITTED:['IN_REVIEW'], IN_REVIEW:['REVISION_REQUESTED','ACCEPTED'],
    REVISION_REQUESTED:['RESUBMITTED'], RESUBMITTED:['IN_REVIEW'], ACCEPTED:['COMPLETED'], COMPLETED:[], CANCELLED:[],
  },
  deliverable: { SUBMITTED:['IN_REVIEW'], IN_REVIEW:['REVISION_REQUESTED','ACCEPTED'], REVISION_REQUESTED:['RESUBMITTED'], RESUBMITTED:['IN_REVIEW'], ACCEPTED:[] },
  payment: { PENDING:['HELD','FAILED','CANCELLED'], HELD:['RELEASED','REFUNDED'], RELEASED:[], REFUNDED:[], FAILED:[], CANCELLED:[] },
};

export function assertTransition(machine, from, to) {
  const allowed = transitions[machine]?.[from] || [];
  if (!allowed.includes(to)) throw new AppError(409, `Chuyển trạng thái ${from} → ${to} không hợp lệ.`, 'INVALID_STATE_TRANSITION');
}
