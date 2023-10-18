extends Node2D


var all_items = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14"]

@onready var item_list = $CanvasLayer/ScrollContainer/ColorRect/ItemList

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_back_pressed():
	get_tree().change_scene_to_file("res://personal.tscn")


func _on_line_edit_text_changed(new_text):
	var matching_items = []
	
	for item in all_items:
		if new_text == "" or item.findn(new_text) != -1:
			matching_items.append(item)
			
		item_list.clear()
		for i in matching_items:
			item_list.add_item(i)
	
"""
var matching_items = []
	for item in all_items:
		if new_text == "" or item.findn(new_text) != -1:
			matching_items.append(item)
	item_list.clear()
	item_list.add_items(matching_items)
"""
