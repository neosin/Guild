extends Node2D

export (int) var next

func _on_Area2D_body_entered(body):
	print("opa")
	if body.is_in_group("player"):
		GLOBAL.TRANSITION = GLOBAL.MAP
		get_tree().change_scene("res://Overworld/Map"+str(next)+".tscn")