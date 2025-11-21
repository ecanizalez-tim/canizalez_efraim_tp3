extends CharacterBody2D

@export var speed: float = 75.0
@export var chase_distance: float = 165.0
@export var attack_range: float = 15.0
@export var player_group := "player"
@export var knockback_strength: float = 40.0

@onready var hitbox: Area2D = $hitbox
@onready var atk_cd: Timer = $attack_cooldown
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D if has_node("AnimatedSprite2D") else null

var _player: Node2D = null
var _attacking: bool = false

func _ready() -> void:
    
    add_to_group("enemy")

    hitbox.body_entered.connect(Callable(self, "_on_hitbox_entered"))


# =================== IA / MOUVEMENT ===================

func _physics_process(_delta: float) -> void:
    if _player == null:
        _player = _find_player()

    if _player and is_instance_valid(_player):
        var to_player := _player.global_position - global_position
        var dist := to_player.length()

        if dist <= attack_range and atk_cd.is_stopped():
            _start_attack()
            return

        if not _attacking and dist <= chase_distance:
            var dir := to_player.normalized()
            velocity = dir * speed
            _play_move_anim(dir)
        else:
            velocity = Vector2.ZERO
            _play_idle_anim()
    else:
        velocity = Vector2.ZERO
        _play_idle_anim()

    move_and_slide()


func _find_player() -> Node2D:
    var players := get_tree().get_nodes_in_group(player_group)
    if players.size() > 0 and players[0] is Node2D:
        return players[0] as Node2D
    return null


# =================== ATTAQUE / CONTACT ===================

func _start_attack() -> void:
    _attacking = true
    velocity = Vector2.ZERO
    _play_attack_anim()
    _do_attack()
    atk_cd.start()
    await get_tree().create_timer(0.3).timeout
    _attacking = false

func _do_attack() -> void:
    if _player and is_instance_valid(_player):
        var dist := global_position.distance_to(_player.global_position)
        if dist <= attack_range:
            if _player is CharacterBody2D:
                var dir := (_player.global_position - global_position).normalized()
                (_player as CharacterBody2D).velocity += dir * knockback_strength

            var gm = get_tree().get_first_node_in_group("game_manager")
            if gm and gm.has_method("fail"):
                gm.fail()

func _on_hitbox_entered(body: Node) -> void:
    if not body.is_in_group(player_group):
        return

    var gm = get_tree().get_first_node_in_group("game_manager")
    if gm and gm.has_method("fail"):
        gm.fail()

    if body is CharacterBody2D:
        var away := ((body as Node2D).global_position - global_position).normalized()
        (body as CharacterBody2D).velocity += away * knockback_strength

    atk_cd.start()


# =================== ANIMATIONS ===================

func _play_move_anim(dir: Vector2) -> void:
    if anim == null or _attacking:
        return
    if abs(dir.x) > abs(dir.y):
        if dir.x > 0.0:
            anim.play("walk_right")
        else:
            anim.play("walk_left")
    else:
        if dir.y > 0.0:
            anim.play("walk_down")
        else:
            anim.play("walk_up")

func _play_idle_anim() -> void:
    if anim and not _attacking:
        anim.play("idle")

func _play_attack_anim() -> void:
    if anim:
        anim.play("attack")
