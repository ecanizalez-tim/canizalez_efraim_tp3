extends Node2D

@onready var control: Control = $CharacterBody2D/Camera2D/Control
var pause=false


func _process(_delta: float) -> void:
    if Input.is_action_just_pressed("pause"):
        pauseMenu()
    
func pauseMenu():
    if pause:
        control.hide()
        Engine.time_scale = 1
    else:
        control.show()
        Engine.time_scale = 0
        
    pause = !pause
