extends RigidBody2D

onready var Game = get_node("/root/Game")
onready var Starting = get_node("/root/Game/Starting")
onready var Comet = get_node("/root/Game/Comet")
onready var Camera = get_node("/root/Game/Camera")

var _decay_rate = 0.0
var _max_offset = 4
var trauma_color = Color(1,1,1,1)
var _start_position
var _trauma = 0.0
var _rotation = 0
var _rotation_speed = 0.05
var _color = 0.0
var _color_decay = 1
var _normal_color
var _size_decay = 0.03
var _alpha_decay = 0.03

var _count = 0

func _ready():
	contact_monitor = true
	_start_position = $ColorRect.rect_position
	_normal_color = $ColorRect.color
	set_max_contacts_reported(4)
	
#runs every frame of game
func _process(delta):
	if _trauma > 0:
		_decay_trauma(delta)
		apply_shake()
	if _color > 0:
		_decay_color(delta)
		_apply_color()
	if _color == 0 and $ColorRect.color != _normal_color:
		$ColorRect.color = _normal_color
		
	#comet time!
	var temp = $ColorRect.duplicate()
	temp.rect_position = Vector2(position.x + $ColorRect.rect_position.x, position.y + $ColorRect.rect_position.y)
	temp.name = "Trail " + str(_count)
	temp.color = temp.color.linear_interpolate(Color(0,0,0,1), 0.5)
	Comet.add_child(temp)
	var trail = Comet.get_children()
	for c in trail:
		c.rect_size = Vector2(c.rect_size.x - _size_decay, c.rect_size.y - _size_decay)
		c.color.a -= _alpha_decay
		if c.color.a <= 0:
			c.color.a = 0
		if c.rect_size.x <= 0.5 and c.color.a <= 0:
			c.queue_free()

func _physics_process(delta):
	# Check for collisions
	var bodies = get_colliding_bodies()
	for body in bodies:
		Camera.add_trauma(.5)
		if body.is_in_group("Tiles"):
			Game.change_score(body.points)
			add_color(1.0)
			body.die()
		add_trauma(2.0)
		if body.name == "Paddle":
			var tile_rows = get_tree().get_nodes_in_group("Tile Row")
			for t in tile_rows:
				t.add_trauma(1.0) #NOTE: why did i have to add more trauma?
				
	
	if position.y > get_viewport().size.y:
		Game.change_lives(-1)
		Starting.startCountdown(3)
		queue_free()
		

func add_color(amount):
	_color += amount
	
func _apply_color():
	var a = min(1, _color)
	$ColorRect.color = _normal_color.linear_interpolate(trauma_color, a)

func _decay_color(delta):
	var change = _color_decay * delta
	_color = max(_color - change, 0)

func add_trauma(amount):
	_trauma = min(_trauma+amount, 1)

func _decay_trauma(delta):
	var change = _decay_rate + delta
	_trauma = max(_trauma-change, 0)
	
func apply_shake():
	var shake = _trauma * _trauma
	var o_x = _max_offset * shake * _scalar()
	var o_y = _max_offset * shake * _scalar()
	$ColorRect.rect_position = _start_position + Vector2(o_x, o_y)
	
func _scalar():
	return rand_range(-1,1)
	
	
	
	
	
	
