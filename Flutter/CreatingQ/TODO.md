# versionを書く

## aab 1.0.8+8

### 11/04
create_pageの方法を変える。
まずdirectuploadではカスタムIDではなくuuidのランダム生成とする。
問題と解説の二つ受け取れたらsupabaseにそれらのuuidを保存して完了とする。

予期せぬエラーが起こった場合にカスタムIDが変更されない場合を考えなくてよくなる

supabase側での処理を考える。
image_dataに情報が挿入された際にusernameとnumを処理する→fetchproblemnumは必要ない

### 11/05
テーブルに削除の要請があった場合の処理を考える。SupabaseでDeleteからWebhooksを使いCloudflare Workersに情報を送ろうとしたが、列がDeleteされてから情報を送る？ようなので対応するrequestBodyの情報がnullになってしまう。
→違うテーブルを作りinsertの際にWebhooksを使えばいい。

How to authenticate webhooks?
https://github.com/orgs/supabase/discussions/14115

Supabaseからのリクエストであることを保証したいと考えているのでそのあたりが上記のURLにかかれていそう。
だがわからない

"Note: I see that there's a headers section, but pasting in a static secret value there seems not great - at the very least there should be some docs around it."

このように静的なパスワードを含めることは可能だが動的にしたい。
そもそもサーバー間の通信がどう行われるかや安全性などが全く分からない

サーバーの方では大体できたので次はクライアント側の処理を書く。


大体できたが、Cloudflare Workersの方でのエラーが問題。
WorkersでのLogからoutcomeがcanceledであった。
これで調べてみる。

https://developers.cloudflare.com/workers/runtime-apis/handlers/tail/
によると

canceled: The worker invocation was canceled before it completed. Commonly because the client disconnected before a response could be sent.

Supabase Webhooksのtimeoutを1000ms→5000msに変更することで解決した

# aab 1.09+9

