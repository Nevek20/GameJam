class_name Game
extends Node2D
## Tela 2: orquestra a fase única (a vila).
## Introdução -> Tutorial -> Personagem 1 -> Personagem 2 -> (TODO: Boss) -> Conclusão.
## Lê/escreve GameState e ReputationState; avisa o GameManager das etapas do fluxo.

enum Phase { INTRO, TUTORIAL, PLAYING, SWITCHING, ENDED }

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


func _ready() -> void:
	if match_config == null:
		match_config = GameManager.match_config
	# Permite abrir game.tscn direto no editor (F6) sem passar pelo menu.
	if GameState.character_ids.is_empty():
		var ids := GameManager.character_ids()
		GameState.reset(ids)
		ReputationState.reset(ids)
	camera.set_bounds(level.bounds)
	camera.set_smoothing(juice.config.camera_smoothing)
	interactions.setup(match_config, dialog, qte, level.get_houses(), level.camp)
	interactions.army_choice_made.connect(_on_army_choice)
	encounter.setup(match_config, level.camp.get_spawn_points())
	encounter.enemy_killed.connect(_on_enemy_killed)
	encounter.encounter_cleared.connect(_on_encounter_cleared)
	encounter.wave_started.connect(_on_wave_started)
	_create_players()
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
		_start_boss()


# --- Exército ---

func _on_army_choice(choice: StringName) -> void:
	var id := GameState.current_id()
	AudioManager.play_sfx(&"fight_start")
	if choice == InteractionDirector.CHOICE_ALLY:
		# TODO (seção 4.3): aliado pode saquear a vila livremente e cavaleiros do reino
		# aparecem para impedi-lo. Hoje só marca a aliança (ReputationState) e mostra o aviso.
		hud.show_banner(Texts.ui("banner.allied_title"), Texts.ui("banner.allied_subtitle", {"name": Texts.character_name(id)}))
		hud.set_objective(Texts.ui("objective.allied"))
	else:
		level.camp.set_decor_visible(false)
		encounter.start()
		hud.show_banner(Texts.ui("banner.confront_title"), Texts.ui("banner.confront_subtitle"))
		hud.set_objective(Texts.ui("objective.confront"))


func _on_wave_started(index: int, total: int) -> void:
	if total > 1:
		hud.show_banner(Texts.ui("banner.wave", {"n": index + 1, "total": total}), "")


func _on_enemy_killed(enemy: Enemy) -> void:
	if enemy.stats.counts_for_heroism:
		ReputationState.register_kill(GameState.current_id())


func _on_encounter_cleared() -> void:
	AudioManager.play_sfx(&"fight_end")
	if phase != Phase.PLAYING:
		return
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
		tombstone.show_for(first_id, ui_config.tombstone_duration)
		await tombstone.closed
	else:
		hud.show_banner(Texts.ui("banner.time_up"), "")
	await GameManager.fade_out()
	pools.clear_combat()
	player.deactivate()
	# P2 sempre começa do início do mapa.
	_place_player(1)
	interactions.prepare_world_for(1)
	await GameManager.fade_in()
	hud.show_banner(Texts.character_name(GameState.p2_id()), Texts.ui("banner.p2_subtitle"))
	phase = Phase.TUTORIAL
	pause_menu.can_pause = true
	tutorial.open("p2")
	await tutorial.confirmed
	_start_character_phase()


func _on_player_died(who: Player) -> void:
	var id := who.stats.id
	GameState.mark_dead(id)
	if who != player or phase != Phase.PLAYING:
		return
	if GameState.current_index == 0:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_switch_to_second(true)
	else:
		@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
		_finish_after_death(id)


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

## TODO (seção 4.5): luta final.
##  - Escolher o boss pela regra fixa (criar uma função pura, ex.: BossSelector.select()):
##    a) ninguém aliado: P2 x cavaleiro do reino com skin do exército; P1 vivo ajuda (IA).
##    b) só um aliado: quem não se aliou enfrenta o aliado (aliado = boss com o próprio moveset).
##    c) ambos aliados: P2 x cavaleiro do reino, final de aliança dupla.
##  - Ao terminar, chamar GameState.record_final_fight(venceu, lutou_pelo_exército)
##    e, se o aliado perdeu, GameState.mark_defeated(id).
## Por enquanto o jogo vai direto para a conclusão.
func _start_boss() -> void:
	if phase == Phase.ENDED:
		return
	phase = Phase.ENDED
	_timer_running = false
	pause_menu.can_pause = false
	interactions.cancel()
	encounter.stop()
	player.set_input_enabled(false)
	hud.show_banner(Texts.ui("banner.time_up"), "")
	GameManager.go_to_conclusion()
