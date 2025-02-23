extends Button

signal increase_level
signal decrease_level

func _ready():
    gui_input.connect(_on_gui_input)

func _on_gui_input(event):
    if event is InputEventMouseButton and event.pressed:
        match event.button_index:
            MOUSE_BUTTON_LEFT:
                increase_level.emit()
            MOUSE_BUTTON_RIGHT:
                decrease_level.emit()
