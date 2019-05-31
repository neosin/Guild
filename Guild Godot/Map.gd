extends Node2D

onready var Players = []
onready var Inventory = []
onready var Enemies = []
var cara_no_mundo = load("res://Cara_no_mundo.tscn")
var Players_pos

func generate_enemies():
	var newEnemy = []
	randomize()
	var total = int(rand_range(1,5))
	for i in range(total):
		var enemy_id = int(rand_range(0,len(Enemies)))
		newEnemy.append(Enemies[enemy_id].enemy_duplicate())
	return newEnemy

# Called when the node enters the scene tree for the first time.
func _ready():
	if BATTLE_INIT.first:
		Players_pos = [Vector2(500, 300), Vector2(500, 300), Vector2(500, 300), Vector2(500, 300)]
		Players = LOADER.players_from_file("res://Testes/Players.json")
		Inventory = LOADER.items_from_file("res://Testes/Inventory.json")
		Enemies = LOADER.enemies_from_file("res://Testes/Enemies.json")
		BATTLE_INIT.init(Players, Enemies, Inventory)
	else:
		Players_pos = BATTLE_INIT.Position
		Players = BATTLE_INIT.Play
	for i in range(len(Players)):
		var cara = cara_no_mundo.instance()
		cara.set_global_position(Players_pos[i])
		cara.id = i
		$Party.add_child(cara)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	update_positions()
	if Input.is_action_just_pressed('ui_focus_next'):
		Enemies = LOADER.enemies_from_file("res://Testes/Enemies.json")
		BATTLE_INIT.begin_battle(generate_enemies())
		get_tree().change_scene("res://Battle/Battle.tscn")

func update_positions():
	for i in range(len($Party.get_children())):
		Players_pos[i] = $Party.get_child(i).get_global_position()
	BATTLE_INIT.update_global_position(Players_pos)