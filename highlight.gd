extends Control

@export var radius : float = 10.0
@export var color : Color = Color.RED
@export var circle_width : float = 1.0
@export var line_width : float = 5.0

@onready var split_direction: Vector2 = Vector2.DOWN

func _draw():
    draw_circle(Vector2.ZERO, radius, color, false, circle_width)
    draw_line(Vector2.ZERO, split_direction * radius, color, line_width)
