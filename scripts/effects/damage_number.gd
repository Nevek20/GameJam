class_name DamageNumber
extends Node2D
## Número de dano flutuante (pool). Sobe, cresce e some.

var _tween: Tween

@onready var _label: Label = $Label


func show_number(pos: Vector2, amount: float, color: Color, big: bool, cfg: JuiceConfig) -> void:
	global_position = pos + Vector2(randf_range(-10, 10), -20)
	_label.text = str(roundi(amount))
	_label.modulate = color
	modulate.a = 1.0
	var s := cfg.damage_number_big_scale if big else 1.0
	scale = Vector2.ONE * s * 0.4
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "scale", Vector2.ONE * s, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "global_position:y", global_position.y - cfg.damage_number_rise, cfg.damage_number_duration) \
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "modulate:a", 0.0, cfg.damage_number_duration * 0.4).set_delay(cfg.damage_number_duration * 0.6)
	_tween.tween_callback(_release)


func on_pool_release() -> void:
	if _tween:
		_tween.kill()


func _release() -> void:
	ObjectPool.release_node(self)
