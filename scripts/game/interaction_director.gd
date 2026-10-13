class_name InteractionDirector
extends Node
## Diálogos de moradores e do exército e QTE de resgate.
## TODO (seção 4.3): depois do resgate, perguntar se quer saquear a casa
## (ReputationState.register_loot) e, se aliado, deixar saquear qualquer casa.
## Morte ou troca de personagem chamam cancel(): toda espera pendente é invalidada
## por um token, então nada continua de um estado antigo.

signal army_choice_made(choice: StringName)
signal busy_changed(busy: bool)

const CHOICE_HELP := &"help"
const CHOICE_LEAVE := &"leave"
const CHOICE_CONFRONT := &"confront"
const CHOICE_ALLY := &"ally"

var enabled: bool = false
var config: MatchConfig
var player: Player
var character_index: int = 0

var _dialog: DialogBox
var _qte: QTEPanel
var _houses: Array[VillagerHouse] = []
var _camp: ArmyCamp
var _busy: bool = false
var _token: int = 0
var _army_decided: bool = false


func setup(match_config: MatchConfig, dialog: DialogBox, qte: QTEPanel, houses: Array[VillagerHouse], camp: ArmyCamp) -> void:
	config = match_config
	_dialog = dialog
	_qte = qte
	_houses = houses
	_camp = camp
	for house: VillagerHouse in houses:
		house.player_entered.connect(_on_house_entered)
	camp.player_entered.connect(_on_camp_entered)


func begin_phase(index: int, current_player: Player) -> void:
	character_index = index
	player = current_player
	_army_decided = GameState.get_army_choice(current_id()) != &""
	enabled = true
	refresh_pois()


## Estado do mundo que o Personagem 2 herda do Personagem 1.
func prepare_world_for(index: int) -> void:
	character_index = index
	for house: VillagerHouse in _houses:
		house.load_state()
	var p1 := GameState.p1_id()
	# TODO (seção 4.5): o estado do mundo do P2 depende das escolhas do P1.
	var show_ally := index == 1 and ReputationState.is_allied(p1) and GameState.is_alive(p1)
	_camp.show_ally_figure(_stats_for(p1) if show_ally else null)
	_camp.set_decor_visible(true)
	refresh_pois()


func current_id() -> StringName:
	return GameState.character_ids[character_index]


func is_busy() -> bool:
	return _busy


func is_army_decided() -> bool:
	return _army_decided


func cancel() -> void:
	_token += 1
	enabled = false
	_dialog.cancel()
	_qte.cancel()
	_set_busy(false)


func disable_all_pois() -> void:
	for house: VillagerHouse in _houses:
		house.set_poi_active(false)
	_camp.set_poi_active(false)


## Marca (!) o que ainda tem algo a fazer.
## TODO (seção 4.3): guia de mapa com setas na borda da tela apontando para estes pontos.
func refresh_pois() -> void:
	for house: VillagerHouse in _houses:
		house.set_poi_active(character_index == 0 and house.state == GameState.HouseState.OCCUPIED)
	_camp.set_poi_active(not _army_decided)


func _on_house_entered(house: VillagerHouse) -> void:
	# Só o Personagem 1 salva moradores.
	if not enabled or _busy or character_index != 0:
		return
	if house.state == GameState.HouseState.OCCUPIED:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_run_rescue(house)


func _run_rescue(house: VillagerHouse) -> void:
	var token := _begin()
	var key := _house_key(house)
	var speaker := Texts.text("dialogues", "houses.%s.speaker" % key)
	var choice: StringName = await _dialog.ask(speaker, Texts.text("dialogues", "houses.%s.ask" % key), [
		_choice(CHOICE_HELP, "dialogues", "choices.help"),
		_choice(CHOICE_LEAVE, "dialogues", "choices.leave")])
	if token != _token:
		return
	if choice != CHOICE_HELP:
		_end()
		return
	var success: bool = await _qte.run(config.qte, Texts.text("dialogues", "qte_title"))
	if token != _token:
		return
	if not success:
		house.set_state(GameState.HouseState.LOST, false)
		refresh_pois()
		await _dialog.ask(speaker, Texts.text("dialogues", "houses.%s.failed" % key), [])
		if token == _token:
			_end()
		return
	house.set_state(GameState.HouseState.RESCUED, false)
	ReputationState.register_rescue(current_id())
	AudioManager.play_sfx(&"rescue")
	var cfg := Juice.cfg()
	if cfg:
		Juice.burst(cfg.particles_skill, house.global_position, Color(0.5, 1.0, 0.7))
	refresh_pois()
	await _dialog.ask(speaker, Texts.text("dialogues", "houses.%s.rescued" % key), [])
	if token == _token:
		_end()


func _on_camp_entered(_camp_node: ArmyCamp) -> void:
	if not enabled or _busy or _army_decided:
		return
	var token := _begin()
	var choice: StringName = await _dialog.ask(Texts.text("dialogues", "army.speaker"), _army_text(), [
		_choice(CHOICE_CONFRONT, "dialogues", "choices.confront"),
		_choice(CHOICE_ALLY, "dialogues", "choices.ally"),
		_choice(CHOICE_LEAVE, "dialogues", "choices.not_now")])
	if token != _token:
		return
	if choice == CHOICE_CONFRONT or choice == CHOICE_ALLY:
		_army_decided = true
		var id := current_id()
		GameState.set_army_choice(id, choice)
		if choice == CHOICE_ALLY:
			ReputationState.set_allied(id)
		else:
			ReputationState.register_confront(id)
		refresh_pois()
		_end()
		army_choice_made.emit(choice)
		return
	_end()


## TODO: o texto para o P2 pode mudar conforme o que o P1 fez (morreu, se aliou...).
func _army_text() -> String:
	return Texts.text("dialogues", "army.p1_ask" if character_index == 0 else "army.p2_ask")


func _begin() -> int:
	_set_busy(true)
	if player:
		player.set_input_enabled(false)
	return _token


func _end() -> void:
	_set_busy(false)
	if player and enabled and not player.dead:
		player.set_input_enabled(true)


func _set_busy(value: bool) -> void:
	if _busy != value:
		_busy = value
		busy_changed.emit(value)


func _house_key(house: VillagerHouse) -> String:
	var key := String(house.dialogue_key)
	if Texts.get_value("dialogues", "houses." + key) == null:
		key = "default"
	return key


func _choice(id: StringName, file: String, path: String) -> Dictionary:
	return {"id": id, "label": Texts.text(file, path)}


func _stats_for(id: StringName) -> CharacterStats:
	for stats: CharacterStats in config.characters:
		if stats.id == id:
			return stats
	return null
