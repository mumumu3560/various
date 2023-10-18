extends Node2D


"""
@onready var personal_name = $CanvasLayer/ColorRect/Name
@onready var person_age = $CanvasLayer/ColorRect/Age
@onready var person_event = $CanvasLayer/ColorRect/Event
@onready var person_spike_size = $CanvasLayer/ColorRect/Spike_size
@onready var person_spike_name = $CanvasLayer/ColorRect/spike_name
@onready var field_list = $CanvasLayer/ColorRect/Field_list
@onready var self_intro = $CanvasLayer/ColorRect/self_intro
"""



"""

"""
@onready var personal_name = $CanvasLayer/ScrollContainer/ColorRect/Name
@onready var person_age = $CanvasLayer/ScrollContainer/ColorRect/Age
@onready var person_event = $CanvasLayer/ScrollContainer/ColorRect/Event
@onready var person_spike_size = $CanvasLayer/ScrollContainer/ColorRect/Spike_size
@onready var person_spike_name = $CanvasLayer/ScrollContainer/ColorRect/spike_name
@onready var field_list = $CanvasLayer/ScrollContainer/ColorRect/Field_list
@onready var field_button1 = $CanvasLayer/ScrollContainer/ColorRect/Field_button1
@onready var field_button2 = $CanvasLayer/ScrollContainer/ColorRect/Field_button2
@onready var field_button3 = $CanvasLayer/ScrollContainer/ColorRect/Field_button3
@onready var self_intro = $CanvasLayer/ScrollContainer/ColorRect/self_intro
@onready var like_button  = $CanvasLayer/ScrollContainer/ColorRect/like_button
@onready var title = $CanvasLayer/ScrollContainer/ColorRect/Title



var field_1 = ""
var field_2 = ""
var field_3 = ""

var already_add = 0

var user_other_id



# Called when the node enters the scene tree for the first time.
#supabaseでは.eqの部分で指定できる条件が一つだけらしいのでユーザーに与えられる固有のuuidをtextにして足したものを考える。
#2人でchatする場合には辞書順で早いStringを前にする。
func _ready():
	
	#これはお気に入りに登録した人 + : + お気に入りに登録した人
	#の順番
	user_other_id = str(Global.user_id) + ":" +str(Global.other_user_id)
	
	print("user_other_id =")
	print(user_other_id)
	
	get_tree().set_quit_on_go_back(false)
	
	field_list.text = ""
	
	var result: DatabaseTask = await load_other_profile().completed
	
	print("koregaresult")
	print(result)
	print(result.error)
	print(result.data)
	print(!result.data)

	
	if(!result.data):
		personal_name.text = ""
		personal_name.text = ""
		person_event.text = ""
		person_spike_size.text = ""
		person_spike_name.text = ""
		self_intro.text = ""
		
	else:
		var profile_data = result.data[0]
		print(profile_data)
		personal_name.text = profile_data["person_name"]
		person_age.text = var_to_str(int(profile_data["age"]))
		person_event.text = profile_data["event"]
		person_spike_size.text = var_to_str(profile_data["spike_size"])
		person_spike_name.text = profile_data["spike_name"]
		self_intro.text = profile_data["self_introduction"]
		title.text = profile_data["person_name"]
		
		Global.other_name = profile_data["person_name"]
		
		update_field()
		check_already_like()

		
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func load_other_profile() -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.other_user_id)
	return Supabase.database.query(query)



func update_field():
	var result: DatabaseTask = await load_other_profile().completed
	
	var profile_data = result.data[0]
	
	if(profile_data["field_1"] != "-1"):

		field_list.text += "・"
		field_list.text += profile_data["field_1"]
		
		field_1 = profile_data["field_1"]
		
		
	if(profile_data["field_2"] != "-1"):

		field_list.text += "\n"
		field_list.text += "・"
		field_list.text += profile_data["field_2"]
		
		field_2 = profile_data["field_2"]
		
		
	if(profile_data["field_3"] != "-1"):

		field_list.text += "\n"
		field_list.text += "・"
		field_list.text += profile_data["field_3"]
		
		field_3 = profile_data["field_3"]
		

# -> DatabaseTask
#これがないとしたのcheck_already_likeでエラーが出る
func load_user_like()-> DatabaseTask:
	print("nowwwww")
	var search_text = str(Global.user_id) + ":"
	
	#ワイルドカードは**らしい
	var query = SupabaseQuery.new().from("like_person").select().ilike("user_other_id", "*{text}*".format({text=search_text}) )
	return Supabase.database.query(query)


func check_already_like():
	var result: DatabaseTask = await load_user_like().completed
	
	print("load_user_likeの結果")
	print(result)
	
	if(result.data.size() == 0):
		print("追加した人がいません")
		already_add = 0
		like_button.text = "追加"
	
	for col in result.data:
		if(col["user_other_id"] == user_other_id):
			print("すでに追加しています")
			already_add = 1
			like_button.text = "追加済み"
	
	
	
func insert_person():
	
	var query = SupabaseQuery.new().from("like_person").insert(
		[{
			"user_other_id": user_other_id
		}]
	)
	
	print("ココが悪いのか")
	var result: DatabaseTask = await Supabase.database.query(query).completed
	
	print("result.error")
	print(result.error)
	if(result.error):
		print(result.error)
		print("ABABABABABAB")
		return null


#ここらへんでreturn Supabase.database.query(query)やってたけどそれがよくなかった
func delete_person():
	
	#Invalid type in function 'eq'
	#in base 'RefCounted (SupabaseQuery)'. Cannot convert argument 2 from Nil to String.
	var query = SupabaseQuery.new().from("like_person").delete().eq("user_other_id", user_other_id )
	print("ココが原因？")
	var result: DatabaseTask = await Supabase.database.query(query).completed
	print("abadgaegaigaeog")
	if(result.error):
		print(result.error)
		print("ABABABABABAB")
		return null
	
	
	
func _on_like_button_pressed():
	
	if(already_add == 0):
		
		
		insert_person()
		like_button.text = "追加済み"
		already_add = 1
		
	else:
		delete_person()
		like_button.text = "追加"
		already_add = 0


func _on_back_pressed():
	get_tree().change_scene_to_file("res://personal.tscn")







func _on_chat_button_pressed():
	
	#文字列比較で辞書順で大きい方を先にする。
	#それをchatのidとする。→一意
	if(str(Global.user_id) > str(Global.other_user_id)):
		Global.chat_id = str(Global.user_id) + ":" +  str(Global.other_user_id)
		Global.which_user = "user1"
		Global.other_user = "user2"
		
	else:
		Global.chat_id = str(Global.other_user_id) + ":" +  str(Global.user_id)
		Global.which_user = "user2"
		
		Global.other_user = "user1"
		
	get_tree().change_scene_to_file("res://chat.tscn")
	
	
