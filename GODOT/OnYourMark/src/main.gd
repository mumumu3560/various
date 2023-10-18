extends Node2D

@onready var Snd1 = preload("res://on_your_mark.wav")
@onready var Snd2 = preload("res://set.wav")
@onready var Snd3 = preload("res://Gun.mp3")

@onready var Time_label = $CanvasLayer/Time

#1.5~2.5らしい

func _ready():
	
	var random_time_from_mark_to_set = randf_range(Global.min_mark_to_set, Global.max_mark_to_set)
	
	
	var random_time_from_set_to_start = randf_range(Global.min_set_to_start, Global.max_set_to_start)
	
	#print(Global.timer_from_mark_to_set)
	
	print(Global.min_mark_to_set)
	print(Global.max_mark_to_set)
	print("abc")
	
	print(Global.min_set_to_start)
	print(Global.max_set_to_start)
	print("def")
	
	
	_play_sound(Snd1)
	print(random_time_from_mark_to_set)
	
	await get_tree().create_timer(random_time_from_mark_to_set).timeout
	
	
	_play_sound(Snd2)
	
	
	print(random_time_from_set_to_start)
	await get_tree().create_timer(random_time_from_set_to_start).timeout
	

	_play_sound(Snd3)
	
	Global.isRunning = true



func _play_sound(snd):
	$AudioStreamPlayer.stop()
	
	$AudioStreamPlayer.stream = snd
	
	$AudioStreamPlayer.play()
	


func _on_stop_pressed():
	Global.isRunning = false


func _on_title_pressed():
	get_tree().change_scene_to_file("res://title.tscn")


func _on_reset_pressed():
	Global.isRunning = false
	Time_label.text = "0:00"
