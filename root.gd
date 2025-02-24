extends Area2D

@export var growing_color: Color = Color.LIGHT_GREEN
@export var stopped_color: Color = Color.WHITE

var direction : Vector2

@onready var line:Line2D = $Line2D
@onready var collider:CollisionShape2D = $CollisionShape2D
@onready var _visible_notifier:VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

@onready var growing : bool = true
@onready var paused: bool = false
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
    line.default_color = growing_color
    collider.disabled = true
    _child_roots = []

func _process(delta):
    if growing and not paused:
        var growth_amount = parent.growth_speed * delta
        line.points[-1] += direction * growth_amount
        collider.shape.b += direction * growth_amount
        _visible_notifier.rect = Rect2(line.points[0], line.points[-1] - line.points[0]).abs()

func duplicate_root() -> Area2D:
    var new_root = duplicate()
    parent.add_child(new_root)
    _child_roots.append(new_root)
    parent.num_growing += 1
    new_root.parent = parent
    
    return new_root

func split_at(start: Vector2):
    
    # Create a new branch
    var new_root = duplicate_root()
    
    new_root.line.points = [start, start]
    new_root.direction = parent.left_direction if direction == parent.right_direction else parent.right_direction
    new_root.collider.shape = SegmentShape2D.new()
    new_root.collider.shape.a = start + new_root.direction
    new_root.collider.shape.b = start + new_root.direction
    new_root.collider.disabled = false
    
    # Split the current root at the split point into a grown and growing root
    if growing:
        new_root = duplicate_root()
        stop_growing(false)
        collider.disabled = true
        
        new_root.line.points = [start, line.points[-1]]
        new_root.direction = direction
        new_root.collider.shape = collider.shape
        new_root.collider.disabled = false

        line.points[-1] = start

func stop_growing(stop_children: bool) -> void:
    if growing:
        growing = false
        line.default_color = stopped_color
        parent.num_growing -= 1
    if stop_children:
        for child in _child_roots:
            child.stop_growing(true)

func _on_area_entered(_area: Area2D) -> void:
    if not _area.is_in_group("roots_can_touch"):
        parent.roots_hit_something.emit()

func _on_exited_screen() -> void:
    queue_free()
