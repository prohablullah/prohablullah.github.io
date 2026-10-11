import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './supabase-config.js';
const db=createClient(SUPABASE_URL,SUPABASE_ANON_KEY);
const {data:{session}}=await db.auth.getSession();if(!session){location.href='login.html';}
document.getElementById('welcome').textContent='স্বাগতম, '+(session.user.user_metadata?.full_name||session.user.email);
document.getElementById('logout').onclick=async()=>{await db.auth.signOut();location.href='index.html';};
async function list(table,el,render){const box=document.getElementById(el);const {data,error}=await db.from(table).select('*').order('created_at',{ascending:false});if(error){box.textContent='এখন ডেটা লোড করা যাচ্ছে না। Supabase SQL ও RLS সেটআপ সম্পন্ন হয়েছে কি না দেখো।';return;}if(!data.length){box.textContent='এখনো কিছু প্রকাশ করা হয়নি।';return;}box.className='';box.innerHTML=data.map(render).join('');}
await list('notes','notes',n=>`<div class="resource-row"><div><b>${esc(n.title)}</b><div class="subtle">${esc(n.subject||'')} ${n.chapter?'• '+esc(n.chapter):''}</div></div><a class="btn" target="_blank" rel="noopener" href="${safeUrl(n.resource_url)}">খুলুন ↗</a></div>`);
await list('exams','exams',x=>`<div class="resource-row"><div><b>${esc(x.title)}</b><div class="subtle">${esc(x.subject||'')} • পূর্ণমান ${Number(x.total_marks)||0}</div></div><span class="pill">প্রকাশিত</span></div>`);
await list('results','results',r=>r.user_id===session.user.id?`<div class="resource-row"><div><b>${esc(r.exam_title||'পরীক্ষা')}</b><div class="subtle">ফলাফল</div></div><span class="pill">${Number(r.score)} / ${Number(r.total_marks)}</span></div>`:'');
function esc(s){return String(s??'').replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
function safeUrl(s){try{const u=new URL(s);return ['https:','http:'].includes(u.protocol)?u.href:'#';}catch{return '#';}}
