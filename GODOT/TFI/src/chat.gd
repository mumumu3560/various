extends Node2D

"""
@onready var other_user_name = $CanvasLayer/ColorRect/other_user_name
@onready var send_button = $CanvasLayer/ColorRect/send_button
@onready var text_edit = $CanvasLayer/ColorRect/TextEdit
@onready var text_field = $CanvasLayer/ColorRect/text_field
"""


"""

"""
@onready var other_user_name = $CanvasLayer/ScrollContainer/ColorRect/other_user_name
@onready var send_button = $CanvasLayer/ScrollContainer/ColorRect/send_button
@onready var text_edit = $CanvasLayer/ScrollContainer/ColorRect/TextEdit
@onready var text_field = $CanvasLayer/ScrollContainer/ColorRect/text_field

var now_user
var other_user

var channel : RealtimeChannel

# Called when the node enters the scene tree for the first time.
func _ready():

	
	var result: DatabaseTask = await load_other().completed
	
	if(!result.data):
		print("error")
		return 
		
	var profile_data = result.data[0]
	other_user_name.text = profile_data["person_name"]
	
	now_user =Global.which_user + "_text"
	other_user = Global.other_user + "_text"
	
	
	var chat_query = SupabaseQuery.new().from("chat").select().eq("users_other_id_text", Global.chat_id)
	
	var result2: DatabaseTask = await Supabase.database.query(chat_query).completed
	
	
	if result2.error:
		print(result2.error)
		return
		
	""" 
	supabaseのchatテーブルはuser1とuser2でやり取りするもので、その固有のidはuser1_id+user2_idのようになっている。
	(user1_id > user2_id→user1_id+user2_id else→user2_id+useri_id)
	
	"""
	for messages in result2.data:
		
		if(messages[now_user] != ""):
			add_text_from_table(messages, 0)
		
		else:
			add_text_from_table(messages, 1)
			
	
	var client = Supabase.realtime.client()
	var connect_result = client.connect_client()
	
	if connect_result != OK:
		print("realtime client error")
	else:
		# SceneTreeTimer オブジェクトの timeout シグナルを待つ
		#このawaitを入れないとエラーが出る。clientのところでwebsocketのstateが0のままsubscribeしてしまう？
		#process(delta)のところでstateが更新されて1になるからエラーが出ない？
		#それともほかにおかしいところがある？
		
  
		client.connect("error", Callable(self, "_on_realtime_client_error"))
		#ここの書き方は？よくわからん
		#channel = client.channel("public", "chat_messages", "room_id=eq.{room_id}".format({room_id=GlobalState.chat_room_id}))
		channel = client.channel("public", "chat", "users_other_id_text=eq.{room_id}".format({room_id=Global.chat_id}))
		channel.connect("insert", Callable(self, "_on_message"))
		
		#ここがよくわからない
		#deltaが25回ぐらいあった
		var timer = self.get_tree().create_timer(2)
		await timer.timeout
		
		channel.subscribe()
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



func load_other():
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.other_user_id)
	return Supabase.database.query(query)


func _on_realtime_client_error(err):
	print(err)


#supabaseのテーブルにあるテキストをチャットに追加
func add_text_from_table(table_data: Dictionary, state: int):
	

	#自分の場合
	if(state == 0):
		var created_time = str(table_data["created_at"]).substr(0, 10) + "-" + str(table_data["created_at"]).substr(11, 5)
		var your_name = "[left][font_size=10][color=white]<{text}>:{created_time}[/color][/font_size][/left]".format({text=Global.user_name, created_time=created_time})
		text_field.text += your_name
		
		
	#	var when_added = "[left][font_size=10][color=white]{text}[/color][/font_size][/left]".format({  text = created_time   })
	#	text_field.text += when_added
		
		text_field.newline()
		var now_fff = "[left][font_size=20][color=white]{text}[/color][/font_size][/left]".format({text=table_data[now_user]})
		text_field.text += now_fff
		text_field.newline()
		var new_line_add = "                                       "
		var new_line_add2 = "____________________________________________"
		
		#var new_line_add2 = "____________________________________________"
		
		text_field.text += new_line_add
		text_field.text += new_line_add2
	
	else:
		var created_time = str(table_data["created_at"]).substr(0, 10) + "-" + str(table_data["created_at"]).substr(11, 5)
		var other_name = "[left][font_size=10][color=green]<{text}>:{created_time}[/color][/font_size][/left]".format({text=Global.other_name, created_time = created_time})
		text_field.text += other_name
		
		text_field.newline()
		var now_fff = "[left][font_size=20][color=green]{text}[/color][/font_size][/left]".format({text=table_data[other_user]})
		text_field.text += now_fff
		text_field.newline()
		var new_line_add = "                                       "
		var new_line_add2 = "____________________________________________"
		text_field.text += new_line_add
		text_field.text += new_line_add2
		
	
	text_field.scroll_to_line(text_field.get_line_count()-1)
	
	
#chatテーブルにメッセージがインサートされたときに動く
func _on_message(new_record, channel):
	
	if(new_record[now_user] != ""):
		add_text_from_table(new_record,0)
		
	else:
		add_text_from_table(new_record,1)

	
func _on_back_pressed():
	get_tree().change_scene_to_file("res://personal.tscn")


#チャットで入力された文字を送信
func _on_send_button_pressed():
	
	if(text_edit.text == ""):
		print("テキストを入力してください")
		return 
	var now_user =Global.which_user + "_text"
	
	var post_message_query = SupabaseQuery.new().from("chat").insert([
		{
			"users_other_id_text": Global.chat_id,
			now_user: text_edit.text
		}
	])
	
	var result: DatabaseTask = await Supabase.database.query(post_message_query).completed
	
	if result.error:
		print("何がおかしいんだろうか")
		print(result.error)
		return
		
	text_edit.text = ""


func _on_text_edit_gutter_clicked(line, gutter):
	pass # Replace with function body.
