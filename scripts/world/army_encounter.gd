class_name ArmyEncounter
extends Node
## Ondas de inimigos. Enfrentar: exército (próxima onda quando a anterior acaba).
## Aliar-se: cavaleiros do reino chegam por intervalo (em loop para o Personagem 1).

signal wave_started(index: int, total: int)
signal encounter_cleared
signal enemy_killed(enemy: Enemy)

enum Mode { NONE, CONFRONT, ALLIANCE }

var mode: Mode = Mode.NONE
var config: MatchConfig
## Fortalecimento dos inimigos (o Game liga quando o Personagem 1 morre).
var health_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var visual_scale: float = 1.0

var _army_points: Array[Vector2] = []
var _knight_points: Array[Vector2] = []
var _waves: Array[WaveData] = []
var _wave_index: int = -1
var _loop: bool = false
var _alive: int = 0
var _queue: Array[EnemyStats] = []
var _queue_points: Array[Vector2] = []

@onready var _timer: Timer = $WaveTimer


func _ready() -> void:
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer)


func setup(match_config: MatchConfig, army_points: Array[Vector2], knight_points: Array[Vector2]) -> void:
	config = match_config
	_army_points = army_points
	_knight_points = knight_points


func start(new_mode: Mode, loop: bool) -> void:
	stop()
	mode = new_mode
	_loop = loop
	_waves = config.confront_waves if new_mode == Mode.CONFRONT else config.alliance_waves
	_wave_index = -1
	if _waves.is_empty():
		encounter_cleared.emit.call_deferred()
		return
	_schedule_next()


func stop() -> void:
	mode = Mode.NONE
	_timer.stop()
	_queue.clear()
	_queue_points.clear()
	_alive = 0
	var pool := Pools.get_pool(&"enemies")
	if pool:
		pool.release_all()


func is_running() -> bool:
	return mode != Mode.NONE


func alive_count() -> int:
	return _alive


func _schedule_next() -> void:
	var next := _wave_index + 1
	if next >= _waves.size():
		if _loop:
			next = 0
		else:
			return
	_timer.start(maxf(_waves[next].delay_before, 0.05))


func _on_timer() -> void:
	if mode == Mode.NONE:
		return
	_wave_index += 1
	if _wave_index >= _waves.size():
		_wave_index = 0
	_spawn_wave(_waves[_wave_index])
	wave_started.emit(_wave_index, _waves.size())
	# Aliança: os cavaleiros chegam por tempo, não esperam a onda anterior acabar.
	if mode == Mode.ALLIANCE and (_loop or _wave_index < _waves.size() - 1):
		_timer.start(config.alliance_wave_interval)


func _spawn_wave(wave: WaveData) -> void:
	var points := _army_points if mode == Mode.CONFRONT else _knight_points
	if points.is_empty():
		push_warning("ArmyEncounter: sem pontos de surgimento")
		return
	for i in wave.primary_count:
		_queue_enemy(wave.primary_enemy, points.pick_random(), wave.spawn_spread)
	for i in wave.elite_count:
		_queue_enemy(wave.elite_enemy, points.pick_random(), wave.spawn_spread)
	# Inimigos rápidos chegam em grupos, cada grupo num ponto.
	for g in wave.fast_groups:
		var point: Vector2 = points.pick_random()
		for i in wave.fast_group_size:
			_queue_enemy(wave.fast_enemy, point, wave.fast_group_spread)
	_flush_queue()


func _queue_enemy(stats: EnemyStats, point: Vector2, spread: float) -> void:
	if stats == null:
		return
	_queue.append(stats)
	_queue_points.append(point + Vector2(randf_range(-spread, spread), randf_range(-spread, spread)))


## Respeita o limite de inimigos ativos; o resto entra quando houver vaga.
func _flush_queue() -> void:
	var pool := Pools.get_pool(&"enemies")
	if pool == null:
		return
	while not _queue.is_empty() and _alive < config.max_active_enemies:
		var stats: EnemyStats = _queue.pop_front()
		var point: Vector2 = _queue_points.pop_front()
		var enemy := pool.acquire() as Enemy
		if enemy == null:
			break
		if not enemy.died.is_connected(_on_enemy_died):
			enemy.died.connect(_on_enemy_died)
		enemy.activate(stats, point, null, health_multiplier, damage_multiplier, visual_scale)
		_alive += 1


func _on_enemy_died(enemy: Enemy) -> void:
	if mode == Mode.NONE:
		return
	_alive = maxi(_alive - 1, 0)
	enemy_killed.emit(enemy)
	if not _queue.is_empty():
		_flush_queue()
		return
	if _alive > 0:
		return
	var last_wave := _wave_index >= _waves.size() - 1
	if mode == Mode.CONFRONT:
		if last_wave and not _loop:
			mode = Mode.NONE
			encounter_cleared.emit()
		else:
			_schedule_next()
	elif last_wave and not _loop and _timer.is_stopped():
		mode = Mode.NONE
		encounter_cleared.emit()
