extends Node


func _on_Button_pressed():
	BATTLE_INIT.first = true
	get_tree().change_scene("res://Menu/Title Screen.tscn")