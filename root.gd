extends Area2D

@export var is_growing_color: Color = Color.LIGHT_GREEN
@export var stopped_color: Color = Color.WHITE

var direction : Vector2

@onready var line:Line2D = $Line2D
@onready var collider:CollisionShape2D = $CollisionShape2D

@onready var is_growing : bool = true
@onready var _child_roots:Array[Area2D] = []
var parent

# Returns the result of orthogonally projecting point p onto this root
func orthogonal_projection(p: Vector2) -> Vector2:
	var l0 = line.points[0]
	var v = p - l0
	var l = line.points[-1] - l0
	
	return l0 + l * ( v.dot(l) / l.length_squared())

func point_on_root(p: Vector2) -> bool:
	var l = line.points[-1] - line.points[0]
	var l_squared_len = l.length_squared()
	var v = p - line.points[0]
	var v_squared_len = v.dot(l)
	
	return v_squared_len > 0.0 and v_squared_len < l_squared_len

func is_on_screen(screen_top:float) -> bool:
	return line.points[-1][1] >= screen_top

func _ready():
	line.default_color = is_growing_color
	_child_roots = []

func _process(delta):
	if is_growing:
		var growth_amount = parent.growth_speed * delta
		line.points[-1] += direction * growth_amount
		collider.shape.b = line.points[-1]

func split_at(start: Vector2):
	
	# Create a new branch
	var new_root = duplicate()
	
	parent.add_child(new_root)
	_child_roots.append(new_root)
	parent.num_roots_growing += 1
	
	new_root.line.points = [start, start]
	new_root.collider.shape.a = start
	new_root.collider.shape.b = start
	new_root.direction = parent.left_direction if direction == parent.right_direction else parent.right_direction
	new_root.parent = parent
	
	if is_growing:
		new_root = duplicate()
		parent.add_child(new_root)
		_child_roots.append(new_root)
		
		new_root.line.points = [start, line.points[-1]]
		new_root.collider.shape.a = start
		new_root.collider.shape.b = line.points[-1]
		new_root.direction = direction
		new_root.parent = parent

		line.points[-1] = start
		is_growing = false
		line.default_color = stopped_color

func stop_growing():
	if is_growing:
		is_growing = false
		line.default_color = stopped_color
		parent.num_roots_growing -= 1
	for child in _child_roots:
		child.stop_growing()
