extends Node2D

"""

"""
@onready var region_button = $CanvasLayer/ColorRect/region_button
@onready var prefecture_button = $CanvasLayer/ColorRect/prefecture_button
@onready var field_list = $CanvasLayer/ColorRect/field_list
@onready var person_list = $CanvasLayer/ColorRect/person_list
@onready var now_field = $CanvasLayer/ColorRect/now_field

"""
@onready var region_button = $CanvasLayer/ScrollContainer/ColorRect/region_button
@onready var prefecture_button = $CanvasLayer/ScrollContainer/ColorRect/prefecture_button
@onready var field_list = $CanvasLayer/ScrollContainer/ColorRect/field_list
@onready var person_list = $CanvasLayer/ScrollContainer/ColorRect/person_list
"""

var selected_field = "-1"
var prefecture_where
var add_field = "-1"
var delete_item = "-1"
#3つまで競技場を選択できる
var my_field = ["-1", "-1", "-1"]


#テーブルから取得した条件に合ったlist、そのlistを1行にしたもの、さらにそのlistから条件に合ったもののみ抽出したlist
var user_list = []
var user_list_text = []
var selected_list = []

var check_age = ""
var check_spike_name = ""
var check_spike_size = ""


var user_age = ""
var user_spike_size = ""

var now_loading = false


var area_jp = ["北海道", "東北", "関東","中部", "近畿",  "中国", "四国", "九州"]

var area_0 = ["北海道"]
var area_1 = ["青森" , "岩手","宮城" ,"秋田","山形","福島"]
var area_2 = ["東京", "茨城","栃木","群馬","埼玉","千葉","神奈川"]
var area_3 = ["新潟", "富山", "石川", "福井", "山梨", "長野", "岐阜", "静岡", "愛知"]
var area_4 = ["京都", "大阪", "三重", "滋賀", "兵庫", "奈良", "和歌山"]
var area_5 = ["鳥取", "島根", "岡山", "広島", "山口"]
var area_6 = ["徳島", "香川", "愛媛", "高知"]
var area_7 = ["福岡", "佐賀", "長崎", "大分", "熊本", "宮崎", "鹿児島", "沖縄"]

var areas =[
	area_0,
	area_1,
	area_2,
	area_3,
	area_4,
	area_5,
	area_6,
	area_7
] 

var all_items = ["1", "2", "11", "34", "342", "333"]



	

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	
	print(my_field)
		
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#
func load_field():
	
	var result: DatabaseTask = await load_my_stadium().completed
	
	var profile_data = result.data[0]
	
	if(profile_data["field_1"] != "-1"):
		my_field[0] = profile_data["field_1"]
		
	if(profile_data["field_2"] != "-1"):
		my_field[1] = profile_data["field_2"]
		
	if(profile_data["field_3"] != "-1"):
		my_field[2] = profile_data["field_3"]
	
	
#競技場のリストを更新
func update_fields(field_name: String, array_index: int):
	
	var where_field = "field_" + str(array_index)
	
	var query = SupabaseQuery.new().from("profile").update(
		{
			where_field : field_name,
		}
	).eq("user_id", Global.user_id)
	
	var result: DatabaseTask = await Supabase.database.query(query).completed

	
	if(result.error):
		print(result.error)
		return null
		
	return Supabase.database.query(query)
	
	
#prefecture_buttonから選択した都道府県に登録した競技場の名前を取得
func load_stadium() -> DatabaseTask:
	var query = SupabaseQuery.new().from("field_place").select().eq("prefecture", prefecture_where)
	return Supabase.database.query(query)
	
	
#profileテーブルから自分が登録した競技場を取得
func load_my_stadium() -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.user_id)
	return Supabase.database.query(query)
	


func _on_back_pressed():
	get_tree().change_scene_to_file("res://personal.tscn")
	

#これはスマートフォン(android)に関して。右下の戻るボタンを押した時の挙動を制御
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://personal.tscn")




#ここで地域選択
func _on_region_button_item_selected(index):
	
	prefecture_button.clear()
	
	prefecture_where = areas[index][0]
	
	reload_field_list()
	
	for pre in areas[index]:
		prefecture_button.add_item(pre)



#ここでは地域に対応した都道府県を選択
func _on_prefecture_button_item_selected(index):

	prefecture_where = prefecture_button.get_item_text(index)
	
	reload_field_list()



func reload_field_list():
	
	field_list.clear()
	
	var result: DatabaseTask = await load_stadium().completed
	
	#optionButtonは選択されないとアイテムが選択されないので取得した県にある最初の競技場を入れておく
	if(result.data.size() != 0):
		add_field = result.data[0]["name"]
		print(add_field)
	
	#ここでは競技場リストに競技場を追加
	if(result.data.size() != 0):
		
		all_items.clear()
		field_list.clear()
		for pre in result.data:
			all_items.append(pre["name"])
			field_list.add_item(pre["name"])
					
	
#
func load_user_1(field: String) -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("field_1", field)
	return Supabase.database.query(query)
	
func load_user_2(field: String) -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("field_2", field)
	return Supabase.database.query(query)
	
func load_user_3(field: String) -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("field_3", field)
	return Supabase.database.query(query)
	
	
	
#supabaseの"profile"テーブルにあるfield_x(x=1,2,3)コラムにfield_nameがあるかどうかを返す
func load_user(field_column: String, field_name: String) -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq(field_column, field_name)
	return Supabase.database.query(query)
	
	
	
#競技場が複数ある場合の検索窓
func _on_field_search_text_changed(new_text):
	var matching_items = []
	
	for item in all_items:
		
		if new_text == "" or item.findn(new_text) != -1:
			matching_items.append(item)
			
		field_list.clear()
		for i in matching_items:
			field_list.add_item(i)


#選択した競技場を表示しておく
func _on_field_list_item_selected(index):
	selected_field = field_list.get_item_text(index)
	#now_field.text = "選択した競技場:" + selected_field
	

#選んだ競技場を登録しているユーザーのリストを取得しstrの配列を用意するまたそれに基づいてユーザー一覧を更新
#ココが大事
func _on_search_pressed():
	
	if(now_loading):
		print("実行中です")
		return 
		
	now_field.text = "選択した競技場:" + selected_field
	var result1: DatabaseTask = await load_user("field_1", selected_field).completed
	var result2: DatabaseTask = await load_user("field_2", selected_field).completed
	var result3: DatabaseTask = await load_user("field_3", selected_field).completed

	
	user_list = []
	
	if(result1.data):
		for i in range(result1.data.size()):
			if(result1.data[i]["user_id"] != Global.user_id):
				user_list.append(result1.data[i])
			
			
	if(result2.data):
		for i in range(result2.data.size()):
			if(result2.data[i]["user_id"] != Global.user_id):
				user_list.append(result2.data[i])
			
			
	if(result3.data):
		for i in range(result3.data.size()):
			if(result3.data[i]["user_id"] != Global.user_id):
				user_list.append(result3.data[i])
	
	dict_to_array_text(user_list)
	
	person_list_reload(user_list_text)
	
	if(user_list.size() == 0):
		print("利用者がいないようです")
		now_loading = false
		return null
		
	now_loading = false
	
		

#検索リストに載っている情報をリロードする
func person_list_reload(now_list):

		person_list.clear()
		
		for i in now_list:
			person_list.add_item(i)


#supabaseにある"profile"テーブルから受け取った情報をdictの配列にしたものを受け取りそれを1行のstrにしている
func dict_to_array_text(now_dict_list):
	
	user_list_text.clear()
	
	for index in range(now_dict_list.size()):
		var now_text = ""
		
		#[1]: 
		now_text += "["
		now_text += str(index)
		now_text += "]"
		
		now_text += ": "
		
		now_text += "\n"
		
		#name: mu-
		now_text += now_dict_list[index]["person_name"]
		now_text += "__"
		now_text += "\n"
		
		#age: 30
		now_text += str(now_dict_list[index]["age"])
		now_text += "歳"
		now_text += "__"
		now_text += "\n"
		
		#spike_size: 26.5
		now_text += str(now_dict_list[index]["spike_size"])
		now_text += "cm"
		now_text += "__"
		now_text += "\n"
		
		#spike_name: SPblade
		now_text += now_dict_list[index]["spike_name"]
		now_text += "\n"
		
		user_list_text.append(now_text)
		
		print(now_text)
		

#これが呼び出されるのは検索窓が変更されたとき。条件に合ったユーザーのリストのみを表示させる
func meet_list_select(now_list: Array, age_search: String, spike_size_search: String, spike_name_search: String):
	
	
	var matching_items = []

	
	person_list.clear()
	
	
	for index in range(user_list.size()):
		var result_age = false
		var result_spike_size = false
		var result_spike_name = false

		#テーブルにある型がfloatやintなのでstringになおす
		
		var age_to_str = str(user_list[index]["age"])
		var spike_size_to_str = str(user_list[index]["spike_size"])
		var spike_name_to_str = str(user_list[index]["spike_name"])
		
	
		
		if age_search == "" or age_to_str.findn(age_search) != -1:
			result_age = true
			
		if spike_size_search == "" or spike_size_to_str.findn(spike_size_search) != -1:
			result_spike_size = true
		
		if spike_name_search == "" or spike_name_to_str.findn(spike_name_search) != -1:
			result_spike_name = true
		
		if result_age and result_spike_name and result_spike_size:
			matching_items.append(user_list_text[index])
		
		
	for item in matching_items:
		person_list.add_item(item)
		
	

#ここでは選択した競技場を登録しているユーザーのリストのアイテムを選択したときの動作。
#person_listには文字列でユーザーの情報が入っているがそのindexは[]に含まれているのでこれを走査する。
#そのindexがわかればuser_listの同じindexからユーザーのid等がわかる

func _on_person_list_item_selected(index):
	var other_user_index = ""
	var first_index_text = person_list.get_item_text(index)
	var second_index_text = person_list.get_item_text(index)
	
	var first_index = int(first_index_text.findn("["))
	var second_index = int(second_index_text.findn("]"))
	
	print("first_index")
	print(first_index)
	
	print("second_index")
	print(second_index)
	
	var other_user_index_text = ""
	for i in range( first_index+1, second_index+1):
		other_user_index_text += person_list.get_item_text(index)[i]
		
	other_user_index = int(other_user_index_text)
	print(other_user_index)
	
	Global.other_user_id = user_list[other_user_index]["user_id"]
	
	print("other_user_id")
	print(Global.other_user_id)
	
	get_tree().change_scene_to_file("res://profile_others.tscn")
	
	
	
	
	

func _on_age_search_text_changed(new_text):
	check_age = new_text
	meet_list_select(user_list, check_age, check_spike_size, check_spike_name)


func _on_spike_size_search_text_changed(new_text):
	check_spike_size = new_text
	meet_list_select(user_list, check_age, check_spike_size, check_spike_name)


func _on_spike_name_search_text_changed(new_text):
	check_spike_name = new_text
	meet_list_select(user_list, check_age, check_spike_size, check_spike_name)
