class_name GuardVisual
extends Node2D
## Escudo desenhado enquanto defende; brilha dourado no parry.

var radius: float = 28.0
var guard_color: Color = Color(0.6, 0.9, 1.0)
var parry_color: Color = Color(1.0, 0.85, 0.3)
var in_parry_window: bool = false
var _tween: Tween


## Escudo em volta do corpo (coordenadas do Visual, que já está na escala do personagem).
func show_guard(body_size: Vector2) -> void:
	radius = maxf(body_size.x, body_size.y) * 0.5 + 8.0
	position = Vector2(0, -body_size.y * 0.5)
	visible = true
	modulate = Color.WHITE
	scale = Vector2.ONE
	queue_redraw()


func hide_guard() -> void:
	visible = false


func set_parry_window(value: bool) -> void:
	if value != in_parry_window:
		in_parry_window = value
		queue_redraw()


func parry_flash() -> void:
	if _tween:
		_tween.kill()
	scale = Vector2.ONE * 1.6
	modulate = Color(3, 3, 3)
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "modulate", Color.WHITE, 0.25)


func _draw() -> void:
	var col := parry_color if in_parry_window else guard_color
	draw_circle(Vector2.ZERO, radius, Color(col, 0.12))
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 40, Color(col, 0.85), 3.0)
