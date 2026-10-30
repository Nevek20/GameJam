@tool
class_name DreamDecor
extends Node2D
## Decoração psicodélica sem colisão (espirais, olhos, flores e cogumelos),
## gerada por semente e desenhada uma única vez. Placeholder até chegar a arte.

@export var area: Rect2 = Rect2(0, 0, 3200, 2000):
	set(value):
		area = value
		queue_redraw()
@export var count: int = 140:
	set(value):
		count = value
		queue_redraw()
@export var seed_value: int = 7:
	set(value):
		seed_value = value
		queue_redraw()
@export var palette: PackedColorArray = PackedColorArray([
	Color(0.98, 0.45, 0.85), Color(0.45, 0.95, 0.9), Color(1.0, 0.85, 0.35),
	Color(0.65, 0.5, 1.0), Color(0.5, 1.0, 0.55)]):
	set(value):
		palette = value
		queue_redraw()


func _draw() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	for i in count:
		var p := Vector2(rng.randf_range(area.position.x, area.end.x), rng.randf_range(area.position.y, area.end.y))
		var col := palette[rng.randi() % palette.size()]
		var s := rng.randf_range(6.0, 18.0)
		match rng.randi() % 4:
			0:
				_spiral(p, s * 1.6, Color(col, 0.35))
			1:
				_eye(p, s, col)
			2:
				_flower(p, s, col)
			3:
				draw_circle(p, s * 0.6, Color(col, 0.25))
				draw_circle(p, s * 0.25, Color(col, 0.6))


func _spiral(center: Vector2, radius: float, col: Color) -> void:
	var points := PackedVector2Array()
	for i in 28:
		var t := float(i) / 27.0
		points.append(center + Vector2.from_angle(t * TAU * 2.2) * radius * t)
	draw_polyline(points, col, 2.0)


func _eye(center: Vector2, size: float, col: Color) -> void:
	draw_set_transform(center, 0.0, Vector2(1.0, 0.55))
	draw_circle(Vector2.ZERO, size, Color(0.95, 0.92, 1.0, 0.5))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	draw_circle(center, size * 0.45, Color(col, 0.8))
	draw_circle(center, size * 0.2, Color(0.05, 0.02, 0.1, 0.9))


func _flower(center: Vector2, size: float, col: Color) -> void:
	for k in 5:
		draw_circle(center + Vector2.from_angle(k * TAU / 5.0) * size * 0.5, size * 0.35, Color(col, 0.55))
	draw_circle(center, size * 0.3, Color(1, 0.95, 0.6, 0.8))
