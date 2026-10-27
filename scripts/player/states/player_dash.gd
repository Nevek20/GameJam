extends PlayerState
## Dash na direção do input (ou da mira, se parado), com i-frames e rastro.

var _velocity: Vector2
var _time_left: float
var _trail_left: float


func enter(_msg: Dictionary) -> void:
	var stats := player.stats
	var dir := player.controller.get_move_vector()
	if dir == Vector2.ZERO:
		dir = player.aim_dir
	dir = dir.normalized()
	_velocity = dir * (stats.dash_distance * player.size_scale / maxf(stats.dash_duration, 0.01))
	_time_left = stats.dash_duration
	_trail_left = 0.0
	player.dash_cooldown_left = stats.dash_cooldown
	player.visual.play(&"dash")
	player.visual.face(dir)
	AudioManager.play_sfx(&"dash")
	var cfg := Juice.cfg()
	if cfg:
		player.visual.squash(cfg.squash_dash)
		Juice.shake_custom(cfg.shake_dash_strength, cfg.shake_dash_duration)
		Juice.burst(cfg.particles_dash, player.global_position, player.stats.body_color, -dir)


func physics_update(delta: float) -> void:
	player.movement.move_with_velocity(_velocity)
	_trail_left -= delta
	var cfg := Juice.cfg()
	if _trail_left <= 0.0 and cfg:
		_trail_left = cfg.trail_interval
		Juice.afterimage(player.visual, player.stats.body_color)
	_time_left -= delta
	if _time_left <= 0.0:
		player.velocity = _velocity * 0.25
		if not try_actions():
			go_idle_or_move()
