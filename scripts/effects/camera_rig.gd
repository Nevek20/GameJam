class_name CameraRig
extends Camera2D
## Câmera suave que segue o alvo, respeita os limites do mapa e faz shake/zoom.

var target: Node2D
var _shake_strength: float = 0.0
var _shake_left: float = 0.0
var _shake_total: float = 0.0
var _zoom_tween: Tween


func _ready() -> void:
	process_callback = Camera2D.CAMERA2D_PROCESS_PHYSICS
	position_smoothing_enabled = true


func set_target(node: Node2D, snap: bool = false) -> void:
	target = node
	if target and snap:
		global_position = target.global_position
		reset_smoothing()


func set_bounds(rect: Rect2) -> void:
	limit_left = int(rect.position.x)
	limit_top = int(rect.position.y)
	limit_right = int(rect.end.x)
	limit_bottom = int(rect.end.y)


func set_smoothing(speed: float) -> void:
	position_smoothing_speed = speed


func add_shake(strength: float, duration: float) -> void:
	# Mantém o mais forte em vez de somar (evita câmera enlouquecida).
	if strength >= _shake_strength * (_shake_left / maxf(_shake_total, 0.001)):
		_shake_strength = strength
		_shake_left = duration
		_shake_total = duration


func zoom_punch(amount: float, duration: float) -> void:
	if _zoom_tween:
		_zoom_tween.kill()
	_zoom_tween = create_tween()
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE * (1.0 + amount), duration * 0.3) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_zoom_tween.tween_property(self, "zoom", Vector2.ONE, duration * 0.7) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _physics_process(delta: float) -> void:
	if target and is_instance_valid(target):
		global_position = target.global_position
	if _shake_left > 0.0:
		_shake_left -= delta
		var k := _shake_left / maxf(_shake_total, 0.001)
		var s := _shake_strength * k * k
		offset = Vector2(randf_range(-s, s), randf_range(-s, s))
	elif offset != Vector2.ZERO:
		offset = Vector2.ZERO
