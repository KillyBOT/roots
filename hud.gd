extends CanvasLayer

signal start_button_pressed

@onready var _score = $score
@onready var _depth = $depth
@onready var _level = $level
@onready var _title = $title
@onready var _start_button = $start_button
@onready var _restart_button = $restart_button
@onready var _game_over_text = $game_over_text
@onready var _final_score = $final_score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    _score.hide()
    _level.hide()
    _depth.hide()
    _title.show()
    _start_button.show()

func update(depth: float, score: int, num_growing: int, level: int) -> void:
    _score.text = str(score) + " x" + str(num_growing)
    _depth.text = str(int(depth))
    _level.text = "Lvl. " + str(level)

func _on_pressed() -> void:
    start_button_pressed.emit()

func _on_game_start() -> void:
    _score.show()
    _level.show()
    _title.hide()
    _start_button.hide()
    _restart_button.hide()
    _game_over_text.hide()
    _final_score.hide()

func _on_game_over(final_score: int) -> void:
    
    # TODO: Make a scoreboard
    _final_score.text = "Score: " + str(final_score)
    
    _score.hide()
    _level.hide()
    _title.hide()
    _start_button.hide()
    _restart_button.show()
    _game_over_text.show()
    _final_score.show()
