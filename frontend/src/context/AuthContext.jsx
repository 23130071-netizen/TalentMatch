import React, { createContext, useContext, useEffect, useMemo, useState } from 'react';
import { api } from '../services/api.js';

const AuthContext = createContext(null);
export function AuthProvider({children}) {
  const [user,setUser]=useState(null); const [loading,setLoading]=useState(true);
  useEffect(()=>{const token=localStorage.getItem('tm_token');if(!token){setLoading(false);return;}api('/auth/me').then(setUser).catch(()=>{localStorage.removeItem('tm_token');setUser(null)}).finally(()=>setLoading(false));},[]);
  const value=useMemo(()=>({user,loading,async login(email,password){const data=await api('/auth/login',{method:'POST',body:JSON.stringify({email,password})});localStorage.setItem('tm_token',data.token);setUser(data.user);return data.user;},async register(payload){const data=await api('/auth/register',{method:'POST',body:JSON.stringify(payload)});localStorage.setItem('tm_token',data.token);setUser(data.user);return data.user;},logout(){localStorage.removeItem('tm_token');setUser(null)},async refresh(){const me=await api('/auth/me');setUser(me);return me;}}),[user,loading]);
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
export const useAuth=()=>useContext(AuthContext);
