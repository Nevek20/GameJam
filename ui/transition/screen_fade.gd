class_name ScreenFade
extends CanvasLayer
## Fade preto entre telas. Bloqueia cliques enquanto está escuro.

var duration: float = 0.35
var _tween: Tween

@onready var _rect: ColorRect = $Rect


func _ready() -> void:
	layer = 128
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rect.color = Color(0.02, 0.0, 0.05, 0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func fade_out() -> void:
	_rect.mouse_filter = Control.MOUSE_FILTER_STOP
	await _fade_to(1.0)


func fade_in() -> void:
	await _fade_to(0.0)
	_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _fade_to(alpha: float) -> void:
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_rect, "color:a", alpha, duration)
	await _tween.finished
