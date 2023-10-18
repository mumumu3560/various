extends Node2D

@onready var person_name
@onready var person_age
@onready var person_spike_size 
@onready var person_spike_name
@onready var person_E_mail

@onready var user_id
@onready var user_E_mail

@onready var user_name
@onready var other_name


@onready var other_user_id

@onready var chat_id
@onready var which_user
@onready var other_user

@onready var test

@onready var field_place = "-1"

"1,2,3,4,5,6,7,8"
var area_jp = ["北海道", "東北", "関東","中部", "近畿",  "中国", "四国", "九州"]

var area_1 = ["北海道"]
var area_2 = ["青森県" , "岩手県","宮城県" ,"秋田県","山形県","福島県"]
var area_3 = ["東京都", "茨城県","栃木県","群馬県","埼玉県","千葉県","神奈川県"]
var area_4 = ["新潟県", "富山県", "石川県", "福井県", "山梨県", "長野県", "岐阜県", "静岡県", "愛知県"]
var area_5 = ["京都府", "大阪府", "三重県", "滋賀県", "兵庫県", "奈良県", "和歌山県"]
var area_6 = ["鳥取県", "島根県", "岡山県", "広島県", "山口県"]
var area_7 = ["徳島県", "香川県", "愛媛県", "高知県"]
var area_8 = ["福岡県", "佐賀県", "長崎県", "大分県", "熊本県", "宮崎県", "鹿児島県", "沖縄県"]


"""
北海道地方	　北海道      1
東北地方	　青森県、岩手県、宮城県、秋田県、山形県、福島県　【6県】 2~7
関東地方	　東京都、茨城県、栃木県、群馬県、埼玉県、千葉県、神奈川県　【1都6県】 8~14
中部地方	　新潟県、富山県、石川県、福井県、山梨県、長野県、岐阜県、静岡県、愛知県　【9県】15 ~ 23
近畿地方	　京都府、大阪府、三重県、滋賀県、兵庫県、奈良県、和歌山県　【2府5県】 24~30
中国地方	　鳥取県、島根県、岡山県、広島県、山口県　【5県】31~35
四国地方	　徳島県、香川県、愛媛県、高知県　【4県】36~39
九州地方	 　福岡県、佐賀県、長崎県、大分県、熊本県、宮崎県、鹿児島県、沖縄県　【8県】 40~47
"""

var user : SupabaseUser

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#ここからメモ

"""
プロフィール→
ログイン時
result
→USER_ID→authのところ
→EMAIL
→ROLE
が与えられる
"""


"""
詰まったところ。
このアプリをPC上で実行した際には問題なくログインができたが、これをそのままandroidにエクスポートするとログインができなかった。
これをChatGPTに聞いた

<uses-permission android:name="android.permission.INTERNET" />

この通りにandroid buildからmanifestを変更したところandroidでもログインが可能になった。

"""



"""

supabaseのRLS(row level security)がよくわかっていない。authentificatedのはずなのにエラーが出る。
今はRLSを有効にしていないがそこら辺の改善が必要

"""
