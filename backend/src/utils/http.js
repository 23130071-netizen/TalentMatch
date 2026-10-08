export const ok = (res, data = null, message = 'OK', status = 200) =>
  res.status(status).json({ success: true, message, data });

export const fail = (res, status, message, details) =>
  res.status(status).json({ success: false, message, ...(details ? { details } : {}) });

export class AppError extends Error {
  constructor(status, message, code = 'APP_ERROR') {
    super(message);
    this.status = status;
    this.code = code;
  }
}

export const assert = (condition, status, message, code) => {
  if (!condition) throw new AppError(status, message, code);
};

export const parsePagination = (query) => {
  const page = Math.max(1, Number(query.page || 1));
  const limit = Math.min(50, Math.max(1, Number(query.limit || 12)));
  return { page, limit, skip: (page - 1) * limit };
};

export const paginationMeta = (page, limit, total) => ({
  page, limit, total, pages: Math.max(1, Math.ceil(total / limit)),
});
