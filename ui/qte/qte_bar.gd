class_name QTEBar
extends Control
## Barra do QTE: esvazia da direita para a esquerda; a faixa clara é a janela de acerto.

var value: float = 1.0:
	set(v):
		value = v
		queue_redraw()
var window_start: float = 0.3
var window_size: float = 0.2
var fill_color: Color = Color(0.55, 0.9, 1.0)
var window_color: Color = Color(1.0, 0.85, 0.3)
var result_color: Color = Color(0, 0, 0, 0)


func set_window(start: float, window: float) -> void:
	window_start = start
	window_size = window
	result_color = Color(0, 0, 0, 0)
	queue_redraw()


func is_in_window() -> bool:
	return value >= window_start and value <= window_start + window_size


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	draw_rect(r, Color(0.05, 0.02, 0.12, 0.9))
	var win := Rect2(Vector2(size.x * window_start, 0), Vector2(size.x * window_size, size.y))
	draw_rect(win, Color(window_color, 0.35))
	draw_rect(win, window_color, false, 2.0)
	var col := fill_color.lerp(window_color, 0.7) if is_in_window() else fill_color
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * value, size.y)).grow(-4.0), col)
	var x := size.x * value
	draw_line(Vector2(x, -8), Vector2(x, size.y + 8), Color.WHITE, 3.0)
	if result_color.a > 0.0:
		draw_rect(r, Color(result_color, 0.35))
	draw_rect(r, Color(1, 1, 1, 0.8), false, 2.0)
