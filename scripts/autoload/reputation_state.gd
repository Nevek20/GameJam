extends Node
## Reputação e heroísmo por personagem. Sistema independente: só emite sinais
## (HUD, finais e boss escutam). Valores no ReputationConfig.

signal heroism_changed(character_id: StringName, value: float, maximum: float)
signal alliance_changed(character_id: StringName, allied: bool)
signal standing_changed(character_id: StringName, standing: Reputation.Standing)

const CONFIG_PATH := "res://resources/config/reputation_config.tres"

var config: ReputationConfig
var _heroism: Dictionary = {}
var _allied: Dictionary = {}
var _standing: Dictionary = {}


func _ready() -> void:
	config = load(CONFIG_PATH) as ReputationConfig
	if config == null:
		config = ReputationConfig.new()


func reset(character_ids: Array[StringName]) -> void:
	_heroism.clear()
	_allied.clear()
	_standing.clear()
	for id: StringName in character_ids:
		_heroism[id] = config.starting_heroism
		_allied[id] = false
		_standing[id] = Reputation.compute_standing(config.starting_heroism, false, config)
		heroism_changed.emit(id, config.starting_heroism, config.max_heroism)


func get_heroism(id: StringName) -> float:
	return float(_heroism.get(id, config.starting_heroism))


func get_max_heroism() -> float:
	return config.max_heroism


func is_allied(id: StringName) -> bool:
	return bool(_allied.get(id, false))


func get_standing(id: StringName) -> Reputation.Standing:
	return _standing.get(id, Reputation.Standing.QUESTIONABLE)


func add_heroism(id: StringName, amount: float) -> void:
	var value := clampf(get_heroism(id) + amount, 0.0, config.max_heroism)
	_heroism[id] = value
	heroism_changed.emit(id, value, config.max_heroism)
	_refresh_standing(id)


func register_rescue(id: StringName) -> void:
	add_heroism(id, config.rescue_gain)


func register_loot(id: StringName) -> void:
	add_heroism(id, -config.loot_loss)


func register_confront(id: StringName) -> void:
	add_heroism(id, config.confront_gain)


func register_kill(id: StringName) -> void:
	if not is_allied(id):
		add_heroism(id, config.kill_gain)


func set_allied(id: StringName, allied: bool = true) -> void:
	_allied[id] = allied
	alliance_changed.emit(id, allied)
	_refresh_standing(id)


func _refresh_standing(id: StringName) -> void:
	var standing := Reputation.compute_standing(get_heroism(id), is_allied(id), config)
	if standing != _standing.get(id):
		_standing[id] = standing
		standing_changed.emit(id, standing)
