extends Node2D

@export var dialogue: Array[String] = [
    "Salut ! Bienvenue dans la zone d’essai.",
    "Appuie sur E pour passer les répliques.",
    "Bonne chance !"
]
@export var player_group := "player"  # ✅ utilise un groupe au lieu du nom
@export var player_node_name := "CharacterBody2D"  # conservé au cas où

var _player_in_range := false
var _ready_to_open := true   # anti-réouverture tant que E n'a pas été relâché

func _ready() -> void:
    $Area2D.body_entered.connect(_on_body_entered)
    $Area2D.body_exited.connect(_on_body_exited)
    if has_node("Label"):
        $Label.visible = false

    # Quand la box se ferme, on ré-affiche "Press E" si le joueur est encore là
    var dlg: Node = _get_dialogue_box()
    if dlg and dlg.has_signal("closed"):
        dlg.connect("closed", Callable(self, "_on_dialogue_closed"))

    # (optionnel) avertit s'il y a plusieurs DialogueBox
    var count := get_tree().get_nodes_in_group("dialogue_ui").size()
    if count != 1:
        push_warning("ATTENTION: %d DialogueBox dans 'dialogue_ui' (attendu: 1)." % count)

func _on_dialogue_closed() -> void:
    if _player_in_range and has_node("Label"):
        $Label.visible = true
    # À la fermeture, il faudra relâcher E avant de pouvoir rouvrir
    _ready_to_open = false

func _on_body_entered(body: Node) -> void:
    # ✅ on vérifie le groupe au lieu du nom exact
    if body.is_in_group(player_group) or body.name == player_node_name:
        _player_in_range = true
        if has_node("Label"):
            $Label.visible = true

func _on_body_exited(body: Node) -> void:
    # ✅ idem ici
    if body.is_in_group(player_group) or body.name == player_node_name:
        _player_in_range = false
        if has_node("Label"):
            $Label.visible = false

# Important : on écoute la RELÂCHE de E pour réarmer l'ouverture
func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_released("interact"):
        _ready_to_open = true

func _process(_delta: float) -> void:
    if not _player_in_range:
        return

    var dlg: Node = _get_dialogue_box()
    # Tant que la boîte est ouverte, le NPC ne fait rien (la boîte gère E toute seule)
    if dlg and dlg.has_method("is_open") and dlg.is_open():
        return

    # Ouvre seulement si box fermée + E pressé + autorisé (debounce)
    if Input.is_action_just_pressed("interact") and _ready_to_open:
        if dlg and dlg.has_method("open") and dlg.has_method("is_open") and not dlg.is_open():
            _ready_to_open = false
            if has_node("Label"):
                $Label.visible = false
            dlg.open(dialogue)

func _get_dialogue_box() -> Node:
    return get_tree().get_first_node_in_group("dialogue_ui")
