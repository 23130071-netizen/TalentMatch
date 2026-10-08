import { Prisma } from '@prisma/client';

export function notFound(req, res) {
  res.status(404).json({ success:false, message:`Không tìm thấy API ${req.method} ${req.originalUrl}` });
}

export function errorHandler(err, _req, res, _next) {
  if (process.env.NODE_ENV !== 'test') console.error(err);
  if (err?.status) return res.status(err.status).json({ success:false, message:err.message, code:err.code });
  if (err instanceof Prisma.PrismaClientKnownRequestError) {
    if (err.code === 'P2002') return res.status(409).json({ success:false, message:'Dữ liệu đã tồn tại hoặc bị trùng.' });
    if (err.code === 'P2025') return res.status(404).json({ success:false, message:'Không tìm thấy dữ liệu yêu cầu.' });
    return res.status(400).json({ success:false, message:'Không thể xử lý dữ liệu yêu cầu.' });
  }
  if (err?.name === 'ZodError') return res.status(422).json({ success:false, message:'Dữ liệu không hợp lệ.', details:err.issues });
  res.status(500).json({ success:false, message:'Đã xảy ra lỗi máy chủ. Vui lòng thử lại.' });
}
