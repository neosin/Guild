extends Node2D

var OFFSET_LANE = Vector2(140, 0)
var current_lane = 0
var initial_position
var my_turn = false
var bounds = [0,0,0,0,0]
export(bool) var Player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_position = self.get_global_position()
	if not Player:
		$Turn.set_color(Color(1, 0, 0))
		$ProgressBar.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_sprite(sprite):
	$Sprite.texture = load(sprite)

# Just hide for now
func die():
	self.hide()

func turn(keep=false):
	if keep:
		my_turn = true
	$Turn.show()

func end_turn(force=false):
	if not my_turn or force:
		$Turn.hide()

func change_lane(lane):
	var new_pos = initial_position
	if lane == 0: # back
		self.set_position(new_pos)
	elif lane == 1: # mid
		self.set_position(new_pos + OFFSET_LANE)
	elif lane == 2: # front
		self.set_position(new_pos + 2*OFFSET_LANE)

func update_bounds(bounds):
	self.bounds = bounds
	
func display_hate(value, id):
	$ProgressBar.set_value(value)
	$ProgressBar.max_value = bounds[id]
	$ProgressBar.show()
	
func hide_hate():
	$ProgressBar.hide()