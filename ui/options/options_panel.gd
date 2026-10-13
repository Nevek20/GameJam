class_name OptionsPanel
extends Control
## Opções: volumes (Master, Música, Efeitos), remapeamento de teclas e restaurar padrão.
## Tudo é salvo pelo autoload Settings (ConfigFile).

signal closed

var _waiting_action: StringName = &""
var _binding_buttons: Dictionary = {}

@onready var _master: HSlider = %MasterSlider
@onready var _music: HSlider = %MusicSlider
@onready var _sfx: HSlider = %SfxSlider
@onready var _bindings: VBoxContainer = %Bindings
@onready var _restore: Button = %RestoreButton
@onready var _back: Button = %BackButton
@onready var _hint: Label = %RemapHint


func _ready() -> void:
	hide()
	%Title.text = Texts.ui("options.title")
	%AudioTitle.text = Texts.ui("options.audio")
	%ControlsTitle.text = Texts.ui("options.controls")
	%MasterLabel.text = Texts.ui("options.master")
	%MusicLabel.text = Texts.ui("options.music")
	%SfxLabel.text = Texts.ui("options.sfx")
	_restore.text = Texts.ui("options.restore")
	_back.text = Texts.ui("options.back")
	_hint.text = ""
	for slider: HSlider in [_master, _music, _sfx]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.05
	_master.value_changed.connect(_on_volume.bind(&"Master"))
	_music.value_changed.connect(_on_volume.bind(&"Music"))
	_sfx.value_changed.connect(_on_volume.bind(&"SFX"))
	_build_binding_rows()
	_restore.pressed.connect(_on_restore)
	_back.pressed.connect(close)
	Settings.settings_changed.connect(_refresh)


func open() -> void:
	show()
	_refresh()
	_master.grab_focus()


func close() -> void:
	_waiting_action = &""
	hide()
	closed.emit()


func _build_binding_rows() -> void:
	for action: StringName in Actions.REMAPPABLE:
		var row := HBoxContainer.new()
		row.add_theme_constant_override(&"separation", 12)
		var label := Label.new()
		label.text = Texts.ui("actions.%s" % action)
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var button := JuicyButton.new()
		button.custom_minimum_size = Vector2(180, 34)
		button.pressed.connect(_on_binding_pressed.bind(action))
		row.add_child(label)
		row.add_child(button)
		_bindings.add_child(row)
		_binding_buttons[action] = button


func _refresh() -> void:
	_master.set_value_no_signal(Settings.get_volume(&"Master"))
	_music.set_value_no_signal(Settings.get_volume(&"Music"))
	_sfx.set_value_no_signal(Settings.get_volume(&"SFX"))
	for action: StringName in _binding_buttons:
		var button: Button = _binding_buttons[action]
		button.text = Texts.ui("options.press_key") if action == _waiting_action else Settings.get_binding_text(action)


func _on_volume(value: float, bus: StringName) -> void:
	Settings.set_volume(bus, value)
	AudioManager.play_sfx(&"ui_focus")


func _on_binding_pressed(action: StringName) -> void:
	_waiting_action = action
	_hint.text = Texts.ui("options.remap_hint")
	_refresh()


func _on_restore() -> void:
	_waiting_action = &""
	_hint.text = ""
	Settings.restore_defaults()


# _input: captura a próxima tecla/botão antes da interface consumir.
func _input(event: InputEvent) -> void:
	if _waiting_action == &"" or not visible:
		return
	var new_event: InputEvent = null
	var key := event as InputEventKey
	if key and key.pressed and not key.echo:
		if key.keycode == KEY_ESCAPE and _waiting_action != Actions.PAUSE:
			_cancel_remap()
			return
		var clean := InputEventKey.new()
		clean.physical_keycode = key.physical_keycode
		clean.keycode = key.keycode
		new_event = clean
	var mouse := event as InputEventMouseButton
	if mouse and mouse.pressed:
		var clean_mouse := InputEventMouseButton.new()
		clean_mouse.button_index = mouse.button_index
		new_event = clean_mouse
	if new_event == null:
		return
	get_viewport().set_input_as_handled()
	var action := _waiting_action
	_waiting_action = &""
	_hint.text = ""
	Settings.rebind(action, new_event)
	(_binding_buttons[action] as Button).grab_focus()


func _cancel_remap() -> void:
	get_viewport().set_input_as_handled()
	var action := _waiting_action
	_waiting_action = &""
	_hint.text = ""
	_refresh()
	(_binding_buttons[action] as Button).grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and _waiting_action == &"" and event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close()
