# 気になることなど

## Edge Function？
//Edge Functionについて   
https://zenn.dev/msy/articles/4c48d9d9e06147    
Supabaseやcloudflareを使う上でEdge Functionの理解が必要そうなので調べる      
supabaseのedge functionsはfreeでUp to 500K Edge Function invocationsらしい。(50万/month?)    
cloudflare workersは10万/day→300万/month?


//supabase webhooks    
https://supabase.com/docs/guides/database/webhooks    
データベースが変更された際に動く非同期のtriggerみたいな感じ？ここで外部と通信？cloudflareとかOneSignalとか

