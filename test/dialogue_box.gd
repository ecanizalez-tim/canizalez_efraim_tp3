extends CanvasLayer

@export var close_on_end := true

var _lines: Array[String] = []
var _i: int = 0
var _is_open := false

@onready var panel: Control            = $Panel
@onready var vb: Control               = $Panel/VBoxContainer
@onready var text_label: RichTextLabel = $Panel/VBoxContainer/Text
@onready var hint_label: Label         = $Panel/VBoxContainer/Hint

signal closed

func _enter_tree() -> void:
    if not is_in_group("dialogue_ui"):
        add_to_group("dialogue_ui")

func _ready() -> void:
    
    follow_viewport_enabled = false
    layer = 10

    _setup_layout()
    _update_layout()
    get_viewport().size_changed.connect(_update_layout)

    
    text_label.autowrap_mode = TextServer.AUTOWRAP_WORD
    text_label.visible_characters = -1
    text_label.add_theme_color_override("default_color", Color(1, 1, 1))
    hint_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT

    
    var sb := StyleBoxFlat.new()
    sb.bg_color = Color(0, 0, 0, 0.75)
    panel.add_theme_stylebox_override("panel", sb)

    visible = false


func _setup_layout() -> void:
    panel.anchor_left = 0.0
    panel.anchor_right = 1.0
    panel.anchor_top = 1.0
    panel.anchor_bottom = 1.0
    panel.offset_left = 0.0
    panel.offset_right = 0.0
    panel.offset_bottom = 0.0
    panel.offset_top = -160.0  

    vb.anchor_left = 0.0
    vb.anchor_right = 1.0
    vb.anchor_top = 0.0
    vb.anchor_bottom = 1.0
    vb.offset_left = 0.0
    vb.offset_top = 0.0
    vb.offset_right = 0.0
    vb.offset_bottom = 0.0

func _update_layout() -> void:
    panel.offset_top = -160.0


func is_open() -> bool:
    return _is_open

func open(lines: Array[String]) -> void:
    if lines.is_empty():
        return
    _lines = lines.duplicate()
    _i = 0
    _is_open = true
    visible = true
    _show_current()

func next() -> void:
    if not _is_open:
        return

    
    if _i >= _lines.size() - 1:
        if close_on_end:
            _close()
        else:
            _i = _lines.size() - 1
            _show_current()
        return

    _i += 1
    _show_current()


func _show_current() -> void:
    text_label.text = _lines[_i]
    hint_label.text = "[E] Suivant / Fermer"

func _close() -> void:
    _is_open = false
    visible = false
    text_label.text = ""
    hint_label.text = ""
    closed.emit()


func _unhandled_input(event: InputEvent) -> void:
    if not _is_open:
        return
    if event.is_action_pressed("interact") or event.is_action_pressed("ui_accept"):
        next()
