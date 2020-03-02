extends StaticBody2D

onready var _target = position
onready var t = $Timer
var color
var points
var _dying = 0.0
var _dying_delta = 0.1
var _dying_delta_color = 0.05
var _dying_rotate = 0.0
var _dying_rotate_delta = rand_range(-0.05, 0.05)
var _dying_threshold = 10

func _ready():
	color = $ColorRect.color
	if color == Color(1, 0, 0, 1):
		points = 50
	elif color == Color(0, 1, 0, 1):
		points = 30
	elif color == Color(0, 0, 1, 1):
		points = 10
	position.y = -30
	var time = rand_range(0,2.5)
	t.set_wait_time(time)
	t.start()
	yield(t, "timeout")
	#NOTE: the linear just sort of lowers it down into position instead of making it bounce
	$Tween.interpolate_property(self, "position", position, _target, 1.5, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	$Tween.start()
	
func _process(delta):
	if _dying > 0:
		_dying += _dying_delta
		position.y += _dying
		rotate(_dying_rotate)
		_dying_rotate += _dying_rotate_delta
		$ColorRect.color = $ColorRect.color.linear_interpolate(Color(0,0,0,0), _dying_delta_color)

func die():
	_dying += _dying_delta
	$CollisionShape2D.queue_free()
