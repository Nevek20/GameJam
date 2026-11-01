extends EnemyState
## Voa em volta do alvo (Olho seco e Siameses).
## ORBIT_DASH: depois de girar um tempo, ataca com o dash (DashAttackAbility, com telegraph).
## ORBIT_WALL: só gira; o grupo nasce junto e gira no mesmo sentido, formando um arco-parede.

var _angle: float = 0.0
var _dash_left: float = 0.0


func enter(_msg: Dictionary) -> void:
	enemy.visual.play(&"move")
	var s := enemy.stats
	_dash_left = randf_range(s.orbit_time_min, maxf(s.orbit_time_max, s.orbit_time_min))
	if enemy.has_valid_target():
		_angle = enemy.target.global_position.angle_to_point(enemy.global_position)


func physics_update(delta: float) -> void:
	enemy.attack_cooldown_left -= delta
	if not enemy.has_valid_target():
		enemy.target = enemy.find_target()
		if enemy.target == null:
			machine.transition_to(&"Idle")
			return
		_angle = enemy.target.global_position.angle_to_point(enemy.global_position)
	var s := enemy.stats
	var center := enemy.target.global_position
	var turn := 1.0 if s.behavior == EnemyStats.Behavior.ORBIT_WALL else enemy.orbit_sign
	_angle = wrapf(_angle + deg_to_rad(s.orbit_speed) * turn * delta, -PI, PI)
	var goal := center + Vector2.from_angle(_angle) * s.orbit_radius * enemy.size_scale
	var to_goal := goal - enemy.global_position
	var dist := to_goal.length()
	# Desacelera perto do ponto da órbita para não tremer.
	var speed := clampf(dist / 40.0, 0.0, 1.0) * enemy.speed_factor(center.distance_to(enemy.global_position))
	enemy.movement.move(enemy.steer(to_goal / maxf(dist, 0.001), delta), speed, delta)
	enemy.visual.face(center - enemy.global_position)

	if s.behavior != EnemyStats.Behavior.ORBIT_DASH:
		return
	_dash_left -= delta
	if _dash_left > 0.0 or enemy.attack_cooldown_left > 0.0:
		return
	var to := center - enemy.global_position
	var ability := enemy.choose_attack(to.length())
	if ability:
		machine.transition_to(&"Attack", {"ability": ability, "direction": to.normalized()})
