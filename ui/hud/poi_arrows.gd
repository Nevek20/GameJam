class_name PoiArrows
extends Control
## Guia do mapa: setas na borda da tela apontando para os pontos de interesse ativos
## (casas com moradores, exército, boss). Desenhadas por código, sem nós extras.

@export var ui_config: UIConfig

var targets: Array[Node2D] = []


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func set_targets(nodes: Array[Node2D]) -> void:
	targets = nodes
	set_process(not targets.is_empty())
	queue_redraw()


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	var margin := ui_config.poi_arrow_margin if ui_config else 34.0
	var arrow := ui_config.poi_arrow_size if ui_config else 16.0
	var xform := get_viewport().get_canvas_transform()
	var inner := Rect2(Vector2.ZERO, size).grow(-margin)
	var center := size * 0.5
	var bob := sin(Time.get_ticks_msec() * 0.006) * 4.0
	for target: Node2D in targets:
		if not is_instance_valid(target) or not target.is_visible_in_tree():
			continue
		if not target.has_method(&"is_poi_active") or not target.call(&"is_poi_active"):
			continue
		var color: Color = target.call(&"get_poi_color") if target.has_method(&"get_poi_color") else Color.WHITE
		var screen := xform * target.global_position
		if inner.has_point(screen):
			# Na tela: pequeno marcador quicando acima do alvo.
			var tip := screen + Vector2(0, -70 + bob)
			draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-arrow * 0.6, -arrow), tip + Vector2(arrow * 0.6, -arrow)]), color)
			continue
		var dir := (screen - center).normalized()
		var edge := _edge_point(center, dir, inner) - dir * bob
		var side := dir.orthogonal()
		var points := PackedVector2Array([edge + dir * arrow, edge - dir * arrow * 0.6 + side * arrow * 0.8, edge - dir * arrow * 0.6 - side * arrow * 0.8])
		draw_circle(edge - dir * arrow * 0.2, arrow * 1.25, Color(0.05, 0.02, 0.1, 0.55))
		draw_colored_polygon(points, color)


static func _edge_point(center: Vector2, dir: Vector2, rect: Rect2) -> Vector2:
	var tx := INF
	var ty := INF
	if dir.x > 0.0001:
		tx = (rect.end.x - center.x) / dir.x
	elif dir.x < -0.0001:
		tx = (rect.position.x - center.x) / dir.x
	if dir.y > 0.0001:
		ty = (rect.end.y - center.y) / dir.y
	elif dir.y < -0.0001:
		ty = (rect.position.y - center.y) / dir.y
	return center + dir * minf(tx, ty)
