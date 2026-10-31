extends Control
## Tela 1: Jogar, Opções e Créditos. Navegação por teclado e mouse.

@onready var _play: Button = %PlayButton
@onready var _options_button: Button = %OptionsButton
@onready var _credits_button: Button = %CreditsButton
@onready var _quit_button: Button = %QuitButton
@onready var _footer: Label = %Footer
@onready var _background: TextureRect = $Background
@onready var _menu: Control = %MenuBox
@onready var _options: OptionsPanel = %Options
@onready var _credits_panel: Control = %CreditsPanel
@onready var _credits_back: Button = %CreditsBack
@onready var _title: Label = %Title
@onready var _subtitle: Label = %Subtitle



func _ready() -> void:
	GameScale.apply_ui(self)
	_title.text = Texts.ui("menu.title")
	_subtitle.text = Texts.ui("menu.subtitle")
	_play.text = Texts.ui("menu.play")
	_options_button.text = Texts.ui("menu.options")
	_credits_button.text = Texts.ui("menu.credits")
	_quit_button.text = Texts.ui("menu.quit")
	_footer.text = Texts.ui("menu.footer")
	# No navegador não existe "sair do jogo".
	_quit_button.visible = not OS.has_feature("web")
	_quit_button.pressed.connect(func() -> void: get_tree().quit())
	_credits_back.text = Texts.ui("options.back")
	_play.pressed.connect(_on_play)
	_options_button.pressed.connect(_on_options)
	_credits_button.pressed.connect(_on_credits)
	_credits_back.pressed.connect(_close_credits)
	_options.closed.connect(_on_options_closed)
	_credits_panel.hide()
	AudioManager.play_music(&"menu")
	_play.grab_focus.call_deferred()
	_animate_entrance()


## Entrada: fundo com zoom lento (vai e volta), título desce, botões aparecem um a um.
func _animate_entrance() -> void:
	_background.pivot_offset = _background.size * 0.5
	var zoom := create_tween().set_loops()
	zoom.tween_property(_background, "scale", Vector2.ONE * 1.06, 18.0).set_trans(Tween.TRANS_SINE)
	zoom.tween_property(_background, "scale", Vector2.ONE, 18.0).set_trans(Tween.TRANS_SINE)
	var intro := create_tween().set_parallel(true)
	for item: Control in [_title, _subtitle]:
		var end_y := item.position.y
		item.position.y -= 24.0
		item.modulate.a = 0.0
		intro.tween_property(item, "position:y", end_y, 0.6).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
		intro.tween_property(item, "modulate:a", 1.0, 0.6)
	var delay := 0.35
	for child: Node in _menu.get_children():
		var button := child as Control
		if button == null or not button.visible:
			continue
		button.modulate.a = 0.0
		intro.tween_property(button, "modulate:a", 1.0, 0.35).set_delay(delay)
		delay += 0.08
	_footer.modulate.a = 0.0
	intro.tween_property(_footer, "modulate:a", 1.0, 0.8).set_delay(delay)


func _on_play() -> void:
	for button: Button in [_play, _options_button, _credits_button, _quit_button]:
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
