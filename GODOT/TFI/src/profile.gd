extends Node2D


"""
@onready var personal_name = $CanvasLayer/ColorRect/Name
@onready var person_age = $CanvasLayer/ColorRect/Age
@onready var person_event = $CanvasLayer/ColorRect/Event
@onready var person_spike_size = $CanvasLayer/ColorRect/Spike_size
@onready var person_spike_name = $CanvasLayer/ColorRect/spike_name
@onready var field_list = $CanvasLayer/ColorRect/Field_list
@onready var field_button1 = $CanvasLayer/ColorRect/Field_button1
@onready var field_button2 = $CanvasLayer/ColorRect/Field_button2
@onready var field_button3 = $CanvasLayer/ColorRect/Field_button3
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





var field_1 = ""
var field_2 = ""
var field_3 = ""

var can_save = true


# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	
	field_list.text = ""
	
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.user_id)
	
	var result: DatabaseTask = await load_profile().completed
	
	print("koregaresult")
	print(result)
	print(result.error)
	print(result.data)
	print(!result.data)
	
	field_button1.hide()
	field_button2.hide()
	field_button3.hide()
	
	
	
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

		update_field()
	
	
	
	
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_profile() -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.user_id)
	return Supabase.database.query(query)
	

#ここは最初にユーザーがプロフィールを入力、保存したときの動作
func insert_profile(person_name: String, age: int, event: String, spike_size: float, spike_name: String, self_intro: String):
	
	var query = SupabaseQuery.new().from("profile").insert(
		[{
			#"user_id" : Global.user_id,
			"person_name" : person_name,
			"age" : age,
			"spike_size" : spike_size,
			"spike_name" : spike_name,
			"event" : event,
			"self_introduction": self_intro
		}]
	)
	
	
	var result: DatabaseTask = await Supabase.database.query(query).completed
	print(result)
	print(result.data)
	
	if(result.error):
		print(result.error)
		print("ABABABABABAB")
		return null
		
	return Supabase.database.query(query)


#ここはユーザーのプロフィールを更新するときの動作
func update_profile(person_name: String, age: int, event: String, spike_size: float, spike_name: String, self_intro: String):
	
	var query = SupabaseQuery.new().from("profile").update(
		{
			"person_name" : person_name,
			"age" : age,
			"spike_size" : spike_size,
			"spike_name" : spike_name,
			"event" : event,
			"self_introduction": self_intro
		}
	).eq("user_id", Global.user_id)
	
	var result: DatabaseTask = await Supabase.database.query(query).completed
	print(result)
	
	if(result.error):
		print(result.error)
		print("CDCDCDCD")
		return null
		
	return Supabase.database.query(query)
	

func _on_save_pressed():
	#まず最初にインサートを試す(ユーザーが最初になんかやる？)
	var result: DatabaseTask = await insert_profile(personal_name.text, person_age.text.to_int(), person_event.text, person_spike_size.text.to_float(), person_spike_name.text, self_intro.text)
	
	print("saveeeeeeeeeeee")
	print(result)
	
	#もしインサートでエラーが出たらそれはすでに"user_id"のところでデータが存在しているため次はそのuser_idに対応した行をアップデートする
	if(!result):
		var result2 : DatabaseTask = await update_profile(personal_name.text, person_age.text.to_int(), person_event.text, person_spike_size.text.to_float(), person_spike_name.text, self_intro.text)
		print(result2)


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://personal.tscn")
	
	
func load_my_stadium() -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.user_id)
	return Supabase.database.query(query)
	
	
func update_field():
	var result: DatabaseTask = await load_my_stadium().completed
	
	var profile_data = result.data[0]
	
	if(profile_data["field_1"] != "-1"):
		field_button1.show()
		field_list.text += "・"
		field_list.text += profile_data["field_1"]
		
		field_1 = profile_data["field_1"]
		
		
	if(profile_data["field_2"] != "-1"):
		field_button2.show()
		field_list.text += "\n"
		field_list.text += "・"
		field_list.text += profile_data["field_2"]
		
		field_2 = profile_data["field_2"]
		
		
	if(profile_data["field_3"] != "-1"):
		field_button3.show()
		field_list.text += "\n"
		field_list.text += "・"
		field_list.text += profile_data["field_3"]
		
		field_3 = profile_data["field_3"]




func _on_back_pressed():
	get_tree().change_scene_to_file("res://personal.tscn")


func _on_field_add_pressed():
	get_tree().change_scene_to_file("res://field_search.tscn")



func _on_field_button_1_pressed():
	Global.field_place = field_1
	get_tree().change_scene_to_file("res://person_search.tscn")
	
	
func _on_field_button_2_pressed():
	Global.field_place = field_2
	get_tree().change_scene_to_file("res://person_search.tscn")


func _on_field_button_3_pressed():
	Global.field_place = field_3
	get_tree().change_scene_to_file("res://person_search.tscn")


func _on_self_intro_text_changed():
	
	var text_length = self_intro.text.length()
	
	if(text_length > 100):
		can_save = false
	else:
		can_save = true
		


func _on_save_self_intro_pressed():
	
	if(!can_save):
		print("保存できません")
		return
	
	var result: DatabaseTask = await insert_profile(personal_name.text, person_age.text.to_int(), person_event.text, person_spike_size.text.to_float(), person_spike_name.text, self_intro.text)
	
	print("saveeeeeeeeeeee")
	print(result)
	
	#もしインサートでエラーが出たらそれはすでに"user_id"のところでデータが存在しているため次はそのuser_idに対応した行をアップデートする
	if(!result):
		var result2 : DatabaseTask = await update_profile(personal_name.text, person_age.text.to_int(), person_event.text, person_spike_size.text.to_float(), person_spike_name.text, self_intro.text)
		print(result2)
	
