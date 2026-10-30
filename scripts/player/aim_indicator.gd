class_name AimIndicator
extends Node2D
## Pequena seta que mostra a direção da mira em volta do personagem.

@export var distance: float = 34.0
@export var color: Color = Color(1, 1, 1, 0.7)


func _draw() -> void:
	var tip := Vector2(distance + 8.0, 0)
	draw_colored_polygon(PackedVector2Array([tip, Vector2(distance, -6), Vector2(distance, 6)]), color)
