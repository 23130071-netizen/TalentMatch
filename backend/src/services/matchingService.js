export function scoreFreelancerForJob(job, freelancer) {
  const jobSkills = new Set((job.skills || []).map(x => x.skill?.id || x.skillId));
  const freelancerSkills = new Set((freelancer.freelancerProfile?.skills || []).map(x => x.skill?.id || x.skillId));
  const overlap = [...jobSkills].filter(x => freelancerSkills.has(x)).length;
  const skillScore = jobSkills.size ? (overlap / jobSkills.size) * 45 : 20;
  const fp = freelancer.freelancerProfile || {};
  const expTarget = job.experienceLevel === 'EXPERT' ? 5 : job.experienceLevel === 'INTERMEDIATE' ? 2 : 0;
  const expScore = Math.min(15, ((fp.experienceYears || 0) / Math.max(expTarget,1)) * 15);
  const ratingScore = Math.min(15, (fp.rating || 0) / 5 * 15);
  const creditScore = Math.min(10, (fp.talentCredit || 0) / 1000 * 10);
  const availabilityScore = fp.availability === 'AVAILABLE' ? 10 : fp.availability === 'LIMITED' ? 5 : 0;
  let budgetScore = 5;
  const rate = Number(fp.hourlyRate || 0);
  if (job.budgetType === 'HOURLY' && rate && job.hourlyRateMax) budgetScore = rate <= Number(job.hourlyRateMax) ? 5 : 0;
  const score = Math.round(Math.min(100, skillScore + expScore + ratingScore + creditScore + availabilityScore + budgetScore));
  const reasons = [`${overlap}/${jobSkills.size || 0} kỹ năng phù hợp`, `${fp.experienceYears || 0} năm kinh nghiệm`, `Rating ${(fp.rating || 0).toFixed(1)}`, `TalentCredit ${fp.talentCredit || 0}`];
  if (fp.availability === 'AVAILABLE') reasons.push('Đang sẵn sàng nhận việc');
  return { score, reasons };
}
