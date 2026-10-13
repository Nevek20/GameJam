class_name ArmyEncounter
extends Node
## Ondas de inimigos ao enfrentar o exército (próxima onda quando a anterior acaba).
## TODO (seção 4.3): modo "aliado", em que cavaleiros do reino chegam por tempo.

signal wave_started(index: int, total: int)
signal encounter_cleared
signal enemy_killed(enemy: Enemy)

var config: MatchConfig
var running: bool = false
## Fortalecimento dos inimigos (o Game liga quando o Personagem 1 morre).
var health_multiplier: float = 1.0
var damage_multiplier: float = 1.0
var visual_scale: float = 1.0

var _spawn_points: Array[Vector2] = []
var _wave_index: int = -1
var _alive: int = 0
var _queue: Array[EnemyStats] = []
var _queue_points: Array[Vector2] = []

@onready var _timer: Timer = $WaveTimer


func _ready() -> void:
	_timer.one_shot = true
	_timer.timeout.connect(_on_timer)


func setup(match_config: MatchConfig, spawn_points: Array[Vector2]) -> void:
	config = match_config
	_spawn_points = spawn_points


func start() -> void:
	stop()
	running = true
	_wave_index = -1
	if config.confront_waves.is_empty():
		running = false
		encounter_cleared.emit.call_deferred()
		return
	_schedule_next()


func stop() -> void:
	running = false
	_timer.stop()
	_queue.clear()
	_queue_points.clear()
	_alive = 0
	var pool := Pools.get_pool(&"enemies")
	if pool:
		pool.release_all()


func _schedule_next() -> void:
	var next := _wave_index + 1
	if next >= config.confront_waves.size():
		running = false
		encounter_cleared.emit()
		return
	_timer.start(maxf(config.confront_waves[next].delay_before, 0.05))


func _on_timer() -> void:
	if not running:
		return
	_wave_index += 1
	var wave := config.confront_waves[_wave_index]
	for i in wave.count:
		if wave.enemy and not _spawn_points.is_empty():
			_queue.append(wave.enemy)
			_queue_points.append(_spawn_points.pick_random() + Vector2(randf_range(-60, 60), randf_range(-60, 60)))
	_flush_queue()
	wave_started.emit(_wave_index, config.confront_waves.size())


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
	if not running:
		return
	_alive = maxi(_alive - 1, 0)
	enemy_killed.emit(enemy)
	if not _queue.is_empty():
		_flush_queue()
	elif _alive == 0:
		_schedule_next()
