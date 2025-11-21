# game_manager_niveau3.gd
extends Node

@export var total_time: float = 30.0
@export var enemy_group: String = "enemy"

const FIRST_LEVEL_SCENE_PATH := "res://niveau1.tscn"

@onready var timer_label: Label = $"../CanvasLayer/TimerLabel"
@onready var win_banner:   Label = $"../CanvasLayer/WinBanner"
@onready var lose_banner:  Label = $"../CanvasLayer/LoseBanner"

@onready var win_sound: AudioStreamPlayer2D = $WinSound
@onready var lose_sound: AudioStreamPlayer2D = $LoseSound

signal level_started
signal level_won
signal level_failed

var _running := false
var _time_left := 0.0

func _ready() -> void:
    _time_left = total_time

    if timer_label:
        timer_label.visible = false
    if win_banner:
        win_banner.visible = false
    if lose_banner:
        lose_banner.visible = false

    set_process(false) # start() sera appelé par le joueur (premier mouvement)

func start() -> void:
    if _running:
        return
    _running = true
    _time_left = total_time

    if timer_label:
        timer_label.visible = true
    if win_banner:
        win_banner.visible = false
    if lose_banner:
        lose_banner.visible = false

    _update_ui()
    set_process(true)
    emit_signal("level_started")

func win() -> void:
    if not _running:
        return
    _running = false
    set_process(false)
    _stop_enemies()
    
    if win_sound:
        win_sound.play()

    if win_banner:
        win_banner.visible = true
    if lose_banner:
        lose_banner.visible = false

    emit_signal("level_won")

    await get_tree().create_timer(2.0).timeout
    get_tree().change_scene_to_file(FIRST_LEVEL_SCENE_PATH)  # → retour niveau1

func fail() -> void:
    if not _running:
        return
    _running = false
    set_process(false)
    _stop_enemies()
    
    if lose_sound:
        lose_sound.play()

    if lose_banner:
        lose_banner.visible = true
    if win_banner:
        win_banner.visible = false

    emit_signal("level_failed")

    await get_tree().create_timer(2.0).timeout
    get_tree().change_scene_to_file(FIRST_LEVEL_SCENE_PATH) # → niveau1 aussi

func _process(delta: float) -> void:
    if not _running:
        return

    _time_left -= delta
    if _time_left <= 0.0:
        _time_left = 0.0
        _update_ui()
        win()
        return

    _update_ui()

func _update_ui() -> void:
    if timer_label:
        timer_label.text = str(ceil(_time_left)) + "s"

func _stop_enemies() -> void:
    for e in get_tree().get_nodes_in_group(enemy_group):
        if e is Node:
            e.set_process(false)
            e.set_physics_process(false)
