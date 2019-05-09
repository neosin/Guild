extends "Apply.gd"

var cenaplayer = load("res://Classes/Player.gd")
var cenaenemy = load("res://Classes/Enemy.gd")
var cenaitem = load("res://Classes/Itens.gd")

var Players
var Enemies
var Inventory
var current_entity
var state
var over
var current_action
var current_target
var dead_enemies = 0
var dead_allies = 0
var total_enemies

signal round_finished

func InitBattle(Players, Enemies, Inventory, Normal, Boss, Fboss):
	var lane
	var sk = LOADER.items_from_file("res://Testes/Skills.json")
	for i in range(Players.size()):
		lane = Players[i].get_pos()
		get_node("P"+str(i)+str(lane)).show()
		for j in range(Enemies.size()):
			Players[i].hate.append(0)
	for i in range(Enemies.size()):
		lane = Enemies[i].get_pos()
		get_node("E"+str(i)+str(lane)).show()
	total_enemies = Enemies.size()

func _ready():
	over = false
	Enemies = []
	Players = []
	Inventory = LOADER.items_from_file("res://Testes/Inventory.json")
	var Skills = LOADER.items_from_file("res://Testes/Skills.json")
	Enemies.append(cenaenemy.new([25,25,100,100,10,10,5,10,9,10], 0, "Slime", []))
	Enemies.append(cenaenemy.new([25,25,100,100,10,10,5,10,9,10], 0, "Minotauro", []))
	Players.append(cenaplayer.new([100,200,50,50, 10,10,10,10,11,10], 0, "beefy boi", []))
	Players.append(cenaplayer.new([100,150,50,50, 10,10,10,10,22,10], 0, "stabby boi", Skills))
	Players.append(cenaplayer.new([100,100,50,50, 10,10,10,10,5,10], 0, "arrow boi", []))
	Players.append(cenaplayer.new([100,100,50,50, 10,10,10,10,0,10], 0, "holy boi", [Skills[-1]]))

	for c in get_node("Menu").get_children():
		c.focus_previous = NodePath("Menu/Attack")

	InitBattle(Players, Enemies, Inventory, 0,0,0)
	
	# Main battle loop: calls rounds() while the battle isn't over
	while (not over):
		for p in Players:
			print(p.get_name()+" hate matrix is ")
			print(p.hate)
		rounds()
		yield(self, "round_finished")
	$Log.display_text("Fim de jogo!")
	print("FIM DE JOGO")

# A round is comprised of the turns of all entities participating in battle
func rounds():
	# The status "AGILITY" is used to determine the turn order
	var turnorder = Players + Enemies
	turnorder.sort_custom(self, "stackagility")
	
	# Each iteration on this loop is a turn in the game
	for i in range(turnorder.size()):
		current_entity = turnorder[i]
		
		# If the entity is currently affected by a status, apply its effect
		var status = current_entity.get_status()
		if status:
			for st in status.keys():
				result_status(st, current_entity, $Log)
			current_entity.decrement_turns()
		
		# If the entity is an enemy, leave it to the AI
		if current_entity.classe == "boss":
			print("ooga booga")
			#current.AI()
		# If it's a player, check valid actions (has itens, has MP)
		else:
			if not current_entity.skills or current_entity.get_mp() == 0:
				get_node("Menu/Skills").disabled = true
			else:
				get_node("Menu/Skills").disabled = false
			if Inventory.size() == 0:
				get_node("Menu/Itens").disabled = true
			
			# Show the Menu and wait until action is selected
			get_node("Menu").show()
			$Menu/Attack.grab_focus()
			yield($Menu, "turn_finished")
			execute_action(current_action, current_target)
		# Check if all players or enemies are dead
		if check_game_over() or check_win_battle():
			over = true
			break
	emit_signal("round_finished")

# All players are dead: Defeat!
func check_game_over():
	return dead_allies == Players.size()

# All players are dead: Victory!
func check_win_battle():
	return Enemies == []

# Auxiliary function to sort the turnorder vector
func stackagility(a,b):
	return a.get_agi() > b.get_agi()

# Executes an action on a given target
func execute_action(action, target):
	
	# Attack: the target takes PHYSICAL damage
	if action == "Attack":
		var atk = current_entity.get_atk()
		var alvo = Enemies[int(target)]
		var dmg = alvo.take_damage(PHYSIC, atk)
		current_entity.update_hate(dmg, int(target))
		$Log.display_text(current_entity.get_name()+" atacou "+alvo.get_name()+", causando "+str(dmg)+" de dano "+dtype[PHYSIC])
		if alvo.get_health() <= 0:
			get_node("E"+target+"0").hide()
			Enemies.remove(int(target))
	
	# Lane: only the player characters may change lanes
	elif action == "Lane":
		for i in range(Players.size()):
			if Players[i] == current_entity:
				var lane = current_entity.get_pos()
				current_entity.set_pos(int(target))
				$Log.display_text(current_entity.get_name()+" se moveu para a lane "+dlanes[int(target)])
				get_node("P"+str(i)+str(lane)).hide()
				get_node("P"+str(i)+str(target)).show()
	
	# Item: only the player characters may use items
	elif action == "Item":
		# Quick trick to identify if target is friend or foe
		var entities = []
		target[1] = int(target[1])
		if target[1] > 0:
			entities = Players
			target[1] -= 1
		else:
			entities = Enemies
			target[1] = abs(target[1])-1
		var alvo = entities[target[1]]
		var item = Inventory[int(target[0])]
		
		# Itens may target entities, lanes or everyone
		var affected = []
		if item.get_target() == "ONE":
			affected.append(alvo)
		elif item.get_target() == "LANE":
			var affected_lane = alvo.get_pos()
			for p in entities:
				if p.get_pos() == affected_lane:
					affected.append(p)
		elif item.get_target() == "ALL":
			for p in entities:
				affected.append(p)
		
		# Apply the effect on all affected
		for alvo in affected:
			$Log.display_text(current_entity.get_name()+" usou o item "+item.nome+" em "+alvo.get_name())
			item.quantity = item.quantity - 1
			if (item.effect != []):
				for eff in item.effect:
					apply_effect(current_entity, eff, alvo,  int(target[1]), $Log)
			if (item.status != []):
				for st in item.status:
					apply_status(st, alvo, $Log)
		
		# No more of the item used
		if item.quantity == 0:
			Inventory.remove(int(target[0]))
		get_node("Menu/Attack").show()
		get_node("Menu/Lane").show()
		get_node("Menu/Skills").show()
#		get_node("Menu/Run").show()
		if alvo.get_health() <= 0:
			dead_enemies += 1
			Enemies.remove(int(target[1]))
			get_node("E"+str(target[1])+"0").hide()
	elif action == "Skills":
		var entities = []
		target[1] = int(target[1])
		if target[1] > 0:
			entities = Players
			target[1] -= 1
		else:
			entities = Enemies
			target[1] = abs(target[1])-1
		var alvo = entities[target[1]]
		var skill = current_entity.get_skills()[int(target[0])]
		
		var affected = []
		if skill.get_target() == "ONE":
			affected.append(alvo)
		elif skill.get_target() == "LANE":
			var affected_lane = alvo.get_pos()
			for p in entities:
				if p.get_pos() == affected_lane:
					affected.append(p)
		elif skill.get_target() == "ALL":
			for p in entities:
				affected.append(p)
		for alvo in affected:
			print(current_entity.get_name()+" USOU O SKILL "+skill.nome+" NO TARGET "+alvo.get_name())
			$Log.display_text(current_entity.get_name()+" usou a habilidade "+skill.nome+" em "+alvo.get_name())
			if (skill.effect != []):
				for eff in skill.effect:
					print(eff)
					apply_effect(current_entity, eff, alvo, int(target[1]), $Log)
			if (skill.status != []):
				for st in skill.status:
					apply_status(st, alvo, $Log)
		var mp = current_entity.get_mp()
		current_entity.set_stats(MP, mp-skill.quantity)
		get_node("Menu/Attack").show()
		get_node("Menu/Lane").show()
		get_node("Menu/Itens").show()
#		get_node("Menu/Run").show()
		if alvo.get_health() <= 0:
			get_node("E"+str(target[1])+"0").hide()
			Enemies.remove(int(target[1]))

# Auxiliary functions for the action selection
func set_current_action(action):
	current_action = action
	
func set_current_target(target):
	current_target = target

func _process(delta):
	if over:
		$E00.hide()
		$E10.hide()
	if Input.is_action_pressed("ui_cancel") or (Input.is_action_pressed("ui_left") and (state == "Attack" or state == "Lane")):
		for c in $Menu.get_children():
			c.hide_stuff()
		get_node("Menu/"+str(state)).grab_focus()

func _on_Lane_button_down():
	state = "Lane"
	for i in range(3):
		get_node("Menu/Lane/Targets/"+str(i)).hide()
	get_node("Menu/Lane/Targets").show()
	if current_entity.get_pos() != 2: 
		get_node("Menu/Lane/Targets/2").show()
		get_node("Menu/Lane/Targets/2").grab_focus()
		get_node("Menu/Lane/Targets/2").set_text("FRONT")
	if current_entity.get_pos() != 1: 
		get_node("Menu/Lane/Targets/1").show()
		get_node("Menu/Lane/Targets/1").grab_focus()
		get_node("Menu/Lane/Targets/1").set_text("MID")
	if current_entity.get_pos() != 0: 
		get_node("Menu/Lane/Targets/0").show()
		get_node("Menu/Lane/Targets/0").grab_focus()
		get_node("Menu/Lane/Targets/0").set_text("BACK")
	get_node("Menu/Lane/")._on_Action_pressed()

func _on_Itens_button_down():
	state = "Itens"
	LOADER.List = Inventory
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Skills").hide()
#	get_node("Menu/Run").hide()
	var itens = get_node("Menu/Itens/Targets/HBoxContainer/Itens")
	var players = get_node("Menu/Itens/Targets/HBoxContainer/Players")
	var enemies = get_node("Menu/Itens/Targets/HBoxContainer/Enemies")
	for i in range(4):
		itens.get_node(str(i)).hide()
	for i in range(1,5):
		players.get_node(str(i)).hide()
	for i in range(-5,0):
		enemies.get_node(str(i)).hide()
	for i in range(Inventory.size()):
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(Inventory[i].nome+" 	x"+str(Inventory[i].quantity))
	for i in range(1, Players.size()+1):
		players.get_node(str(i)).show()
		players.get_node(str(i)).set_text(Players[i-1].get_name()+"   HP:"+str(Players[i-1].get_health())+"/"+str(Players[i-1].get_max_health())+"        MP: "+str(Players[i-1].get_mp())+"/"+str(Players[i-1].get_max_mp()))
	for i in range(1, Enemies.size()+1):
		enemies.get_node(str(-i)).show()
		enemies.get_node(str(-i)).set_text(Enemies[abs(i)-1].get_name())
	itens.get_node("0").grab_focus()
	get_node("Menu/Itens/")._on_Action_pressed()

func _on_Skills_button_down():
	state = "Skills"
	LOADER.List = current_entity.skills
	get_node("Menu/Attack").hide()
	get_node("Menu/Lane").hide()
	get_node("Menu/Itens").hide()
#	get_node("Menu/Run").hide()
	var skills = current_entity.get_skills()
	print(skills)
	var itens = get_node("Menu/Skills/Targets/HBoxContainer/Itens")
	var players = get_node("Menu/Skills/Targets/HBoxContainer/Players")
	var enemies = get_node("Menu/Skills/Targets/HBoxContainer/Enemies")
	for i in range(4):
		itens.get_node(str(i)).hide()
	for i in range(1,5):
		players.get_node(str(i)).hide()
	for i in range(-5,0):
		enemies.get_node(str(i)).hide()
	for i in range(skills.size()):
		if current_entity.get_mp() < skills[i].quantity:
			itens.get_node(str(i)).disabled = true
		else:
			itens.get_node(str(i)).disabled = false
		itens.get_node(str(i)).show()
		itens.get_node(str(i)).set_text(skills[i].nome)
	for i in range(1, Players.size()+1):
		players.get_node(str(i)).show()
		players.get_node(str(i)).set_text(Players[i-1].get_name()+"   HP:"+str(Players[i-1].get_health())+"/"+str(Players[i-1].get_max_health())+"        MP: "+str(Players[i-1].get_mp())+"/"+str(Players[i-1].get_max_mp()))
	for i in range(1, Enemies.size()+1):
		enemies.get_node(str(-i)).show()
		enemies.get_node(str(-i)).set_text(Enemies[abs(i)-1].get_name())
	itens.get_node("0").grab_focus()
	get_node("Menu/Skills/")._on_Action_pressed()

func _on_Attack_button_down():
	state = "Attack"
	print(state)
	for i in range(total_enemies):
		get_node("Menu/Attack/Targets/"+str(i)).hide()
	for i in range(Enemies.size()):
		get_node("Menu/Attack/Targets/"+str(i)).show()
		get_node("Menu/Attack/Targets/"+str(i)).set_text(Enemies[i].nome)
	get_node("Menu/Attack/")._on_Action_pressed()
