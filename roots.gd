extends Node2D

signal roots_hit_something
signal no_roots_growing

## Maximum distance before clicks are allowed, in pixels
@export var max_root_click_dist = 30.0
## Button to click to split the root at the highlighted location.
@export var split_button = MOUSE_BUTTON_LEFT
## Button to click to stop the highlighted root.
@export var stop_button = MOUSE_BUTTON_RIGHT
## Maximum number of roots allowed to grow at once.
@export var max_roots_growing: int
## What angle the roots should grow in, in radians
@export var split_angle: float = PI/6

var left_direction = Vector2.DOWN.rotated(split_angle)
var right_direction = Vector2.DOWN.rotated(-split_angle)

var _do_split : bool = false
var _do_stop : bool = false

@onready var _highlight: Control = $highlight
@onready var _split_sounds = [$audio/split_1, $audio/split_2, $audio/split_3, $audio/split_4]

@onready var running : bool = false
@onready var paused: bool = false
@onready var num_growing: int = 1
@onready var depth: float = 0.0
@onready var growth_speed: float = 0.0

func _ready() -> void:
    var init_root = $init_root

    init_root.direction = left_direction
    init_root.parent = self
    init_root.collider.shape.a = position + left_direction
    init_root.collider.shape.b = position + left_direction
    init_root.collider.disabled = false
    
    _split_sounds[0].play()

func _input(event):
    if not paused and event is InputEventMouseButton and event.pressed:
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
            
            # Also update the depth while we're at it
            depth = max(depth, root.line.points[-1][1])

    # Update highlight
    _highlight.visible = closest_root != null
    if closest_root != null:
        var old_direction = _highlight.split_direction
        _highlight.split_direction = left_direction if closest_root.direction == right_direction else right_direction
        if old_direction != _highlight.split_direction:
            _highlight.queue_redraw()
        _highlight.position = split_pos

    # Anything after this only happens when running
    if not running or paused:
        return
    
    if _do_split and closest_root != null and num_growing < max_roots_growing:
        closest_root.split_at(split_pos)
        _split_sounds[num_growing - 1].play()
    
    if _do_stop and closest_root != null:
        closest_root.stop_growing(true)
        if num_growing > 0:
            _split_sounds[num_growing - 1].play()
    
    _do_split = false
    _do_stop = false
        
    if num_growing == 0:
        no_roots_growing.emit()

func _on_game_over(_final_score: int) -> void:
    if running:
        running = false
        if num_growing > 0:
            for root in get_children():
                if root is Area2D:
                    root.stop_growing(false)

func _on_pause():
    paused = true
    for root in get_children():
        if root is Area2D:
            root.paused = true

func _on_resume():
    paused = false
    for root in get_children():
        if root is Area2D:
            root.paused = false
