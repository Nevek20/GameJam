class_name CreditsView
extends Control
## Créditos roláveis carregados de data/credits.json (editar sem abrir a cena).
## auto_scroll: rola sozinho (créditos finais); segurar Enter acelera, Enter no fim avança.

signal finished

@export var ui_config: UIConfig
@export var auto_scroll: bool = false

var _scroll_pos: float = 0.0
var _at_end: bool = false

@onready var _scroll: ScrollContainer = %Scroll
@onready var _label: RichTextLabel = %CreditsText
@onready var _hint: Label = %Hint
@onready var _top_spacer: Control = %TopSpacer
@onready var _bottom_spacer: Control = %BottomSpacer


func _ready() -> void:
	_label.text = Texts.text("credits", "lines")
	_hint.visible = auto_scroll
	_hint.text = Texts.ui("credits.hint", {"key": Settings.get_binding_text(Actions.CONFIRM)})
	set_process(auto_scroll)
	# Nos créditos finais o texto entra por baixo e sai por cima.
	var spacer := get_viewport_rect().size.y if auto_scroll else 0.0
	_top_spacer.custom_minimum_size.y = spacer
	_bottom_spacer.custom_minimum_size.y = spacer
	if auto_scroll:
		_scroll.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_scroll.get_v_scroll_bar().modulate.a = 0.0


func restart() -> void:
	_scroll_pos = 0.0
	_at_end = false
	_scroll.scroll_vertical = 0


func _process(delta: float) -> void:
	if _at_end:
		return
	var speed := ui_config.credits_speed if ui_config else 40.0
	if Input.is_action_pressed(Actions.CONFIRM):
		speed *= ui_config.credits_fast_multiplier if ui_config else 4.0
	_scroll_pos += speed * delta
	_scroll.scroll_vertical = int(_scroll_pos)
	var max_scroll := _scroll.get_v_scroll_bar().max_value - _scroll.get_v_scroll_bar().page
	if _scroll_pos >= max_scroll and max_scroll > 0.0:
		_at_end = true
		_hint.text = Texts.ui("credits.end_hint", {"key": Settings.get_binding_text(Actions.CONFIRM)})


func _unhandled_input(event: InputEvent) -> void:
	if auto_scroll and _at_end and event.is_action_pressed(Actions.CONFIRM):
		get_viewport().set_input_as_handled()
		finished.emit()
