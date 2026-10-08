export async function addTalentCredit(tx, userId, projectId, delta, reason) {
  const fp = await tx.freelancerProfile.findUnique({ where:{userId} });
  if (!fp) return null;
  const next = Math.max(0, Math.min(1000, fp.talentCredit + delta));
  await tx.freelancerProfile.update({ where:{userId}, data:{talentCredit:next} });
  return tx.talentCreditTransaction.create({ data:{userId,projectId,changeAmount:delta,reason,balanceAfter:next} });
}
