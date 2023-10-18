extends Node2D


@onready var email_edit = $CanvasLayer/E_mail
@onready var password_edit = $CanvasLayer/Password
@onready var debug_label = $CanvasLayer/debug_label

"""
名前に?を入れないようにする
"""
# Called when the node enters the scene tree for the first time.
func _ready():
	
	#ログインの時にいちいち入力するのが面倒→スマホに情報を保存
	#パスは下のようにやればできた。(必要ならprintで確かめられる)
	
	
	#var save_path = OS.get_user_data_dir() + "/TFtest.cfg"
	
	#debug_label.text = str(save_path)
	print("ret")

	#var config_read = ConfigFile.new()
	
	#var ret = config_read.load(save_path)
	
	#if ret != OK:
	#	return # 読み込み失敗

	
	#var email_save_text = config_read.get_value("user", "E-mail")
	#var password_save_text = config_read.get_value("user", "Password")
	
	#email_edit.text = email_save_text
	#password_edit.text = password_save_text

	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func try_login() -> SupabaseUser:
	
	#すでにログインしてるか？
	if Global.user != null:
		print("already login")
		return null
	
	#result: Authtask
	var result:AuthTask = await Supabase.auth.sign_in(email_edit.text, password_edit.text).completed
	
	
	if result.user != null:
		
		Global.user = result.user

		return result.user
		
	return null


func try_sign_up() -> SupabaseUser:
	
	var result:AuthTask = await Supabase.auth.sign_up(email_edit.text, password_edit.text).completed
	
	print("here is result")
	print(result)
	print("this is result")
	
	print(result.user)
	
	if result.user != null:
		Global.user = result.user
		print("########")
		return result.user
		
		
	
	return null	





func _on_login_button_pressed():
	
	var login_result2 = await try_login()
	
	"""
	print("login_result")
	print("abcdefg")
	print(login_result2)
	print(!login_result2)
	
	print(login_result2.id)
	print(login_result2)
	
	
	Global.user_id = login_result2.id
	"""
	
	"""
	print("Global.user_id=")
	print(Global.user_id)
	"""
	
	if !login_result2:
		print(123)
		login_result2 = await try_sign_up()
		print(login_result2)
		print(email_edit.text)
		print(password_edit.text)
		
		if(login_result2 == null):
			print("sign upに失敗しました")
			return 
			
		Global.user_id = login_result2.id
		print("Global.user_id=")
		print(Global.user_id)
		
		
	if !login_result2:
		print("login failed")
		return
	else:
		Global.user_id = login_result2.id
		get_tree().change_scene_to_file("res://personal.tscn")







var data = {"number": 1, "string": "test" }   

#ここはログインの保持のために作ったもの。
func save(content):
	var save_path = OS.get_user_data_dir() + "/TFtest.cfg"
	var file = FileAccess.open(save_path,FileAccess.WRITE)
	file.store_string(content)
	file = null

func load_game():
	var save_path = OS.get_user_data_dir() + "/TFtest.cfg"
	var file = FileAccess.open(save_path,FileAccess.READ)
	var content = file.get_as_text()
	return content









func _on_login_save_pressed():
	var config_write = ConfigFile.new()
	
	var save_path = OS.get_user_data_dir() + "/TFtest.cfg"
	
	if(email_edit.text == ""):
		print("入力がありません")
		return
		
	config_write.set_value("user", "E-mail", email_edit.text)
	config_write.set_value("user", "Password", password_edit.text)
	# ユーザーディレクトリに保存する
	
	if config_write.save(save_path) != OK:
		config_write.save(save_path)

