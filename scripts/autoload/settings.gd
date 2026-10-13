extends Node
## Opções do jogador: volumes (buses Master/Music/SFX) e teclas (InputMap).
## Salvas em user://settings.cfg (ConfigFile) e carregadas ao abrir o jogo.

signal settings_changed

const SAVE_PATH := "user://settings.cfg"
const DEFAULTS_PATH := "res://resources/config/default_settings.tres"
const BUSES: Array[StringName] = [&"Master", &"Music", &"SFX"]

var defaults: DefaultSettings
var _volumes: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	defaults = load(DEFAULTS_PATH) as DefaultSettings
	if defaults == null:
		defaults = DefaultSettings.new()
	_reset_volumes()
	load_settings()
	_apply_all_volumes()


func get_volume(bus: StringName) -> float:
	return float(_volumes.get(bus, 1.0))


func set_volume(bus: StringName, linear: float, save: bool = true) -> void:
	_volumes[bus] = clampf(linear, 0.0, 1.0)
	_apply_volume(bus)
	if save:
		save_settings()
	settings_changed.emit()


func rebind(action: StringName, event: InputEvent) -> void:
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, event)
	save_settings()
	settings_changed.emit()


func restore_defaults() -> void:
	InputMap.load_from_project_settings()
	_reset_volumes()
	_apply_all_volumes()
	save_settings()
	settings_changed.emit()


func get_binding_text(action: StringName) -> String:
	var events := InputMap.action_get_events(action)
	if events.is_empty():
		return "-"
	return event_to_text(events[0])


static func event_to_text(event: InputEvent) -> String:
	var key := event as InputEventKey
	if key:
		# Tecla física (posição no teclado) mostrada com o nome do layout US.
		var keycode := key.physical_keycode if key.physical_keycode != KEY_NONE else key.keycode
		return OS.get_keycode_string(keycode)
	var mouse := event as InputEventMouseButton
	if mouse:
		return Texts.ui("keys.mouse_%d" % mouse.button_index)
	return event.as_text()


func save_settings() -> void:
	var file := ConfigFile.new()
	for bus: StringName in BUSES:
		file.set_value("audio", String(bus), get_volume(bus))
	for action: StringName in Actions.REMAPPABLE:
		var serialized: Array = []
		for event: InputEvent in InputMap.action_get_events(action):
			var data := _serialize(event)
			if not data.is_empty():
				serialized.append(data)
		file.set_value("input", String(action), serialized)
	var err := file.save(SAVE_PATH)
	if err != OK:
		push_warning("Settings: não foi possível salvar (%s)" % error_string(err))


func load_settings() -> void:
	var file := ConfigFile.new()
	if file.load(SAVE_PATH) != OK:
		return
	for bus: StringName in BUSES:
		_volumes[bus] = clampf(float(file.get_value("audio", String(bus), get_volume(bus))), 0.0, 1.0)
	for action: StringName in Actions.REMAPPABLE:
		if not InputMap.has_action(action) or not file.has_section_key("input", String(action)):
			continue
		var stored: Variant = file.get_value("input", String(action), [])
		if not stored is Array or (stored as Array).is_empty():
			continue
		InputMap.action_erase_events(action)
		for data: Variant in stored as Array:
			if data is Dictionary:
				var event := _deserialize(data as Dictionary)
				if event:
					InputMap.action_add_event(action, event)


func _reset_volumes() -> void:
	_volumes[&"Master"] = defaults.master_volume
	_volumes[&"Music"] = defaults.music_volume
	_volumes[&"SFX"] = defaults.sfx_volume


func _apply_all_volumes() -> void:
	for bus: StringName in BUSES:
		_apply_volume(bus)


func _apply_volume(bus: StringName) -> void:
	var index := AudioServer.get_bus_index(bus)
	if index < 0:
		return
	var linear := get_volume(bus)
	AudioServer.set_bus_volume_db(index, linear_to_db(maxf(linear, 0.0001)))
	AudioServer.set_bus_mute(index, linear <= 0.001)


static func _serialize(event: InputEvent) -> Dictionary:
	var key := event as InputEventKey
	if key:
		return {"type": "key", "physical": int(key.physical_keycode), "keycode": int(key.keycode)}
	var mouse := event as InputEventMouseButton
	if mouse:
		return {"type": "mouse", "button": int(mouse.button_index)}
	return {}


static func _deserialize(data: Dictionary) -> InputEvent:
	match String(data.get("type", "")):
		"key":
			var key := InputEventKey.new()
			key.physical_keycode = int(data.get("physical", 0)) as Key
			key.keycode = int(data.get("keycode", 0)) as Key
			return key
		"mouse":
			var mouse := InputEventMouseButton.new()
			mouse.button_index = int(data.get("button", 1)) as MouseButton
			return mouse
	return null
