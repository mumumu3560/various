extends Node2D


#https://docs.godotengine.org/en/stable/tutorials/ui/bbcode_in_richtextlabel.html
var all_items = ["1","2","3","4","5","6","7","8","9","10","11","12","13","14"]

@onready var item_list = $CanvasLayer/ScrollContainer/ColorRect/ItemList
#@onready var text_field = $CanvasLayer/ScrollContainer/ColorRect/ScrollContainer/ColorRect/RichTextLabel
@onready var text_field = $CanvasLayer/RichTextLabel


# Called when the node enters the scene tree for the first time.
func _ready():
	var aaa = "[right]textaaaaaaaaaaaaaaa[/right]"
	text_field.text += aaa
	
	var bbb = "[left]testbbbbbbbbbb[/left]"
	text_field.text += bbb
	
	var ccc = "[left]testbbbbbbbbbb[/left]"
	text_field.text += ccc
	
	var ddd = "[left][bgcolor=0000ff80]aaaaaaaaaaa[/bgcolor][/left]"
	text_field.text += ddd
	
	var eee = "[left][bgcolor=black][color=white]aaaaaaaaaaa[/color][/bgcolor][/left]"
	text_field.text += eee
	
	var fff = "[right][bgcolor=white][color=black]aaaaaaaaaaa[/color][/bgcolor][/right]"
	text_field.text += fff

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




func _on_test_button_pressed():
	var now_fff = "[left][color=green]<mu-3>[/color][/left]"
	text_field.text += now_fff
	var eee = "[left][color=green]それではスパイクを貸していただけますか？あああああああああああああああああああああ[/color][/left]"
	text_field.text += eee
	text_field.newline()
	var now_ggg = "[right][color=ffffff][mumumumu3][/color][/right]"
	text_field.text += now_ggg
	var fff = "[left][u][color=ffffff]対応お願いしますううううううううううううううううううううううううううううう[/color][/u][/left]"
	text_field.text += fff
	
	var text = "345"
	var nowaaa = "[left][color=green]{text}[/color][/left]".format({text="ges"})
	text_field.text += nowaaa
