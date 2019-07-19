extends Node

onready var first = true
onready var Play
onready var Enem
onready var Inve
onready var Position = []
onready var Leader_pos = [Vector2(500, 320)]
onready var count = 0
onready var kill = null

func get_leader_pos(id):
	var index = 10*id
	if index < len(Leader_pos):
		return Leader_pos[-index]
	else:
		return Leader_pos[0]

func init(players, enemies):
	Play = [] + players
	Enem = [] + enemies

func update_global_position(Players_pos):
	Position = [] + Players_pos
	if count < 500000:
		Leader_pos.append(Position[0])
	Leader_pos[count % 500000] = Position[0]
	count+=1

func begin_battle(Enemies, OnMap):
	kill = OnMap
	Enem = [] + Enemies
	return

func end_battle(Players, Enemies, Inventory):
	
	var total_exp = 0
	for e in Enemies:
		if e.is_dead():
			total_exp += e.get_xp()
	
	Play = []
	for p in Players:
		if not p.is_dead():
			p.remove_all_status()
			p.zero_hate()
			p.reset_hate()
			p.xp += total_exp
			print(p.get_name()+" ganhou "+str(total_exp)+" de experiência!")
			var up = STATS.level_max_exp[p.level]
			if p.xp >= up:
				print(p.get_name()+" aumentou de nível!") 
				p.xp = p.xp - up
				p.level += 1
			print(p.get_name()+" agora tem "+str(p.xp)+" de experiência no nível "+str(p.level))
			Play.append(p)
		else:
			print("this guy "+p.get_name()+" is dead and will be removed")
	
	Enem = []
	GLOBAL.INVENTORY = [] + Inventory
	GLOBAL.ALL_PLAYERS = Play
	if Players == []:
		get_tree().change_scene("res://Battle/Game Over.tscn")
	return
