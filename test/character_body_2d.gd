extends CharacterBody2D

@export var speed: float = 120.0

var direction: Vector2 = Vector2.ZERO
var _has_moved_once := false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

signal died


func _physics_process(_delta: float) -> void:
    # 1) Lire l’input
    direction = Vector2.ZERO

    if Input.is_action_pressed("ui_right"):
        direction.x += 1
    if Input.is_action_pressed("ui_left"):
        direction.x -= 1
    if Input.is_action_pressed("ui_down"):
        direction.y += 1
    if Input.is_action_pressed("ui_up"):
        direction.y -= 1

    # 2) Normaliser et bouger
    direction = direction.normalized()
    velocity = direction * speed
    move_and_slide()

    # 3) Animations
    _update_animation()

    # 4) Démarrage du GameManager au premier mouvement
    if not _has_moved_once and direction.length() > 0.0:
        _has_moved_once = true
        var gm = get_tree().get_first_node_in_group("game_manager")
        if gm and gm.has_method("start"):
            gm.start()


func _update_animation() -> void:
    if anim == null:
        return

    if direction == Vector2.ZERO:
        anim.play("idle")
        return

    if abs(direction.x) > abs(direction.y):
        if direction.x > 0.0:
            anim.play("walk_right")
        else:
            anim.play("walk_left")
    else:
        if direction.y > 0.0:
            anim.play("walk_down")
        else:
            anim.play("walk_up")


func apply_damage(_amount: int, _knockback_dir := Vector2.ZERO) -> void:
    died.emit()
    var gm = get_tree().get_first_node_in_group("game_manager")
    if gm and gm.has_method("fail"):
        gm.fail()
