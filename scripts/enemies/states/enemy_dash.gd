extends EnemyState
## Dash da elite (avanço ou esquiva) com rastro.

var _velocity: Vector2
var _time_left: float
var _trail_left: float


func enter(msg: Dictionary) -> void:
	var s := enemy.stats
	var dir: Vector2 = msg.get("direction", Vector2.RIGHT)
	_velocity = dir * (s.dash_distance / maxf(s.dash_duration, 0.01))
	_time_left = s.dash_duration
	_trail_left = 0.0
	enemy.dash_cooldown_left = s.dash_cooldown
	enemy.visual.play(&"dash")
	AudioManager.play_sfx(&"dash")
	var cfg := Juice.cfg()
	if cfg:
		enemy.visual.squash(cfg.squash_dash)


func physics_update(delta: float) -> void:
	enemy.movement.move_with_velocity(_velocity)
	_trail_left -= delta
	var cfg := Juice.cfg()
	if _trail_left <= 0.0 and cfg and enemy.skin:
		_trail_left = cfg.trail_interval * 1.5
		Juice.afterimage(enemy.visual, enemy.skin.body_color)
	_time_left -= delta
	if _time_left <= 0.0:
		enemy.velocity = _velocity * 0.2
		machine.transition_to(&"Chase")
