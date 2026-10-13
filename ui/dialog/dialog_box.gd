class_name DialogBox
extends Control
## Caixa de diálogo inferior reutilizável. Texto com efeito máquina de escrever
## e até 3 escolhas (teclado ou mouse). Enter completa o texto / confirma.
## Uso: var escolha := await dialog.ask(nome, texto, [{"id": &"sim", "label": "Sim"}])

signal choice_selected(choice_id: StringName)

const CANCEL := &"cancel"
const CONTINUE := &"continue"

@export var ui_config: UIConfig

var is_open: bool = false
var _ids: Array[StringName] = []
var _has_choices: bool = false
var _typing: bool = false
var _type_tween: Tween
var _slide_tween: Tween

@onready var _panel: Control = %Panel
@onready var _speaker: Label = %Speaker
@onready var _text: RichTextLabel = %Text
@onready var _choices: HBoxContainer = %Choices
@onready var _hint: Label = %Hint
@onready var _buttons: Array[Button] = [%Choice1, %Choice2, %Choice3]


func _ready() -> void:
	hide()
	for i in _buttons.size():
		_buttons[i].pressed.connect(_on_choice_pressed.bind(i))


func ask(speaker: String, text: String, choices: Array[Dictionary]) -> StringName:
	open(speaker, text, choices)
	return await choice_selected


func open(speaker: String, text: String, choices: Array[Dictionary]) -> void:
	is_open = true
	show()
	_speaker.text = speaker
	_speaker.visible = not speaker.is_empty()
	_text.text = text
	_has_choices = not choices.is_empty()
	_ids.clear()
	for i in _buttons.size():
		var button := _buttons[i]
		button.visible = i < choices.size()
		if i < choices.size():
			button.text = String(choices[i].get("label", ""))
			_ids.append(StringName(choices[i].get("id", &"")))
	_choices.visible = false
	_hint.text = Texts.ui("dialog.skip")
	# A raiz ocupa a tela toda em (0, 0): animar a posição dela desliza o painel.
	_panel.modulate.a = 0.0
	position.y = 40.0
	if _slide_tween:
		_slide_tween.kill()
	_slide_tween = create_tween().set_parallel(true)
	_slide_tween.tween_property(_panel, "modulate:a", 1.0, 0.15)
	_slide_tween.tween_property(self, "position:y", 0.0, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_start_typing()


## Fecha sem escolha (morte, troca de personagem). Quem espera recebe CANCEL.
func cancel() -> void:
	if is_open:
		_close(CANCEL)


func _start_typing() -> void:
	_typing = true
	_text.visible_ratio = 0.0
	if _type_tween:
		_type_tween.kill()
	var speed := ui_config.typewriter_speed if ui_config else 50.0
	var duration := float(_text.get_total_character_count()) / maxf(speed, 1.0)
	_type_tween = create_tween()
	_type_tween.tween_property(_text, "visible_ratio", 1.0, duration)
	_type_tween.tween_callback(_finish_typing)


func _finish_typing() -> void:
	if not _typing:
		return
	_typing = false
	if _type_tween:
		_type_tween.kill()
	_text.visible_ratio = 1.0
	if _has_choices:
		_choices.visible = true
		_hint.text = Texts.ui("dialog.choose")
		_buttons[0].grab_focus()
	else:
		_hint.text = Texts.ui("dialog.continue")


func _unhandled_input(event: InputEvent) -> void:
	if not is_open or not event.is_action_pressed(Actions.CONFIRM):
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	elif not _has_choices:
		_close(CONTINUE)
	else:
		var focused := get_viewport().gui_get_focus_owner() as Button
		var index := _buttons.find(focused)
		_on_choice_pressed(maxi(index, 0))


func _on_choice_pressed(index: int) -> void:
	if not is_open or _typing or index >= _ids.size():
		return
	_close(_ids[index])


func _close(choice_id: StringName) -> void:
	is_open = false
	_typing = false
	if _type_tween:
		_type_tween.kill()
	var focused := get_viewport().gui_get_focus_owner()
	if focused and is_ancestor_of(focused):
		focused.release_focus()
	hide()
	choice_selected.emit(choice_id)
