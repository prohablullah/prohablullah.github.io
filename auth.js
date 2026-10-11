import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm';
import { SUPABASE_URL, SUPABASE_ANON_KEY } from './supabase-config.js';
const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
const status = document.getElementById('status');
function show(message, kind='error'){ status.textContent=message; status.className='status '+kind; }
const loginForm=document.getElementById('loginForm');
if(loginForm) loginForm.addEventListener('submit', async e=>{e.preventDefault();show('লগইন হচ্ছে…','ok');const email=document.getElementById('email').value.trim();const password=document.getElementById('password').value;const {error}=await supabase.auth.signInWithPassword({email,password});if(error){show('লগইন হয়নি: '+error.message);return;}location.href='student.html';});
const signupForm=document.getElementById('signupForm');
if(signupForm) signupForm.addEventListener('submit',async e=>{e.preventDefault();show('অ্যাকাউন্ট তৈরি হচ্ছে…','ok');const name=document.getElementById('name').value.trim();const email=document.getElementById('email').value.trim();const password=document.getElementById('password').value;const {data,error}=await supabase.auth.signUp({email,password,options:{data:{full_name:name}}});if(error){show('সাইন আপ হয়নি: '+error.message);return;}if(data.session){location.href='student.html';}else{show('অ্যাকাউন্ট তৈরি হয়েছে। ইমেইলে নিশ্চিতকরণ লিংক এলে সেটি খুলে তারপর লগইন করো।','ok');}});
