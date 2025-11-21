extends Camera2D

@export var tilemap_group := "world_bounds"     # Groupe où se trouve TON TileMap
@export var use_smoothing := true
@export var smoothing_speed: float = 6.0

func _ready() -> void:
    enabled = true
    make_current()

    position_smoothing_enabled = use_smoothing
    if use_smoothing:
        position_smoothing_speed = smoothing_speed

func _setup_limits_from_tilemap() -> void:
    var tm := get_tree().get_first_node_in_group(tilemap_group)
    if tm == null or not (tm is TileMap):
        push_warning("Aucun TileMap trouvé dans le groupe '%s'." % tilemap_group)
        return

    var used_rect: Rect2i = tm.get_used_rect()
    if used_rect.size == Vector2i.ZERO:
        push_warning("Le TileMap n'a pas de tuiles placées (used_rect vide).")
        return

    # cellules -> pixels (casts)
    var ts: Vector2 = Vector2(tm.tile_set.tile_size)
    var min_px: Vector2 = Vector2(used_rect.position) * ts
    var max_px: Vector2 = Vector2(used_rect.position + used_rect.size) * ts

    # taille visible du viewport
    var vp_size: Vector2 = get_viewport().get_visible_rect().size
    var half_vp: Vector2 = vp_size * 0.5

    # limites
    limit_left   = int(min_px.x + half_vp.x)
    limit_top    = int(min_px.y + half_vp.y)
    limit_right  = int(max_px.x - half_vp.x)
    limit_bottom = int(max_px.y - half_vp.y)

    # si la carte est plus petite que l'écran, centre la caméra
    if limit_left > limit_right:
        var cx := int((min_px.x + max_px.x) * 0.5)
        limit_left = cx
        limit_right = cx

    if limit_top > limit_bottom:
        var cy := int((min_px.y + max_px.y) * 0.5)
        limit_top = cy
        limit_bottom = cy
        
