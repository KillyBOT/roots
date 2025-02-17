extends Line2D

@export var growth_speed: float = 50.0  # Pixels per second
@export var split_interval: float = 1.0  # Time between splits
@export var max_length: float = 100.0    # Maximum length before splitting
@export var split_angle: float = PI/6.0   # Angle of new branches

var total_length: float = 0.0
var length: float = 0.0
var left_direction : Vector2 = Vector2.DOWN.rotated(split_angle)
var right_direction : Vector2 = Vector2.DOWN.rotated(-split_angle)
var direction = left_direction

func _ready():
	$Timer.wait_time = split_interval
	$Timer.start()
	
	#$Area2D.input_event.connect(_on_input_event)

func _process(delta):
	# Grow the root
	var growth_amount = growth_speed * delta
	length += growth_amount
	var new_point = points[-1] + direction * growth_amount
	add_point(new_point)
	remove_point(1)
	

func split_at(start: Vector2):
	# Create two new branches
	var new_root = duplicate()
	
	# Reset length for new branches
	new_root.length = 0
	# Really cursed trick
	new_root.points = [start, start]
	
	# Set new directions
	if (direction == left_direction):
		new_root.direction = right_direction
	else:
		new_root.direction = left_direction

	# Add branches to the scene
	get_parent().add_child(new_root)
