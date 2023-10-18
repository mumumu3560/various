extends Node2D



@onready var disc_Label = $CanvasLayer/Label

@onready var min_on_to_set = $CanvasLayer/min_on_your_mark_to_set
@onready var min_set_to_start = $CanvasLayer/min_set_to_start

@onready var min_on_to_set_label = $CanvasLayer/min_on_your_mark_to_set/min_on_to_set
@onready var min_set_to_start_label = $CanvasLayer/min_set_to_start/min_set_to_start


@onready var max_on_to_set = $CanvasLayer/max_on_your_mark_to_set
@onready var max_set_to_start = $CanvasLayer/max_set_to_start

@onready var max_on_to_set_label = $CanvasLayer/max_on_your_mark_to_set/max_on_to_set
@onready var max_set_to_start_label = $CanvasLayer/max_set_to_start/max_set_to_start


# Called when the node enters the scene tree for the first time.
func _ready():
	
	max_on_to_set.value = Global.max_mark_to_set
	min_on_to_set.value = Global.min_mark_to_set
	
	max_set_to_start.value = Global.max_set_to_start
	min_set_to_start.value = Global.min_set_to_start
	
# Called every frame. 'delta' is the elapsed time since the previous frame.



func _on_min_on_your_mark_to_set_value_changed(value):
	
	
	Global.min_mark_to_set = value
	max_on_to_set.min_value = value
	
	min_on_to_set_label.text = "mark to set(min:10~max" + str(min_on_to_set.max_value) + ")"
	max_on_to_set_label.text = "mark to set (min: "  + str(max_on_to_set.min_value) +  " ~max:20)"
	
	var string_text_1 = "mark to set →" + " \n" + str(Global.min_mark_to_set) + "~" + str(Global.max_mark_to_set) + "の間でrandom" + " \n"
	var string_text_2 = "set to start →" + " \n" + str(Global.min_set_to_start) + "~" + str(Global.max_set_to_start) + "の間でrandom"
	
	disc_Label.text = string_text_1 +  " \n" + string_text_2


func _on_max_on_your_mark_to_set_value_changed(value):
	Global.max_mark_to_set = value
	min_on_to_set.max_value = value
	
	max_on_to_set_label.text = "mark to set (min: "  + str(max_on_to_set.min_value) +  " ~max:20)"
	min_on_to_set_label.text = "mark to set(min:10~max" + str(min_on_to_set.max_value) + ")"
	
	var string_text_1 = "mark to set →" + " \n" +  str(Global.min_mark_to_set) + "~" + str(Global.max_mark_to_set) + "の間でrandom" + " \n"
	var string_text_2 = "set to start →" + " \n" +  str(Global.min_set_to_start) + "~" + str(Global.max_set_to_start) + "の間でrandom"
	
	disc_Label.text = string_text_1 +  " \n" + string_text_2


func _on_min_set_to_start_value_changed(value):
	Global.min_set_to_start = value
	max_set_to_start.min_value = value
	
	min_set_to_start_label.text = "set to start(min: 1.5 ~ max: " + str(max_set_to_start.min_value) + ")"
	max_set_to_start_label.text = "set to set (min : "  + str(min_set_to_start.max_value) +  " ~ max : 2.5)"
	
	var string_text_1 = "mark to set →" + " \n" +  str(Global.min_mark_to_set) + "~" + str(Global.max_mark_to_set) + "の間でrandom" + " \n"
	var string_text_2 = "set to start →" + " \n" +  str(Global.min_set_to_start) + "~" + str(Global.max_set_to_start) + "の間でrandom"
	
	disc_Label.text = string_text_1 +  " \n" + string_text_2
	
func _on_max_set_to_start_value_changed(value):
	Global.max_set_to_start = value
	min_set_to_start.max_value = value
	
	max_set_to_start_label.text = "set to set (min: "  + str(min_set_to_start.max_value) +  " ~max:2.5)"
	min_set_to_start_label.text = "set to start(min:1.5~max" + str(max_set_to_start.min_value) + ")"
	
	var string_text_1 = "mark to set →" + " \n" +  str(Global.min_mark_to_set) + "~" + str(Global.max_mark_to_set) + "の間でrandom" + " \n"
	var string_text_2 = "set to start →" + " \n" +  str(Global.min_set_to_start) + "~" + str(Global.max_set_to_start) + "の間でrandom"
	
	disc_Label.text = string_text_1 + " \n" + string_text_2



func _on_back_pressed():
	get_tree().change_scene_to_file("res://title.tscn")






