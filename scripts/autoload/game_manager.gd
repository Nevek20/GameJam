extends Node
## Máquina de estados do fluxo do jogo:
## Menu -> Introdução/Tutorial -> Personagem 1 -> Personagem 2 -> (Boss) -> Conclusão -> Créditos.
## Só troca telas (com fade) e guarda em que etapa estamos. Sem lógica de gameplay.

signal flow_changed(from: Flow, to: Flow)

enum Flow { BOOT, MENU, INTRO, CHARACTER_1, CHARACTER_2, BOSS, CONCLUSION, CREDITS }

const SCENE_MENU := "res://ui/menu/main_menu.tscn"
const SCENE_GAME := "res://scenes/game/game.tscn"
const SCENE_CONCLUSION := "res://ui/endings/conclusion.tscn"
const SCENE_CREDITS := "res://ui/credits/credits_screen.tscn"
const MATCH_CONFIG_PATH := "res://resources/config/match_config.tres"
const JUICE_CONFIG_PATH := "res://resources/config/juice_config.tres"
const FADE_SCENE := preload("res://ui/transition/screen_fade.tscn")

var flow: Flow = Flow.BOOT
var match_config: MatchConfig
var _fade: ScreenFade
var _changing: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	match_config = load(MATCH_CONFIG_PATH) as MatchConfig
	var juice := load(JUICE_CONFIG_PATH) as JuiceConfig
	_fade = FADE_SCENE.instantiate() as ScreenFade
	if juice:
		_fade.duration = juice.fade_duration
	add_child(_fade)
	var scene := get_tree().current_scene
	if scene and scene.scene_file_path == SCENE_MENU:
		flow = Flow.MENU


func character_ids() -> Array[StringName]:
	var ids: Array[StringName] = []
	for stats: CharacterStats in match_config.characters:
		ids.append(stats.id)
	return ids


func start_new_game() -> void:
	var ids := character_ids()
	GameState.reset(ids)
	ReputationState.reset(ids)
	@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
	_change_scene(SCENE_GAME, Flow.INTRO)


func go_to_menu() -> void:
	@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
	_change_scene(SCENE_MENU, Flow.MENU)


func go_to_conclusion() -> void:
	@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
	_change_scene(SCENE_CONCLUSION, Flow.CONCLUSION)


func go_to_credits() -> void:
	@warning_ignore("missing_await") # dispara a corrotina sem esperar (intencional)
	_change_scene(SCENE_CREDITS, Flow.CREDITS)


## Etapas dentro da cena de jogo (sem trocar de cena).
func set_flow(next: Flow) -> void:
	if next == flow:
		return
	var previous := flow
	flow = next
	flow_changed.emit(previous, next)


func is_changing_scene() -> bool:
	return _changing


func fade_out() -> void:
	await _fade.fade_out()


func fade_in() -> void:
	await _fade.fade_in()


func _change_scene(path: String, next: Flow) -> void:
	if _changing:
		return
	_changing = true
	await _fade.fade_out()
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().change_scene_to_file(path)
	set_flow(next)
	# A troca de cena acontece no fim do frame.
	await get_tree().process_frame
	await get_tree().process_frame
	_changing = false
	await _fade.fade_in()
