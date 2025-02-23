extends Node

signal game_over(final_score: int)
signal game_start
signal next_level

## The effect that depth should have on the total score.
@export var depth_multiplier: float
## The effect that level should have on the total score.
@export var level_multiplier: float
## How long should a level be until moving on to the next one?
@export var level_length: float
## What's the highest level achieveable?
@export var max_level: int
## The starting speed
@export var min_growth_speed: float
## The ending speed; the speed at max level
@export var max_growth_speed: float
@export var min_depth_until_collectable: float
## The maximum depth between collectables
@export var max_depth_until_collectable: float
## The number of points to get for each collectable
@export var points_per_collectable: float

@export var collectable: PackedScene
@export var roots: PackedScene

@onready var _roots: Node2D = null
@onready var _hud: CanvasLayer = $HUD

@onready var _half_screen_height: float = get_viewport().size[1] / 2.0
@onready var _half_screen_width: float = get_viewport().size[0] / 2.0
var _depth_until_collectable: float
var _prev_depth: float

@onready var running: bool = false
@onready var level: int = 1
@onready var score: float = 0.0

# A simple linear interpolation
func _update_growth_speed() -> void:
    _roots.growth_speed = min_growth_speed + (level * (max_growth_speed - min_growth_speed)) / (max_level)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    
    if not running:
        return
        
    # Update score
    var delta_depth = max(0.0, _roots.depth - _prev_depth)
    score += (delta_depth * depth_multiplier) * _roots.num_growing * level * level_multiplier
    
    # Update level
    if level < max_level and _prev_depth > (level * level_length * (1 + level)) / 2.0:
        next_level.emit()
    
    _hud.update(_prev_depth, int(score), _roots.num_growing, level)
        
    # Spawn a collectable, if possible
    while _roots.depth + _half_screen_height > _depth_until_collectable:
        
        var new_collectable = collectable.instantiate()
        new_collectable.position = Vector2(randf_range(-_half_screen_width, _half_screen_width), _depth_until_collectable)
        new_collectable.collected.connect(_on_collectable_collected)
        add_child(new_collectable)
        
        _depth_until_collectable += randf_range(min_depth_until_collectable, max_depth_until_collectable)
    
    _prev_depth = _roots.depth

func _start_game() -> void:
    game_start.emit()
func _on_game_start() -> void:
    level = 1
    score = 0.0
    
    if _roots != null:
        _roots.queue_free()
    _roots = roots.instantiate()
    add_child(_roots)
    
    _roots.no_roots_growing.connect(_stop_current_game)
    _roots.roots_hit_something.connect(_stop_current_game)
    
    game_over.connect(Callable(_roots, "_on_game_over"))

    _prev_depth = _roots.depth
    _depth_until_collectable = _half_screen_height + randf_range(min_depth_until_collectable, max_depth_until_collectable)
    _update_growth_speed()
    
    running = true
    _roots.running = true

func _stop_current_game() -> void:
    if running:
        running = false
        game_over.emit(int(score))

func _on_game_over(_final_score: int) -> void:
    pass

func _on_next_level() -> void:
    level += 1
    _update_growth_speed()

func _on_collectable_collected() -> void:
    score += points_per_collectable * level
