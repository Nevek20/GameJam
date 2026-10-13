class_name Banner
extends Control
## Faixa de anúncio no topo (troca de personagem, boss, escolhas).

@export var ui_config: UIConfig

var _tween: Tween

@onready var _title: Label = %BannerTitle
@onready var _subtitle: Label = %BannerSubtitle


func _ready() -> void:
	hide()


func show_banner(title: String, subtitle: String = "") -> void:
	_title.text = title
	_subtitle.text = subtitle
	_subtitle.visible = not subtitle.is_empty()
	show()
	modulate.a = 0.0
	pivot_offset = size * 0.5
	scale = Vector2(1.3, 1.3)
	if _tween:
		_tween.kill()
	var hold := ui_config.banner_duration if ui_config else 2.0
	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(self, "modulate:a", 1.0, 0.2)
	_tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_tween.chain().tween_interval(hold)
	_tween.chain().tween_property(self, "modulate:a", 0.0, 0.4)
	_tween.chain().tween_callback(hide)
