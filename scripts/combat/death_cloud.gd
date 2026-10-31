class_name DeathCloud
extends Node2D
## Nuvem de dano (pool). Desenhada por código; o dano é por distância a cada tick (sem física).

var config: DeathCloudConfig
var team: Team.Faction = Team.Faction.FOES
var damage_multiplier: float = 1.0
var radius_scale: float = 1.0
var source: Node2D

var _elapsed: float = 0.0
var _tick_left: float = 0.0


func activate(cfg: DeathCloudConfig, pos: Vector2, side: Team.Faction, dmg_mult: float, size_scale: float,
		from: Node2D = null) -> void:
	config = cfg
	team = side
	damage_multiplier = dmg_mult
	radius_scale = size_scale
	source = from
	global_position = pos
	_elapsed = 0.0
	_tick_left = cfg.arm_delay
	modulate = Color.WHITE
	queue_redraw()


func _process(delta: float) -> void:
	if config == null:
		return
	_elapsed += delta
	if _elapsed >= config.duration:
		ObjectPool.release_node(self)
		return
	_tick_left -= delta
	if _tick_left <= 0.0:
		_tick_left = config.tick_interval
		_damage_tick()
	queue_redraw()


func _damage_tick() -> void:
	var r := config.radius * radius_scale
	var groups: Array[StringName] = [Team.hurtbox_group(Team.opposite(team))]
	if config.hurts_enemies:
		groups.append(Team.hurtbox_group(team))
	for group in groups:
		for node: Node in get_tree().get_nodes_in_group(group):
			var hurtbox := node as HurtboxComponent
			if hurtbox == null or not hurtbox.is_active():
				continue
			if hurtbox.global_position.distance_to(global_position) > r:
				continue
			var hit := HitData.new()
			hit.damage = config.damage_per_tick * damage_multiplier
			hit.direction = global_position.direction_to(hurtbox.global_position)
			hit.source = null
			# Time "neutro" para poder acertar os dois lados quando hurts_enemies = true.
			hit.team = team if group == groups[0] else Team.opposite(team)
			hit.parryable = false
			hit.hit_position = hurtbox.global_position
			hit.color = config.color
			hit.sfx_hit = config.sfx_tick
			hurtbox.receive_hit(hit)


func _draw() -> void:
	if config == null:
		return
	var r := config.radius * radius_scale
	var life := clampf(_elapsed / maxf(config.duration, 0.01), 0.0, 1.0)
	# Cresce rápido no começo e some no fim.
	var grow := minf(_elapsed / 0.25, 1.0)
	var fade := 1.0 - smoothstep(0.75, 1.0, life)
	var armed := _elapsed >= config.arm_delay
	var c := config.color
	for i in 4:
		var k := 1.0 - i * 0.18
		var wobble := Vector2(cos(_elapsed * 2.0 + i), sin(_elapsed * 1.7 + i * 2.0)) * r * 0.08
		draw_circle(wobble, r * k * grow, Color(c, c.a * 0.5 * fade))
	draw_arc(Vector2.ZERO, r * grow, 0.0, TAU, 48, Color(c.lightened(0.3), (0.9 if armed else 0.4) * fade), 2.0)
