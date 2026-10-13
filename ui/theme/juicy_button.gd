class_name JuicyButton
extends Button
## Botão com feedback: cresce no foco/hover, "aperta" no clique e toca sons de UI.

@export var hover_scale: float = 1.08
@export var press_scale: float = 0.94

var _tween: Tween


func _ready() -> void:
	focus_entered.connect(_on_focus.bind(true))
	focus_exited.connect(_on_focus.bind(false))
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_focus.bind(false))
	pressed.connect(_on_pressed)
	resized.connect(_update_pivot)
	_update_pivot()


func _update_pivot() -> void:
	pivot_offset = size * 0.5


func _on_mouse_entered() -> void:
	if not disabled:
		grab_focus()
	_on_focus(true)


func _on_focus(focused: bool) -> void:
	if focused and has_focus():
		AudioManager.play_sfx(&"ui_focus")
	_animate(Vector2.ONE * (hover_scale if focused or has_focus() else 1.0))


func _on_pressed() -> void:
	AudioManager.play_sfx(&"ui_click")
	scale = Vector2.ONE * press_scale
	_animate(Vector2.ONE * hover_scale)


func _animate(target: Vector2) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", target, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
