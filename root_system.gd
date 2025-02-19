extends Node2D

signal game_over

@export var max_root_click_dist = 30.0
@export var split_button = MOUSE_BUTTON_LEFT
@export var stop_button = MOUSE_BUTTON_RIGHT
@export var growth_speed: float = 100.0  # Pixels per second
@export var split_angle: float = PI/6

var left_direction = Vector2.DOWN.rotated(split_angle)
var right_direction = Vector2.DOWN.rotated(-split_angle)

var _do_split : bool = false
var _do_stop : bool = false

@onready var running : bool = true

@onready var _highlight: Control = $highlight
@onready var _camera: Camera2D = $camera

@onready var num_roots_growing = 1
@onready var max_root_depth = 0
@onready var _half_screen_height = _camera.get_viewport().size[1] / 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    var init_root = $init_root

    init_root.direction = left_direction
    init_root.parent = self
    init_root.collider.shape.a = position + left_direction
    init_root.collider.shape.b = position + left_direction
    init_root.collider.disabled = false

func _input(event):
    if event is InputEventMouseButton and event.pressed:
        match event.button_index:
            split_button:
                _do_split = true
            stop_button:
                _do_stop = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    # Update closest root
    var mouse_pos = get_local_mouse_position()
    var closest_root = null
    var split_pos = null
    var min_dist_from_mouse = max_root_click_dist * max_root_click_dist

    for root in get_children():
        if root is Area2D:
            var p : Vector2 = root.orthogonal_projection(mouse_pos)
            var dist_from_mouse = p.distance_squared_to(mouse_pos)
            
            if root.point_on_root(p) and dist_from_mouse < min_dist_from_mouse:
                split_pos = p
                min_dist_from_mouse = dist_from_mouse
                closest_root = root
        
            if root.growing:
                max_root_depth = max(max_root_depth, root.line.points[-1][1])
            elif not root.is_on_screen(_camera.position[1] - _half_screen_height):
                root.queue_free()
            _camera.position[1] = max_root_depth

    _highlight.visible = closest_root != null
    if closest_root != null:
        _highlight.position = split_pos

    if running:
        if _do_split and closest_root != null:
            _do_split = false
            closest_root.split_at(split_pos)
        
        if _do_stop and closest_root != null:
            _do_stop = false
            closest_root.stop_growing(true)
    
        if num_roots_growing == 0:
            game_over.emit()

func _on_root_hit() -> void:
    game_over.emit()

func _on_game_over() -> void:
    if not running:
        return

    running = false
    if num_roots_growing > 0:
        for root in get_children():
            if root is Area2D:
                root.stop_growing(false)
    print("Game over! Root depth: ", max_root_depth)
