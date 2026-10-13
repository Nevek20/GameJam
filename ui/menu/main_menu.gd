extends Control
## Tela 1: Jogar, Opções e Créditos. Navegação por teclado e mouse.

@onready var _play: Button = %PlayButton
@onready var _options_button: Button = %OptionsButton
@onready var _credits_button: Button = %CreditsButton
@onready var _menu: Control = %MenuBox
@onready var _options: OptionsPanel = %Options
@onready var _credits_panel: Control = %CreditsPanel
@onready var _credits_back: Button = %CreditsBack
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle

var _title_tween: Tween


func _ready() -> void:
	_title.text = Texts.ui("menu.title")
	_subtitle.text = Texts.ui("menu.subtitle")
	_play.text = Texts.ui("menu.play")
	_options_button.text = Texts.ui("menu.options")
	_credits_button.text = Texts.ui("menu.credits")
	_credits_back.text = Texts.ui("options.back")
	_play.pressed.connect(_on_play)
	_options_button.pressed.connect(_on_options)
	_credits_button.pressed.connect(_on_credits)
	_credits_back.pressed.connect(_close_credits)
	_options.closed.connect(_on_options_closed)
	_credits_panel.hide()
	AudioManager.play_music(&"menu")
	_play.grab_focus.call_deferred()
	_title.pivot_offset = _title.size * 0.5
	_title_tween = create_tween().set_loops()
	_title_tween.tween_property(_title, "rotation", deg_to_rad(1.5), 1.6).set_trans(Tween.TRANS_SINE)
	_title_tween.tween_property(_title, "rotation", deg_to_rad(-1.5), 1.6).set_trans(Tween.TRANS_SINE)


func _on_play() -> void:
	for button: Button in [_play, _options_button, _credits_button]:
		button.disabled = true
	GameManager.start_new_game()


func _on_options() -> void:
	_menu.hide()
	_options.open()


func _on_options_closed() -> void:
	_menu.show()
	_options_button.grab_focus()


func _on_credits() -> void:
	_menu.hide()
	_credits_panel.show()
	_credits_back.grab_focus()


func _close_credits() -> void:
	_credits_panel.hide()
	_menu.show()
	_credits_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _credits_panel.visible and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		_close_credits()
