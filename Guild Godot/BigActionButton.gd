extends Button
var item_picked = null

signal action_picked

func _ready():
	for c in $Targets/HBoxContainer/Itens.get_children():
		c.connect("target_picked", self, "_on_Item_Picked")
	for c in $Targets/HBoxContainer/Players.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")
	for c in $Targets/HBoxContainer/Enemies.get_children():
		c.connect("target_picked", self, "_on_Target_Picked")

func _on_Target_Picked(target):
	if item_picked != null:
		target = [item_picked, target]
		emit_signal("action_picked", self.text, target)
		$Targets/HBoxContainer.hide()
		#self.disabled = false

func _on_Action_pressed():
	$Targets/HBoxContainer.show()

func _on_Item_Picked(item):
	item_picked = item