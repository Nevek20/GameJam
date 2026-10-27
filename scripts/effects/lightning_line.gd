class_name LightningLine
extends Line2D
## Linha do raio encadeado (pool). Ganha um zigue-zague e some.

const SEGMENT := 26.0
const JITTER := 10.0

var _tween: Tween


func show_chain(chain_points: PackedVector2Array, tint: Color, line_width: float, lifetime: float) -> void:
	clear_points()
	global_position = Vector2.ZERO
	for i in chain_points.size() - 1:
		var a := chain_points[i]
		var b := chain_points[i + 1]
		var steps := maxi(int(a.distance_to(b) / SEGMENT), 1)
		var normal := (b - a).normalized().orthogonal()
		for s in steps:
			var t := float(s) / float(steps)
			var jitter := 0.0 if s == 0 else randf_range(-JITTER, JITTER)
			add_point(a.lerp(b, t) + normal * jitter)
	if chain_points.size() > 0:
		add_point(chain_points[chain_points.size() - 1])
	width = line_width
	default_color = Color(tint, 1.0).lightened(0.35)
	modulate = Color.WHITE
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, lifetime)
	_tween.tween_callback(_release)


func on_pool_release() -> void:
	if _tween:
		_tween.kill()
	clear_points()


func _release() -> void:
	ObjectPool.release_node(self)
