# versionを書く

## aab 1.0.8+8

create_pageの方法を変える。
まずdirectuploadではカスタムIDではなくuuidのランダム生成とする。
問題と解説の二つ受け取れたらsupabaseにそれらのuuidを保存して完了とする。

予期せぬエラーが起こった場合にカスタムIDが変更されない場合を考えなくてよくなる
