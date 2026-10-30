class_name CooldownSlot
extends Control
## Ícone de habilidade no HUD: escurece de cima para baixo durante o cooldown
## e dá um "pulo" quando fica pronto. Mostra a tecla atual (respeita remapeamento).

@export var action: StringName = &"skill_q"
@export var accent: Color = Color(1, 0.8, 0.4)
## Ícone (vazio = letra/nome curto do ui.json).
@export var icon: Texture2D

var ratio: float = 0.0
var label_text: String = ""
var _key_text: String = ""
var _tween: Tween


func _ready() -> void:
	resized.connect(func() -> void: pivot_offset = size * 0.5)
	pivot_offset = size * 0.5
	refresh_key()
	Settings.settings_changed.connect(refresh_key)


func refresh_key() -> void:
	_key_text = Settings.get_binding_text(action)
	queue_redraw()


func set_ratio(value: float) -> void:
	if absf(value - ratio) < 0.002 and (value > 0.0 or ratio <= 0.0):
		return
	var became_ready := value <= 0.0 and ratio > 0.0
	ratio = value
	queue_redraw()
	if became_ready:
		_pulse()


func _pulse() -> void:
	if _tween:
		_tween.kill()
	scale = Vector2.ONE * 1.25
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _draw() -> void:
	var r := Rect2(Vector2.ZERO, size)
	var is_ready := ratio <= 0.0
	draw_rect(r, Color(0.08, 0.04, 0.16, 0.85))
	if icon:
		draw_texture_rect(icon, r.grow(-6.0), false)
	var font := get_theme_default_font()
	var font_size := 15
	if not icon:
		draw_string(font, Vector2(0, size.y * 0.58), label_text, HORIZONTAL_ALIGNMENT_CENTER, size.x, font_size,
			accent if is_ready else Color(0.6, 0.6, 0.7))
	if not is_ready:
		draw_rect(Rect2(Vector2.ZERO, Vector2(size.x, size.y * ratio)), Color(0, 0, 0, 0.6))
	draw_rect(r, accent if is_ready else Color(0.4, 0.4, 0.5), false, 2.0 if is_ready else 1.0)
	var key_size := font.get_string_size(_key_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12)
	var key_rect := Rect2(Vector2(size.x - key_size.x - 8, -8), Vector2(key_size.x + 8, 18))
	draw_rect(key_rect, Color(0.15, 0.08, 0.25))
	draw_string(font, key_rect.position + Vector2(4, 13), _key_text, HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)
