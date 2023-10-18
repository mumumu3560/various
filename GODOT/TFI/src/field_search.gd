extends Node2D


@onready var region_button = $CanvasLayer/region_button
@onready var prefecture_button = $CanvasLayer/prefecture_button
@onready var add_button = $CanvasLayer/add_button
@onready var field_list = $CanvasLayer/field_list
@onready var register_list = $CanvasLayer/register_list
@onready var profile_fields = $CanvasLayer/profile_fields


var prefecture_where
var add_field = "-1"
var delete_item = "-1"
#3つまで競技場を選択できる
var my_field = ["-1", "-1", "-1"]


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



"""
	何回も繰り返すと上のprofile_data[field_1]が本来競技場の名前が入っているはずなのに
	-1	となってしまったこれはsupabaseとのやり取りがあるからのようで更新が早いのが問題？待ち時間などが必要か？awaitで何とかなる？
"""

"""
手順→
"""	
	

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	
	await load_field()
	
	for i in range(3):
		
		if(my_field[i] != "-1"):
			profile_fields.add_item(my_field[i])
			
	update_register_list()
	
	if(Global.field_place != "-1"):
		pass
			
	print(my_field)
		
	
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_field():
	
	var result: DatabaseTask = await load_my_stadium().completed
	
	if(result.data.size() == 0):
		print("競技場を登録していません")
		return
	
	var profile_data = result.data[0]
	
	if(profile_data["field_1"] != "-1"):
		my_field[0] = profile_data["field_1"]
		
	if(profile_data["field_2"] != "-1"):
		my_field[1] = profile_data["field_2"]
		
	if(profile_data["field_3"] != "-1"):
		my_field[2] = profile_data["field_3"]
	
	
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
	
	
	

	
	
func load_my_stadium() -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.user_id)
	return Supabase.database.query(query)
	
	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://personal.tscn")
	

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://personal.tscn")




#ここで地域選択
func _on_region_button_item_selected(index):
	
	prefecture_button.clear()
	field_list.clear()
	
	prefecture_where = areas[index][0]
	
	reload_field_list()
	
	for pre in areas[index]:
		prefecture_button.add_item(pre)



#ここでは地域に対応した都道府県を選択
func _on_prefecture_button_item_selected(index):
	
	
	prefecture_where = prefecture_button.get_item_text(index)
	
	reload_field_list()


func load_stadium() -> DatabaseTask:
	var query = SupabaseQuery.new().from("field_place").select().eq("prefecture", prefecture_where)
	return Supabase.database.query(query)
			
			
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
	
			
#ここでは選択された競技場を自分のお気に入りに登録
func _on_add_button_pressed():
	
	var result = already_exist(add_field)
	
	if(result):
		print("既に登録した競技場です")
		return 
		
	
	if(my_field[0] == "-1" ):
		my_field[0] = add_field
		
	elif(my_field[1] == "-1"):
		my_field[1] = add_field
		
	elif(my_field[2] == "-1"):
		my_field[2] = add_field
	else:
		print("登録数が多すぎます")
		
	print(my_field)
	print(add_button)
	
	update_register_list()


#既に登録しているかString
func already_exist(field_name: String) :
	
	print(my_field)
	print(add_field)
	for i in range(3):
		if(field_name == my_field[i]):
			return true
	
	return false	

	

#ここでdelete_itemと一致したmy_field内の要素を-1に置き換える
func _on_delete_pressed():
	
	if(!(register_list.get_item_count() > 0)):
		print("削除するものがありません")
		return 
		
	var now_delete_item = delete_item
	print(now_delete_item)
	
	for i in range(3):
		if(my_field[i] == now_delete_item):
			my_field[i] = "-1"
			
	update_register_list()
	
	print(my_field)


func update_register_list():
	register_list.clear()
	
	for i in range(3):
		if(my_field[i] != "-1"):
			register_list.add_item(my_field[i])
	
	
#ここで検索窓の条件に合ったものを探す。
func _on_field_search_text_changed(new_text):
	var matching_items = []
	
	field_list.clear()
	
	for item in all_items:
		
		if new_text == "" or item.findn(new_text) != -1:
			matching_items.append(item)
			
		
		for i in matching_items:
			field_list.add_item(i)
			
	


func _on_field_list_item_selected(index):
	add_field = field_list.get_item_text(index)
	

func _on_register_list_item_selected(index):
	delete_item = register_list.get_item_text(index)


func adjust_my_field():
	var adjust_field = []
	
	for i in range(3):
		if(my_field[i] != "-1"):
			adjust_field.append(my_field[i])
			
	for i in range( 3- adjust_field.size() ):
		adjust_field.append("-1")
		
	return adjust_field
	
	
func _on_decide_field_pressed():
	
	profile_fields.clear()
	
	var decide_field = adjust_my_field()
	
	for i in decide_field:
		if(i != "-1"):
			profile_fields.add_item(i)
			
			
	for i in range(3):
		update_fields(decide_field[i],i+1)
			

