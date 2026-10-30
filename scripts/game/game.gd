class_name Game
extends Node2D
## Tela 2: orquestra a fase única (a vila).
## Introdução -> Tutorial -> Personagem 1 -> Personagem 2 -> Boss -> Conclusão.
## Lê/escreve GameState e ReputationState; avisa o GameManager das etapas do fluxo.

enum Phase { INTRO, TUTORIAL, PLAYING, SWITCHING, BOSS, ENDED }

@export var match_config: MatchConfig
@export var ui_config: UIConfig
@export var player_scene: PackedScene
## Cutscene ao passar do Personagem 1 para o 2.
@export var switch_cutscene: IntroConfig
## Cutscene antes da luta final (depois da escolha de personagem, quando há).
@export var boss_cutscene: IntroConfig

var phase: Phase = Phase.INTRO
var player: Player
var _players: Dictionary = {}
var _time_left: float = 0.0
var _timer_running: bool = false
## Objetivos do personagem atual (7.1).
var _army_defeated: bool = false
var _objectives_asked: bool = false
var _can_advance: bool = false

@onready var level: Level = $Level
@onready var camera: CameraRig = $Camera
@onready var juice: Juice = $Juice
@onready var pools: Pools = $Pools
@onready var hud: HUD = %HUD
@onready var dialog: DialogBox = %DialogBox
@onready var qte: QTEPanel = %QTE
@onready var tutorial: TutorialPanel = %Tutorial
@onready var intro: IntroSequence = %Intro
@onready var tombstone: TombstoneView = %Tombstone
@onready var pause_menu: PauseMenu = %PauseMenu
@onready var character_choice: CharacterChoice = %CharacterChoice
@onready var interactions: InteractionDirector = $InteractionDirector
@onready var encounter: ArmyEncounter = $ArmyEncounter
@onready var boss_director: BossDirector = $BossDirector


func _ready() -> void:
	if match_config == null:
		match_config = GameManager.match_config
	# Permite abrir game.tscn direto no editor (F6) sem passar pelo menu.
	if GameState.character_ids.is_empty():
		var ids := GameManager.character_ids()
		GameState.reset(ids)
		ReputationState.reset(ids)
	camera.set_bounds(level.camera_bounds())
	camera.set_base_zoom(GameScale.current().camera_zoom)
	for ui: Control in [hud, dialog, qte, tutorial, intro, tombstone, pause_menu, character_choice]:
		GameScale.apply_ui(ui)
	camera.set_smoothing(juice.config.camera_smoothing)
	interactions.setup(match_config, dialog, qte, level.get_houses(), level.camp)
	interactions.army_choice_made.connect(_on_army_choice)
	encounter.setup(match_config, level.camp.get_spawn_points(), level.marker_group("KnightSpawns"))
	encounter.enemy_killed.connect(_on_enemy_killed)
	encounter.encounter_cleared.connect(_on_encounter_cleared)
	interactions.house_resolved.connect(func(_h: VillagerHouse) -> void: _check_objectives())
	interactions.busy_changed.connect(func(busy: bool) -> void: if not busy: _check_objectives())
	encounter.wave_started.connect(_on_wave_started)
	boss_director.boss_defeated.connect(_on_boss_defeated)
	_create_players()
	_update_pois()
	@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
	_run_intro()


func _create_players() -> void:
	for stats: CharacterStats in match_config.characters:
		var p := player_scene.instantiate() as Player
		level.actors.add_child(p)
		p.setup(stats, Team.Faction.HEROES, HumanController.new())
		p.deactivate()
		p.died.connect(_on_player_died)
		_players[stats.id] = p


func _run_intro() -> void:
	phase = Phase.INTRO
	GameManager.set_flow(GameManager.Flow.INTRO)
	AudioManager.play_music(&"intro")
	hud.show_timer(false)
	_place_player(0)
	intro.play()
	await intro.finished
	phase = Phase.TUTORIAL
	pause_menu.can_pause = true
	tutorial.open("p1")
	await tutorial.confirmed
	_start_character_phase()


## Coloca o personagem do índice na posição inicial padrão (sem input ainda).
func _place_player(index: int) -> void:
	GameState.current_index = index
	player = _players[GameState.current_id()]
	player.spawn_at(level.marker("PlayerStart"))
	if index == 0 or level.barrels.config.respawn_each_phase:
		level.barrels.respawn()
	player.set_input_enabled(false)
	camera.set_target(player, true)
	hud.bind_player(player)
	hud.set_time(match_config.character_durations[index])
	hud.set_objective(Texts.ui("objective.p1" if index == 0 else "objective.p2"))


func _start_character_phase() -> void:
	var index := GameState.current_index
	_army_defeated = false
	_objectives_asked = false
	_can_advance = false
	hud.set_prompt("")
	phase = Phase.PLAYING
	GameManager.set_flow(GameManager.Flow.CHARACTER_1 if index == 0 else GameManager.Flow.CHARACTER_2)
	_time_left = match_config.character_durations[index]
	_timer_running = true
	hud.show_timer(true)
	hud.set_time(_time_left)
	hud.set_objective(Texts.ui("objective.p1" if index == 0 else "objective.p2"))
	player.set_input_enabled(true)
	interactions.begin_phase(index, player)
	AudioManager.play_music(&"gameplay")


func _physics_process(delta: float) -> void:
	if phase == Phase.BOSS:
		_update_revive_prompt()
		return
	if phase != Phase.PLAYING or not _timer_running:
		return
	if match_config.pause_timer_during_dialogue and interactions.is_busy():
		return
	_time_left -= delta
	hud.set_time(_time_left)
	if _time_left <= 0.0:
		_timer_running = false
		_on_time_up()


## Avisos do caído e revive na luta final.
func _update_revive_prompt() -> void:
	var text := ""
	var other := boss_director.helper
	if other and is_instance_valid(other) and not other.dead:
		if player.downed:
			text = Texts.ui("hud.downed_self", {"name": Texts.character_name(other.stats.id), "time": ceili(player.downed_left)})
		elif other.downed:
			var params := {"name": Texts.character_name(other.stats.id), "key": Settings.get_binding_text(Actions.INTERACT),
				"time": ceili(other.downed_left)}
			text = Texts.ui("hud.revive_prompt" if player.revive_target() else "hud.downed_ally", params)
	hud.set_prompt(text)


func _on_time_up() -> void:
	if GameState.current_index == 0:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_switch_to_second(false)
	else:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_start_boss()


# --- Exército ---

func _on_army_choice(choice: StringName) -> void:
	var id := GameState.current_id()
	var loop := GameState.current_index == 0 and match_config.p1_alliance_loops
	AudioManager.play_sfx(&"fight_start")
	if choice == InteractionDirector.CHOICE_ALLY:
		level.camp.set_decor_visible(true)
		encounter.start(ArmyEncounter.Mode.ALLIANCE, loop)
		hud.show_banner(Texts.ui("banner.allied_title"), Texts.ui("banner.allied_subtitle", {"name": Texts.character_name(id)}))
		hud.set_objective(Texts.ui("objective.allied"))
	else:
		level.camp.set_decor_visible(false)
		encounter.start(ArmyEncounter.Mode.CONFRONT, false)
		hud.show_banner(Texts.ui("banner.confront_title"), Texts.ui("banner.confront_subtitle"))
		hud.set_objective(Texts.ui("objective.confront"))
	_update_pois()


func _on_wave_started(index: int, total: int) -> void:
	if encounter.mode == ArmyEncounter.Mode.ALLIANCE:
		hud.show_banner(Texts.ui("banner.knights"), "")
	elif total > 1:
		hud.show_banner(Texts.ui("banner.wave", {"n": index + 1, "total": total}), "")


func _on_enemy_killed(enemy: Enemy) -> void:
	if encounter.mode == ArmyEncounter.Mode.CONFRONT and enemy.stats.counts_for_heroism:
		ReputationState.register_kill(GameState.current_id())


func _on_encounter_cleared() -> void:
	AudioManager.play_sfx(&"fight_end")
	if phase != Phase.PLAYING:
		return
	if encounter.last_mode == ArmyEncounter.Mode.CONFRONT:
		_army_defeated = true
	hud.show_banner(Texts.ui("banner.cleared"), "")
	hud.set_objective(Texts.ui("objective.after_fight"))
	_check_objectives()


# --- Objetivos completos (7.1) ---

## P1: todos os moradores resolvidos E exército derrotado. P2: exército derrotado.
## Só para quem NÃO se aliou; a pergunta aparece uma vez.
func _check_objectives() -> void:
	if phase != Phase.PLAYING or _objectives_asked or interactions.is_busy():
		return
	var id := GameState.current_id()
	if ReputationState.is_allied(id) or not _army_defeated:
		return
	if GameState.current_index == 0 and not interactions.all_houses_resolved():
		return
	_objectives_asked = true
	@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
	_ask_advance()


func _ask_advance() -> void:
	var path := "objectives.p1" if GameState.current_index == 0 else "objectives.p2"
	var choice: StringName = await interactions.ask(Texts.text("dialogues", "objectives.speaker"),
		Texts.text("dialogues", path), [
			{"id": &"advance", "label": Texts.text("dialogues", "choices.advance")},
			{"id": &"explore", "label": Texts.text("dialogues", "choices.explore")}])
	if phase != Phase.PLAYING:
		return
	if choice == &"advance":
		_advance_stage()
	elif choice == &"explore":
		_can_advance = true
		hud.set_prompt(Texts.ui("hud.advance_prompt", {"key": Settings.get_binding_text(Actions.ADVANCE)}))


## Vai para a próxima etapa sem esperar o tempo.
func _advance_stage() -> void:
	_can_advance = false
	hud.set_prompt("")
	if GameState.current_index == 0:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_switch_to_second(false)
	else:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_start_boss()


func _unhandled_input(event: InputEvent) -> void:
	if _can_advance and phase == Phase.PLAYING and not interactions.is_busy() and event.is_action_pressed(Actions.ADVANCE):
		get_viewport().set_input_as_handled()
		_advance_stage()


# --- Troca de personagem e morte ---

func _switch_to_second(first_died: bool) -> void:
	phase = Phase.SWITCHING
	_timer_running = false
	pause_menu.can_pause = false
	interactions.cancel()
	encounter.stop()
	player.set_input_enabled(false)
	var first_id := GameState.p1_id()
	if first_died:
		# GDD 4.2: inimigos mais fortes para o personagem seguinte.
		encounter.health_multiplier = match_config.death_enemy_health_multiplier
		encounter.damage_multiplier = match_config.death_enemy_damage_multiplier
		encounter.visual_scale = match_config.death_enemy_scale
		tombstone.show_for(first_id, ui_config.tombstone_duration)
		await tombstone.closed
	else:
		hud.show_banner(Texts.ui("banner.time_up"), "")
	await GameManager.fade_out()
	pools.clear_combat()
	player.deactivate()
	await _play_cutscene(switch_cutscene)
	_place_player(1)
	interactions.prepare_world_for(1)
	_update_pois()
	await GameManager.fade_in()
	var subtitle := Texts.ui("banner.enemies_stronger") if first_died else Texts.ui("banner.p2_subtitle")
	hud.show_banner(Texts.character_name(GameState.p2_id()), subtitle)
	phase = Phase.TUTORIAL
	pause_menu.can_pause = true
	tutorial.open("p2")
	await tutorial.confirmed
	_start_character_phase()


## Toca uma cutscene (se configurada) com a tela já escura; o fade abre por cima dela.
func _play_cutscene(cutscene: IntroConfig) -> void:
	if cutscene == null:
		return
	intro.play(cutscene)
	await GameManager.fade_in()
	await intro.finished
	await GameManager.fade_out()


func _on_player_died(who: Player) -> void:
	if who.boss_profile:
		return # O personagem-boss é tratado pelo BossDirector.
	var id := who.stats.id
	GameState.mark_dead(id)
	if who != player:
		# Ajudante caiu na luta do boss.
		hud.show_banner(Texts.ui("banner.helper_down", {"name": Texts.character_name(id)}), "")
		return
	match phase:
		Phase.PLAYING:
			if GameState.current_index == 0:
				@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
				_switch_to_second(true)
			else:
				@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
				_finish_after_death(id)
		Phase.BOSS:
			var for_army := boss_director.setup_data.player_fights_for_army if boss_director.setup_data \
				else ReputationState.is_allied(id)
			GameState.record_final_fight(false, for_army)
			@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
			_finish_after_death(id)
		_:
			# Morte durante transição: só registra; o fluxo atual segue.
			pass


func _finish_after_death(id: StringName) -> void:
	phase = Phase.ENDED
	_timer_running = false
	pause_menu.can_pause = false
	interactions.cancel()
	encounter.stop()
	tombstone.show_for(id, ui_config.tombstone_duration)
	await tombstone.closed
	GameManager.go_to_conclusion()


# --- Boss ---

func _start_boss() -> void:
	if phase == Phase.BOSS or phase == Phase.ENDED:
		return
	phase = Phase.BOSS
	_timer_running = false
	pause_menu.can_pause = false
	GameManager.set_flow(GameManager.Flow.BOSS)
	interactions.cancel()
	interactions.disable_all_pois()
	encounter.stop()
	player.set_input_enabled(false)
	var p1 := GameState.p1_id()
	var p2 := GameState.p2_id()
	var data := BossSelector.select(p1, p2, GameState.is_alive(p1), GameState.is_alive(p2),
		ReputationState.is_allied(p1), ReputationState.is_allied(p2))
	if _time_left <= 0.0:
		hud.show_banner(Texts.ui("banner.time_up"), "")
	await GameManager.fade_out()
	pools.clear_combat()
	for p: Player in _players.values():
		p.deactivate()
	# Escolha de personagem (só nos casos da regra 6.4).
	if data.choice:
		var stats_by_id := {}
		for s: CharacterStats in match_config.characters:
			stats_by_id[s.id] = s
		character_choice.open(data.choice_options, stats_by_id)
		# O fade abre sem esperar: um clique durante o fade já vale como escolha.
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		GameManager.fade_in()
		var picked: StringName = await character_choice.chosen
		AudioManager.play_sfx(&"ui_click")
		data.apply_choice(picked)
		await GameManager.fade_out()
	await _play_cutscene(boss_cutscene)
	# GDD 4.2: se o P1 morreu, o boss também vem mais forte.
	player = boss_director.start(data, _players, level, match_config,
		encounter.health_multiplier, encounter.damage_multiplier)
	camera.set_target(player, true)
	hud.bind_player(player)
	hud.show_timer(false)
	hud.set_objective(Texts.ui("objective.boss"))
	var health := boss_director.boss_health()
	hud.show_boss(boss_director.boss_display_name(), boss_director.boss_node, health.current, health.max_health)
	_update_pois()
	AudioManager.play_music(&"boss")
	await GameManager.fade_in()
	var subtitle := Texts.ui("banner.boss_switched", {"name": Texts.character_name(data.player_id)}) \
		if data.control_switched else Texts.ui("banner.boss_subtitle")
	hud.show_banner(boss_director.boss_display_name(), subtitle)
	AudioManager.play_sfx(&"boss_start")
	pause_menu.can_pause = true
	boss_director.begin_fight()


func _on_boss_defeated() -> void:
	if phase != Phase.BOSS:
		return
	phase = Phase.ENDED
	pause_menu.can_pause = false
	var data := boss_director.setup_data
	GameState.record_final_fight(true, data.player_fights_for_army)
	if data.kind == BossSelector.Kind.CHARACTER:
		GameState.mark_defeated(data.boss_character_id)
	player.set_input_enabled(false)
	hud.hide_boss()
	AudioManager.play_sfx(&"boss_defeated")
	var cfg := juice.config
	Juice.time_scale(cfg.boss_kill_time_scale, cfg.boss_kill_slowmo)
	Juice.shake_custom(cfg.shake_boss_strength, cfg.shake_boss_duration)
	Juice.zoom_punch(cfg.zoom_boss)
	hud.show_banner(Texts.ui("banner.victory"), "")
	await get_tree().create_timer(cfg.boss_kill_slowmo + 1.2, false, false, true).timeout
	GameManager.go_to_conclusion()


func _update_pois() -> void:
	var targets: Array[Node2D] = []
	for house: VillagerHouse in level.get_houses():
		targets.append(house)
	targets.append(level.camp)
	if boss_director.boss_node:
		targets.append(boss_director.boss_node)
	hud.poi_arrows.set_targets(targets)
