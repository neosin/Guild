extends LOADER

var dstats = {HP:"HP", HP_MAX:"HP máximo",MP:"MP", MP_MAX:"MP máximo", ATK:"ATK", ATKM:"ATKM", DEF:"DEF", DEFM:"DEFM", AGI:"AGI", ACC:"ACC", LCK:"LCK"}
# Stats
enum {HP, HP_MAX, MP, MP_MAX, ATK, ATKM, DEF, DEFM, AGI, ACC, LCK}

var sstats = {0:"CONFUSION", 1:"POISON", 2:"BURN", 3:"SLOW", 
	4:"HASTE", 5:"BERSERK", 6:"REGEN", 7:"UNDEAD", 8:"PETRIFY", 9:"SILENCE", 
	10:"BLIND", 11:"DOOM", 12:"PARALYSIS", 13:"MAX_HP_DOWN", 14:"MAX_MP_DOWN", 
	15:"SLEEP", 16:"FLOAT", 17:"UNKILLABLE", 18:"VISIBILITY", 19:"REFLECT", 
	20:"CONTROL", 21:"CHARM", 22:"HP_CRITICAL", 23:"CURSE", 24:"STOP", 
	25:"HIDDEN", 26:"FREEZE", 27:"IMMOBILIZE", 28:"KO", 29:"VEIL", 30:"TRAPPED"}

# Attack type
enum {PHYSIC, MAGIC}
var dtype = {PHYSIC:"físico", MAGIC:"mágico"}
var dlanes = {0:"do fundo", 1:"do meio", 2:"da frente"}

func apply_effect(who, effect, target, t_id, logs):
	var stat = effect[0]
	var value = effect[1]
	var type = effect[2]
	var times = effect[3]
	var TargetStat = target.get_stats(stat)
	var finalval = TargetStat + value
	var valmax = 9999
	for i in range(times):
		print(i)
		if stat == HP and value < 0:
			var dmg = target.take_damage(type, abs(value))
			who.update_hate(dmg, t_id)
		elif stat == HP:
			valmax = target.get_stats(HP_MAX)
		elif stat == MP:
			valmax = target.get_stats(MP_MAX)
		if TargetStat + value > valmax:
			finalval = valmax
		target.set_stats(stat, finalval)
	logs.display_text(target.get_name()+" agora tem "+str(target.get_stats(stat))+" de "+dstats[stat])

func apply_status(status, target, logs):
	var type = status[1]
	var value = status[0]
	if value:
		logs.display_text(target.get_name()+" agora está sob o efeito de "+sstats[type])
		target.add_status(sstats[type], 3)
	else:
		logs.display_text(target.get_name()+" não está mais sob o efeito de "+sstats[type])
		target.remove_status(sstats[type])

func result_status(status, target, logs):
	if status == "POISON":
		var hp = target.get_health()
		target.set_stats(HP, hp-10)
		logs.display_text(target.get_name()+" levou 10 de dano de Poison")
	elif status == "REGEN":
		var hp = target.get_health()
		target.set_stats(HP, hp+10)
		logs.display_text(target.get_name()+" recuperou 10 de HP")