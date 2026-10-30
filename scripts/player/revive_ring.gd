class_name ReviveRing
extends Node2D
## Acima do personagem caído: anel do revive (verde) e barra do tempo que resta (vermelha).

@export var radius: float = 26.0
@export var height: float = 110.0


func _draw() -> void:
	var p := get_parent() as Player
	if p == null or p.revive_config == null:
		return
	var cfg := p.revive_config
	var center := Vector2(0, -height * p.size_scale)
	var progress := clampf(p.revive_progress / maxf(cfg.revive_time, 0.01), 0.0, 1.0)
	var left := clampf(p.downed_left / maxf(cfg.downed_time, 0.01), 0.0, 1.0)
	draw_circle(center, radius, Color(0, 0, 0, 0.45))
	draw_arc(center, radius, -PI * 0.5, -PI * 0.5 + TAU * progress, 40, cfg.ring_color, 6.0)
	draw_rect(Rect2(center + Vector2(-radius, radius + 8.0), Vector2(radius * 2.0, 6.0)), Color(0, 0, 0, 0.5))
	draw_rect(Rect2(center + Vector2(-radius, radius + 8.0), Vector2(radius * 2.0 * left, 6.0)), Color(1, 0.35, 0.4))
