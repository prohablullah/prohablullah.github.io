HABLULLAH EL MASRY | HSC 2028 — ADMIN STARTER
=============================================

এই ফোল্ডারে কী আছে
- index.html: হোমপেজ
- login.html / signup.html: Supabase Auth দিয়ে লগইন ও সাইন আপ
- student.html: শিক্ষার্থীর ড্যাশবোর্ড (নোট/পরীক্ষা/নিজের ফলাফলের তালিকা)
- admin.html: অনুমোদিত admin/teacher প্যানেল (নোট, পরীক্ষা, শিক্ষার্থী, ফলাফল, সেটিংস)
- admin.js / auth.js / student.js: কাজের JavaScript
- supabase-config.js: তোমার Project URL ও Publishable key
- supabase_setup.sql: টেবিল, role, trigger ও RLS নীতিমালা

প্রথমে করো
1) https://supabase.com/dashboard খোলো এবং নতুন project তৈরি করো। শক্তিশালী database password রাখো; কাউকে পাঠিও না।
2) Project Dashboard → SQL Editor → New query → supabase_setup.sql-এর সব লেখা paste করে Run করো।
3) Project Dashboard → Connect (বা Settings → API Keys) থেকে Project URL ও Publishable key নাও।
4) supabase-config.js-এ PASTE_YOUR_PROJECT_URL_HERE এবং PASTE_YOUR_PUBLISHABLE_KEY_HERE-এর জায়গায় নিজের মান বসাও।
   Publishable key (সাধারণত sb_publishable_...) browser-এ ব্যবহার করা যায় RLS ঠিক থাকলে।
   কখনো sb_secret_... বা service_role key HTML/JS-এ বসাবে না।
5) Authentication → URL Configuration-এ তোমার website URL Site URL হিসেবে সেট করো।
   Local testing-এর জন্য Supabase Auth URL configuration-এ localhost callback অনুমোদন দরকার হতে পারে।
6) ফাইলগুলো Localhost বা GitHub Pages-এ চালাও। ES module/import ব্যবহারের কারণে file:// থেকে সরাসরি খোলার বদলে localhost/server ব্যবহার করো।
7) signup.html থেকে নিজের account তৈরি করো; email confirmation চালু থাকলে ইমেইল নিশ্চিত করো।
8) Supabase → Authentication → Users থেকে নিজের UUID কপি করো।
9) SQL Editor-এ নিচের লাইনটি নিজের UUID দিয়ে চালাও:
   update public.profiles set role = 'admin' where id = 'YOUR-USER-UUID';
10) admin.html খোলো এবং ওই admin account দিয়ে login করো।

সতর্কতা
- এই starter-এ RLS policies আছে, তবে live করার আগে test করা জরুরি।
- Admin panel থেকে MCQ প্রশ্ন তৈরি/প্রকাশের UI আছে; ছাত্রদের পরীক্ষা দেওয়া, server-side auto-marking, timer, leaderboard, secure exam answer handling, file upload/storage ও teacher-specific permissions পরবর্তী ধাপের কাজ। এখনো সম্পূর্ণ পরীক্ষা-প্রবাহ চালু নয়।
- Supabase SQL-এ RLS অন আছে; তবুও কোনো পলিসি/স্কিমা live করার আগে পরীক্ষা করো।
- Secret key, database password, email password বা login credentials চ্যাটে পাঠাবে না।
- শিক্ষার্থী ব্যবস্থাপনা এখানে প্রোফাইল তালিকা দেখায়; account ban/delete-এর মতো privileged operations এই public static starter-এ নেই।
- GitHub Pages static host; নিরাপদ privileged backend কাজের জন্য Supabase policies/Edge Functions বা trusted server দরকার।
