# 問題投稿アプリ（現在進行形）

### ・目的、なぜ作ったか  
作問は勉強になりそうだが制作者が少ない(大学レベルの物理とか)  
問題を投稿するハードル？誰でも簡単に問題を投稿できるようにしたい(画像投稿が楽)。  
他人の思考を知りたい←解説だけでなく、どうしてその問題を作ろうと思ったかなども書いてほしい。  


### ・説明  
ユーザーが問題を作り画像としてアップロード、また他人の問題も閲覧できるようにする。  


### ・使ったもの  
flutter(dart)  
Supabase(auth,database)  
cloudflare workers(API tokenなどをクライアントに見せたくないのでサーバーレスの処理で)  
cloudflare images(画像投稿、画像配信)  


### ・現在    
画像投稿と新着順で他の人の投稿を見られる。


### ・改善案、やること  
作問>解答であってほしいので作問に報酬をつけ、解答は面倒にする？   
難しい問題であることが重要ではないので気を付ける。  
他の人に問題を解いてもらったり、反応をもらったりするとうれしいと思うのでそこらへんにもインセンティブをつけたい。
称号とかトロフィーとか？

### 参考にしたもの、使ったもの
・Supabaseのログイン周りなど  
https://zenn.dev/dshukertjr/books/flutter-supabase-chat/viewer/page1  
https://github.com/flutter-osaka-dev/flutter-chat

https://qiita.com/kokogento/items/87aaf0a0fbc192e51504

### 注意
supabaseのapi_urlとanon_keyは.envファイルに格納→dotenvで取得。envファイルはenviedによってdartファイルに変換することで難読化ができる。  
ところどころのurlなどは変更している。




