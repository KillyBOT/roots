extends Node

signal game_over(final_score: int)
signal game_start
signal next_level

const sprite_scale: float = 8.0

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
## The minimum vertical spacing between collectables
@export var min_next_collectable_depth: float
## The maximum vertical spacing between collectables
@export var max_next_collectable_depth: float
## The number of points to get for each collectable
@export var points_per_collectable: float
## The minimum vertical spacing between static obstacles
@export var min_next_obstacle_depth: float
## The maximum vertical spacing between static obstacles
@export var max_next_obstacle_depth: float
## The minimum vertical spacing between static obstacles
@export var min_next_big_obstacle_depth: float
## The maximum vertical spacing between static obstacles
@export var max_next_big_obstacle_depth: float

@export var collectable: PackedScene
@export var obstacle: PackedScene
@export var big_obstacle: PackedScene
@export var roots: PackedScene

@onready var _roots: Node2D = null
@onready var _hud: CanvasLayer = $HUD
@onready var _camera: Camera2D = $background/camera

@onready var _half_screen_height: float = get_viewport().size[1] / 2.0
@onready var _half_screen_width: float = get_viewport().size[0] / 2.0
var _next_collectable_depth: float
var _next_obstacle_depth: float
var _next_big_obstacle_depth: float
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
    if level < max_level and _prev_depth > (level * level_length * (1 + level * 0.5)) / 2.0:
        next_level.emit()
    
    _hud.update_score(_prev_depth, int(score), _roots.num_growing, level)
        
    # Spawn collectables and obstacles
    while _roots.depth + _half_screen_height * 1.5 > _next_collectable_depth:
        
        var new_collectable = collectable.instantiate()
        new_collectable.position = Vector2(snappedf(randf_range(-_half_screen_width, _half_screen_width), sprite_scale), _next_collectable_depth)
        new_collectable.collected.connect(_on_collectable_collected)
        add_child(new_collectable)
        
        _next_collectable_depth += snappedf(randf_range(min_next_collectable_depth, max_next_collectable_depth), sprite_scale)
    
    while _roots.depth + _half_screen_height * 1.5 > _next_obstacle_depth:
        
        var new_obstacle = obstacle.instantiate()
        new_obstacle.position = Vector2(snappedf(randf_range(-_half_screen_width, _half_screen_width), sprite_scale), _next_obstacle_depth)
        add_child(new_obstacle)
        
        _next_obstacle_depth += snappedf(randf_range(min_next_obstacle_depth, max_next_obstacle_depth), sprite_scale)
    
    while _roots.depth + _half_screen_height * 1.5 > _next_big_obstacle_depth:
        
        var new_big_obstacle = big_obstacle.instantiate()
        new_big_obstacle.position = Vector2(snappedf(randf_range(-_half_screen_width, _half_screen_width), sprite_scale), _next_big_obstacle_depth)
        add_child(new_big_obstacle)
        
        _next_big_obstacle_depth += snappedf(randf_range(min_next_big_obstacle_depth, max_next_big_obstacle_depth), sprite_scale)
    
    _camera.position[1] = _roots.depth
    _prev_depth = _roots.depth

func _start_game() -> void:
    game_start.emit()
func _on_game_start() -> void:
    for child in get_children():
        if child.is_in_group("clear_on_start"):
            child.queue_free()

    level = _hud.starting_level
    score = 0.0
    _roots = roots.instantiate()
    add_child(_roots)
    
    _roots.no_roots_growing.connect(_stop_current_game)
    _roots.roots_hit_something.connect(_stop_current_game)
    
    game_over.connect(Callable(_roots, "_on_game_over"))

    _prev_depth = _roots.depth
    _next_collectable_depth = _half_screen_height + snappedf(randf_range(min_next_collectable_depth, max_next_collectable_depth), sprite_scale)
    _next_obstacle_depth = _half_screen_height + snappedf(randf_range(min_next_obstacle_depth, max_next_obstacle_depth), sprite_scale)
    _next_big_obstacle_depth = _half_screen_height + snappedf(randf_range(min_next_big_obstacle_depth, max_next_big_obstacle_depth), sprite_scale)
    
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
