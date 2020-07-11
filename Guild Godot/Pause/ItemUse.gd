extends Control

onready var location = "OUTSIDE"
var recoverHP = 0
var recoverMP = 0
var hp_char = GLOBAL.PLAYERS[0].stats[0]
var hpmax_char = GLOBAL.PLAYERS[0].stats[1]
var mp_char = GLOBAL.PLAYERS[0].stats[2]
var mpmax_char = GLOBAL.PLAYERS[0].stats[3]

func enter(itemx):
	location = "TARGETS"
	get_node("Panel/All/Left/Chars/Char0").grab_focus()
	for i in range(len(GLOBAL.PLAYERS)):
		var node = get_node("Panel/All/Left/Chars/Char"+str(i))
		node.update_info(GLOBAL.PLAYERS[i])

	for i in range(len(GLOBAL.INVENTORY)):
		if itemx == GLOBAL.INVENTORY[i].nome:
			actual_item(GLOBAL.INVENTORY[i])

func give_focus():
	$Panel/All/Left/Chars/Char0.set_focus_mode(2)
	$Panel/All/Left/Chars/Char1.set_focus_mode(2)
	$Panel/All/Left/Chars/Char2.set_focus_mode(2)
	$Panel/All/Left/Chars/Char3.set_focus_mode(2)
	get_node("Panel/All/Left/Chars/Char0").grab_focus()


func actual_item(item):
	for i in range(len(item.effect)):
		if item.effect[i][0] == 0:
			recoverHP = item.effect[i][1]
		if item.effect[i][0] == 2:
			recoverMP = item.effect[i][1]
	item.quantity = item.quantity - 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("ui_cancel") and location == "TARGETS":
		get_parent().get_parent().get_parent().back_to_inventory()
		queue_free()

func _on_Char0_pressed():
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	get_parent().get_parent().get_parent().back_to_inventory()
	queue_free()


func _on_Char1_pressed():
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	get_parent().get_parent().get_parent().back_to_inventory()
	queue_free()


func _on_Char2_pressed():
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	get_parent().get_parent().get_parent().back_to_inventory()
	queue_free()


func _on_Char3_pressed():
	hp_char =  hp_char  + recoverHP
	mp_char  =  mp_char  + recoverMP
	if hp_char > hpmax_char:
		hp_char = hpmax_char
	if mp_char > mpmax_char:
		mp_char = mpmax_char
	location = "OUTSIDE"
	get_parent().get_parent().get_parent().back_to_inventory()
	queue_free()
