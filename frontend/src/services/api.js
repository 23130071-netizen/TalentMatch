const API_URL = import.meta.env.VITE_API_URL || 'http://localhost:3001/api';

export async function api(path, options = {}) {
  const token = localStorage.getItem('tm_token');
  const headers = { ...(options.body instanceof FormData ? {} : { 'Content-Type':'application/json' }), ...(options.headers || {}) };
  if (token) headers.Authorization = `Bearer ${token}`;
  const res = await fetch(`${API_URL}${path}`, { ...options, headers });
  let payload = null;
  try { payload = await res.json(); } catch { payload = { success:false, message:'Phản hồi từ máy chủ không hợp lệ.' }; }
  if (!res.ok || payload?.success === false) {
    const err = new Error(payload?.message || `HTTP ${res.status}`);
    err.status = res.status; err.code = payload?.code; err.details = payload?.details;
    throw err;
  }
  return payload?.data;
}

export const qs = (params) => {
  const s = new URLSearchParams();
  Object.entries(params || {}).forEach(([k,v]) => { if (v !== undefined && v !== null && v !== '') s.set(k,String(v)); });
  const out = s.toString(); return out ? `?${out}` : '';
};
