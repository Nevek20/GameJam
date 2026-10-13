class_name PauseMenu
extends Control
## Pausa (Esc). Fica em um CanvasLayer com process_mode ALWAYS; o resto do jogo
## pausa junto (timers e tweens pausáveis param, nada quebra).

var can_pause: bool = false

@onready var _box: Control = %Box
@onready var _resume: Button = %ResumeButton
@onready var _options_button: Button = %OptionsButton
@onready var _menu_button: Button = %MenuButton
@onready var _options: OptionsPanel = %Options


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	%Title.text = Texts.ui("pause.title")
	_resume.text = Texts.ui("pause.resume")
	_options_button.text = Texts.ui("menu.options")
	_menu_button.text = Texts.ui("pause.menu")
	_resume.pressed.connect(close)
	_options_button.pressed.connect(_on_options)
	_menu_button.pressed.connect(_on_menu)
	_options.closed.connect(_on_options_closed)


func open() -> void:
	if GameManager.is_changing_scene():
		return
	get_tree().paused = true
	show()
	_box.show()
	_resume.grab_focus()


func close() -> void:
	_options.hide()
	hide()
	get_tree().paused = false


func _on_options() -> void:
	_box.hide()
	_options.open()


func _on_options_closed() -> void:
	_box.show()
	_options_button.grab_focus()


func _on_menu() -> void:
	hide()
	GameManager.go_to_menu()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed(Actions.PAUSE):
		return
	if visible:
		if not _options.visible:
			get_viewport().set_input_as_handled()
			close()
	elif can_pause:
		get_viewport().set_input_as_handled()
		open()
