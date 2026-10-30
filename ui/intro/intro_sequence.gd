class_name IntroSequence
extends Control
## Player de cutscene: imagens (IntroConfig) com legendas de data/intro.json.
## Enter ou clique esquerdo avança; na última, termina. O cronômetro não corre aqui.

signal finished

@export var config: IntroConfig
@export var ui_config: UIConfig

var is_playing: bool = false
var _index: int = 0
var _count: int = 1
var _captions: Array = []
var _tween: Tween

@onready var _image: TextureRect = %Image
@onready var _placeholder: Control = %Placeholder
@onready var _caption: RichTextLabel = %Caption
@onready var _hint: Label = %Hint
@onready var _counter: Label = %Counter
@onready var _content: Control = %Content


func _ready() -> void:
	hide()


## Sem argumento toca a introdução (config exportado); senão, a cutscene indicada.
func play(cutscene: IntroConfig = null) -> void:
	if cutscene:
		config = cutscene
	_captions = Texts.array("intro", config.captions_key if config else "slides")
	var images := config.images.size() if config else 0
	_count = maxi(maxi(images, _captions.size()), 1)
	_index = 0
	is_playing = true
	show()
	_show_slide()


func _show_slide() -> void:
	var texture: Texture2D = null
	if config and _index < config.images.size():
		texture = config.images[_index]
	_image.texture = texture
	_image.visible = texture != null
	_placeholder.visible = texture == null
	_caption.text = str(_captions[_index]) if _index < _captions.size() else ""
	_counter.text = "%d / %d" % [_index + 1, _count]
	_hint.text = Texts.ui("intro.next" if _index < _count - 1 else "intro.start",
		{"key": Settings.get_binding_text(Actions.CONFIRM)})
	_content.modulate.a = 0.0
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_content, "modulate:a", 1.0, ui_config.intro_fade if ui_config else 0.3)


# _input: recebe o clique antes da interface (os painéis consumiriam o clique).
func _input(event: InputEvent) -> void:
	if not is_playing or not Actions.is_advance(event):
		return
	get_viewport().set_input_as_handled()
	AudioManager.play_sfx(&"ui_click")
	_index += 1
	if _index < _count:
		_show_slide()
		return
	is_playing = false
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, ui_config.intro_fade if ui_config else 0.3)
	await _tween.finished
	hide()
	modulate.a = 1.0
	finished.emit()
