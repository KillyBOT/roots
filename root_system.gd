extends Node2D

signal split(split_point: Vector2)

const split_button = MOUSE_BUTTON_LEFT

func orthogonal_projection_on_root(root: Line2D, p: Vector2) -> Vector2:
	var l0 = root.points[0]
	var l1 = root.points[1]
	var s = l1 - l0
	var v = p - l0
	return s * (v.dot(s) / s.dot(s)) + l0

func is_point_on_root(root: Line2D, p: Vector2) -> bool:
	var l0 = root.points[0]
	var l1 = root.points[1]
	var v_p = p - l0
	var v_l = l1 - l0
	
	return v_p.dot(v_l) > 0 and v_p.dot(v_l) < v_l.dot(v_l)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event):
	if event is not InputEventMouseButton or not event.pressed:
		return

	match event.button_index:
		split_button:
			# Get the clicked position in local coordinates
			var click_position = get_local_mouse_position()
			
			var closest_root = get_node("root")
			var p_min = orthogonal_projection_on_root(closest_root, click_position)
			var p_min_dist = (click_position - p_min).dot(click_position - p_min)
			for root in get_children():
				if root is Line2D:
					var p = orthogonal_projection_on_root(root, click_position)
					var dist = (click_position - p).dot(click_position - p)
					if is_point_on_root(root, p) and dist < p_min_dist:
						p_min = p
						p_min_dist = dist
						closest_root = root

			# Find the closest point on the root to the clicked position
			# Split the root at the closest point
			closest_root.split_at(p_min)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
