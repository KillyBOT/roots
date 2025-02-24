extends Area2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

@onready var moving: bool = false
var speed
var direction

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    if moving:
        position[0] += delta * speed * direction

func _on_screen_entered() -> void:
    moving = true
    anim.play()

func _on_screen_exited() -> void:
    queue_free()

func _on_game_over(_score: int) -> void:
    moving = false
    anim.pause()

func _on_pause() -> void:
    moving = false
    anim.pause()

func _on_resume() -> void:
    moving = true
    anim.play()
