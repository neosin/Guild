extends Node

var font_size = "24"
var text_speed = 15

var size_opts = ["24", "26", "28", "30", "32"]

var speed_opts = ["Slow", "Medium", "Fast"]
var speed_vals = [10, 15, 20]


func get_size():
	return font_size


func get_speed():
	return text_speed


func get_size_opts():
	return size_opts


func get_speed_opts():
	return speed_opts


func set_speed(ID):
	text_speed = speed_vals[ID]


func set_size(ID):
	font_size = size_opts[ID]
	for tex in get_tree().get_nodes_in_group("text"):
		tex.add_font_override("font", get_font())


func get_font():
	return load("res://Assets/Fonts/Font"+font_size+".tres")