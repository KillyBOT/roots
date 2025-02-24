extends Area2D

signal collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
    pass

func _on_area_entered(_area: Area2D) -> void:
    if _area.is_in_group("is_root"):
        collected.emit()
    queue_free()


func _on_screen_exited() -> void:
    queue_free()
