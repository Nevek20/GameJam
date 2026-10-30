class_name CharacterChoice
extends Control
## Escolha de quem enfrenta o cavaleiro (só quando os dois estão vivos e ninguém, ou os
## dois, se aliaram). O outro vira ajudante da IA. Teclado (setas + Enter) ou mouse.

signal chosen(character_id: StringName)

var _ids: Array[StringName] = []

@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle
@onready var _hint: Label = %Hint
@onready var _buttons: Array[Button] = [%Option1, %Option2]
@onready var _portraits: Array[TextureRect] = [%Portrait1, %Portrait2]


func _ready() -> void:
	hide()
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_pressed.bind(i))


## stats é mantido na assinatura usada pelo chamador da tela.
func open(options: Array[StringName], stats: Dictionary) -> void:
	_ids = options.duplicate()
	_title.text = Texts.ui("choice.title")
	_subtitle.text = Texts.ui("choice.subtitle")
	_hint.text = Texts.ui("choice.hint")
	for i in _buttons.size():
		var visible_option := i < _ids.size()
		_buttons[i].visible = visible_option
		_portraits[i].visible = visible_option
		if visible_option:
			_buttons[i].text = Texts.character_name(_ids[i])
			_portraits[i].texture = _portrait_for(_ids[i])
	show()
	_buttons[0].grab_focus.call_deferred()


func _portrait_for(character_id: StringName) -> Texture2D:
	if character_id == &"princess":
		return load("res://assets/sprites/princess/portrait.png") as Texture2D
	return load("res://assets/sprites/mage/idle/00.png") as Texture2D


func _on_pressed(index: int) -> void:
	if index >= _ids.size() or not visible:
		return
	hide()
	chosen.emit(_ids[index])
