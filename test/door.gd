extends Area2D

@export var player_group: String = "player"
const NEXT_SCENE: String = "res://niveau2.tscn"

func _ready() -> void:
    monitoring = true
    body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
    
    if not body.is_in_group(player_group):
        return

    print("Changement de scène -> niveau2")

    
    get_tree().call_deferred("change_scene_to_file", NEXT_SCENE)
