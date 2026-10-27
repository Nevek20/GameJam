class_name Game
extends Node2D
## Tela 2: orquestra a fase única (a vila).
## Introdução -> Tutorial -> Personagem 1 -> Personagem 2 -> Boss -> Conclusão.
## Lê/escreve GameState e ReputationState; avisa o GameManager das etapas do fluxo.

enum Phase { INTRO, TUTORIAL, PLAYING, SWITCHING, BOSS, ENDED }

@export var match_config: MatchConfig
@export var ui_config: UIConfig
@export var player_scene: PackedScene

var phase: Phase = Phase.INTRO
var player: Player
var _players: Dictionary = {}
var _time_left: float = 0.0
var _timer_running: bool = false

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
	for ui: Control in [hud, dialog, qte, tutorial, intro, tombstone, pause_menu]:
		GameScale.apply_ui(ui)
	camera.set_smoothing(juice.config.camera_smoothing)
	interactions.setup(match_config, dialog, qte, level.get_houses(), level.camp)
	interactions.army_choice_made.connect(_on_army_choice)
	encounter.setup(match_config, level.camp.get_spawn_points(), level.marker_group("KnightSpawns"))
	encounter.enemy_killed.connect(_on_enemy_killed)
	encounter.encounter_cleared.connect(_on_encounter_cleared)
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
	player.set_input_enabled(false)
	camera.set_target(player, true)
	hud.bind_player(player)
	hud.set_time(match_config.character_durations[index])
	hud.set_objective(Texts.ui("objective.p1" if index == 0 else "objective.p2"))


func _start_character_phase() -> void:
	var index := GameState.current_index
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
	if phase != Phase.PLAYING or not _timer_running:
		return
	if match_config.pause_timer_during_dialogue and interactions.is_busy():
		return
	_time_left -= delta
	hud.set_time(_time_left)
	if _time_left <= 0.0:
		_timer_running = false
		_on_time_up()


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
	if GameState.current_index == 1 and match_config.p2_boss_after_encounter:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_start_boss()
	else:
		hud.show_banner(Texts.ui("banner.cleared"), "")
		hud.set_objective(Texts.ui("objective.after_fight"))


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
			GameState.record_final_fight(false, boss_director.setup_data.player_fights_for_army)
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
	var data := BossSelector.select(p1, p2, GameState.is_alive(p1),
		ReputationState.is_allied(p1), ReputationState.is_allied(p2))
	if _time_left <= 0.0:
		hud.show_banner(Texts.ui("banner.time_up"), "")
	await GameManager.fade_out()
	pools.clear_combat()
	for p: Player in _players.values():
		p.deactivate()
	player = boss_director.start(data, _players, level, match_config)
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
