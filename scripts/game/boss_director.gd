class_name BossDirector
extends Node
## Monta a luta final a partir do BossSelector (regra pura) e avisa o resultado.

signal boss_defeated
signal control_changed(player: Player)

@export var boss_scene: PackedScene

var setup_data: BossSelector.Setup
var boss_node: Node2D
var helper: Player
var human: Player
var _knight: Boss


## players: id -> Player. Retorna o personagem controlado pelo jogador na luta.
func start(data: BossSelector.Setup, players: Dictionary, level: Level, config: MatchConfig) -> Player:
	setup_data = data
	human = players[data.player_id]
	human.spawn_at(level.marker("ArenaPlayer"))
	human.set_input_enabled(false)
	if data.control_switched:
		control_changed.emit(human)
	match data.kind:
		BossSelector.Kind.CHARACTER:
			var boss_player: Player = players[data.boss_character_id]
			var ai := AIController.new()
			ai.profile = boss_player.stats.ai_profile
			boss_player.setup(boss_player.stats, Team.Faction.FOES, ai, config.character_boss_profile)
			boss_player.spawn_at(level.marker("ArenaBoss"))
			boss_player.set_input_enabled(false)
			if not boss_player.died.is_connected(_on_boss_down):
				boss_player.died.connect(_on_boss_down)
			boss_node = boss_player
		_:
			if _knight == null:
				_knight = boss_scene.instantiate() as Boss
				level.actors.add_child(_knight)
				_knight.died.connect(_on_boss_down)
			_knight.activate_boss(config.knight_boss, level.marker("ArenaBoss"),
				data.kind == BossSelector.Kind.KNIGHT_ARMY_SKIN)
			_knight.state_machine.transition_to(&"Roar", {"duration": config.knight_boss.phase_change_duration})
			boss_node = _knight
	if data.helper_id != &"":
		helper = players[data.helper_id]
		var helper_ai := AIController.new()
		helper_ai.profile = helper.stats.ai_profile
		helper.setup(helper.stats, Team.Faction.HEROES, helper_ai)
		helper.spawn_at(level.marker("ArenaHelper"))
	return human


## Libera os personagens/IA para lutar (depois do fade e do anúncio).
func begin_fight() -> void:
	human.set_input_enabled(true)
	var boss_player := boss_node as Player
	if boss_player:
		boss_player.set_input_enabled(true)


func boss_display_name() -> String:
	if setup_data.kind == BossSelector.Kind.CHARACTER:
		return Texts.character_name(setup_data.boss_character_id)
	return Texts.character_name(_knight.display_name_key())


func boss_health() -> HealthComponent:
	var boss_player := boss_node as Player
	if boss_player:
		return boss_player.health
	return _knight.health


func _on_boss_down(_who: Node) -> void:
	boss_defeated.emit()
