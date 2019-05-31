extends Node

onready var first = true
onready var Play
onready var Enem
onready var Inve
onready var Position = []
onready var Leader_pos = [Vector2(500, 320)]
onready var count = 0

func init(Players, Enemies, Inventory):
	Play =  [] + Players
	Enem = [] + Enemies
	Inve = [] + Inventory
	first = false
	return

func get_leader_pos(id):
	if 50*id < len(Leader_pos):
		return Leader_pos[-id*50]
	else:
		return Leader_pos[0]

func update_global_position(Players_pos):
	Position = [] + Players_pos
	if count < 500000:
		Leader_pos.append(Position[0])
	Leader_pos[count % 500000] = Position[0]
	count+=1

func begin_battle(Enemies):
	Enem = [] + Enemies
	return

func end_battle(Players, Enemies, Inventory):
	var total_exp = 0
	for e in Enemies:
		total_exp += e.get_xp()
	
	for p in Players:
		p.xp += total_exp
		print(p.get_name()+" ganhou "+str(total_exp)+" de experiência!")
		var up = STATS.level_max_exp[p.level]
		if p.xp >= up:
			print(p.get_name()+" aumentou de nível!") 
			p.xp = p.xp - up
			p.level += 1
		print(p.get_name()+" agora tem "+str(p.xp)+" de experiência no nível "+str(p.level))
	
	Play =  [] + Players
	Enem = []
	Inve = [] + Inventory
	return