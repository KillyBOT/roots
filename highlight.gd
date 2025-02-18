extends Node2D

@export var radius : float = 10.0
@export var color : Color = Color.RED
@export var width : float = 1.0

func _draw():
	draw_circle(Vector2.ZERO, radius, color, false, width)
