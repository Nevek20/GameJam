class_name TutorialPanel
extends Control
## Painel lateral de tutorial (não cobre o cenário). Texto em data/tutorial.json,
## com as teclas atuais do remapeamento. Enter confirma.

signal confirmed

var is_open: bool = false
var _tween: Tween

@onready var _panel: Control = %Panel
@onready var _title: Label = %Title
@onready var _body: RichTextLabel = %Body
@onready var _hint: Label = %Hint


func _ready() -> void:
	hide()


func open(key: String) -> void:
	var keys := {
		"move": "%s %s %s %s" % [Settings.get_binding_text(Actions.MOVE_UP), Settings.get_binding_text(Actions.MOVE_LEFT),
			Settings.get_binding_text(Actions.MOVE_DOWN), Settings.get_binding_text(Actions.MOVE_RIGHT)],
		"dash": Settings.get_binding_text(Actions.DASH),
		"attack": Settings.get_binding_text(Actions.ATTACK),
		"parry": Settings.get_binding_text(Actions.PARRY),
		"skill_q": Settings.get_binding_text(Actions.SKILL_Q),
		"skill_e": Settings.get_binding_text(Actions.SKILL_E),
		"ultimate": Settings.get_binding_text(Actions.ULTIMATE),
		"confirm": Settings.get_binding_text(Actions.CONFIRM),
		"pause": Settings.get_binding_text(Actions.PAUSE),
	}
	_title.text = Texts.text("tutorial", key + ".title", keys)
	_body.text = Texts.text("tutorial", key + ".body", keys)
	_hint.text = Texts.text("tutorial", "hint", keys)
	is_open = true
	show()
	# A raiz ocupa a tela toda em (0, 0): animar a posição dela desliza o painel.
	_panel.modulate.a = 0.0
	position.x = 60.0
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_panel, "modulate:a", 1.0, 0.25)
	_tween.tween_property(self, "position:x", 0.0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed(Actions.CONFIRM):
		get_viewport().set_input_as_handled()
		is_open = false
		if _tween:
			_tween.kill()
		hide()
		AudioManager.play_sfx(&"ui_click")
		confirmed.emit()
