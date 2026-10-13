class_name TombstoneView
extends Control
## Lápide genérica (mesma cena para os dois personagens; muda só o texto).
## Textos em data/endings.json -> tombstone.<id>. Enter fecha (ou tempo, se definido).

signal closed

## Arte da lápide (vazio = placeholder desenhado).
@export var tombstone_texture: Texture2D

var is_open: bool = false
var _token: int = 0
var _tween: Tween

@onready var _title: Label = %Title
@onready var _text: RichTextLabel = %Text
@onready var _hint: Label = %Hint
@onready var _art: TextureRect = %Art
@onready var _stone: PlaceholderShape = %Stone
@onready var _content: Control = %Content


func _ready() -> void:
	hide()
	if tombstone_texture:
		_art.texture = tombstone_texture
	_art.visible = tombstone_texture != null
	_stone.visible = tombstone_texture == null


## auto_close <= 0: espera Enter.
func show_for(character_id: StringName, auto_close: float = 0.0) -> void:
	var params := {"name": Texts.character_name(character_id)}
	_title.text = Texts.text("endings", "tombstone.%s.title" % character_id, params)
	_text.text = Texts.text("endings", "tombstone.%s.text" % character_id, params)
	_hint.text = Texts.ui("ending.next", {"key": Settings.get_binding_text(Actions.CONFIRM)})
	is_open = true
	_token += 1
	show()
	_content.modulate.a = 0.0
	_content.scale = Vector2(0.9, 0.9)
	_content.pivot_offset = _content.size * 0.5
	if _tween:
		_tween.kill()
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(_content, "modulate:a", 1.0, 0.4)
	_tween.tween_property(_content, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	if auto_close > 0.0:
		get_tree().create_timer(auto_close, false).timeout.connect(_on_auto_close.bind(_token), CONNECT_ONE_SHOT)


func _on_auto_close(token: int) -> void:
	if token == _token and is_open:
		close()


func close() -> void:
	if not is_open:
		return
	is_open = false
	_token += 1
	hide()
	closed.emit()


func _unhandled_input(event: InputEvent) -> void:
	if is_open and event.is_action_pressed(Actions.CONFIRM):
		get_viewport().set_input_as_handled()
		AudioManager.play_sfx(&"ui_click")
		close()
