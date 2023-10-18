extends Node2D



# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().set_quit_on_go_back(false)
	
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.user_id)
	
	var result: DatabaseTask = await load_profile().completed
	
	if(!result.data):
		return 
	else:
		var profile_data = result.data[0]
		
		Global.user_name = profile_data["person_name"]
		
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func load_profile() -> DatabaseTask:
	var query = SupabaseQuery.new().from("profile").select().eq("user_id", Global.user_id)
	return Supabase.database.query(query)
	
	
func _on_profile_pressed():
	get_tree().change_scene_to_file("res://profile.tscn")


func _on_like_person_pressed():
	get_tree().change_scene_to_file("res://person_search.tscn")

func _on_field_pressed():
	get_tree().change_scene_to_file("res://field_search.tscn")


func _on_test_pressed():
	get_tree().change_scene_to_file("res://test.tscn")


func _on_contact_pressed():
	get_tree().change_scene_to_file("res://contact.tscn")


func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()


func _on_registered_user_pressed():
	get_tree().change_scene_to_file("res://registered_user.tscn")
