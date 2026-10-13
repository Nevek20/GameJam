extends EnemyState
## Persegue o alvo; decide atacar, dar dash (elite) ou defender (elite).

var _think_left: float = 0.0


func enter(_msg: Dictionary) -> void:
	_think_left = 0.0
	enemy.visual.play(&"move")


func physics_update(delta: float) -> void:
	enemy.attack_cooldown_left -= delta
	enemy.dash_cooldown_left -= delta
	enemy.block_cooldown_left -= delta
	if not enemy.has_valid_target():
		enemy.target = enemy.find_target()
		if enemy.target == null:
			machine.transition_to(&"Idle")
			return
	var to := enemy.target.global_position - enemy.global_position
	var dist := to.length()
	var dir := to / maxf(dist, 0.001)
	enemy.visual.face(dir)

	_think_left -= delta
	if _think_left <= 0.0:
		_think_left = enemy.stats.think_interval
		if _try_block(dist) or _try_dash(dir, dist):
			return

	if enemy.attack_cooldown_left <= 0.0:
		var ability := enemy.choose_attack(dist)
		if ability:
			machine.transition_to(&"Attack", {"ability": ability, "direction": dir})
			return

	# Para um pouco antes do alcance para não grudar no alvo.
	var stop_distance := enemy.max_attack_range() * 0.7
	var move_dir := dir if dist > stop_distance else Vector2.ZERO
	enemy.movement.move(move_dir, 1.0, delta)


func _try_block(dist: float) -> bool:
	var s := enemy.stats
	if s.block_chance <= 0.0 or enemy.block_cooldown_left > 0.0 or dist > 160.0:
		return false
	if not (enemy.target.has_method(&"is_attacking") and enemy.target.call(&"is_attacking")):
		return false
	if randf() >= s.block_chance:
		return false
	machine.transition_to(&"Block")
	return true


func _try_dash(dir: Vector2, dist: float) -> bool:
	var s := enemy.stats
	if s.dash_chance <= 0.0 or enemy.dash_cooldown_left > 0.0 or randf() >= s.dash_chance:
		return false
	# Longe: avança na diagonal. Perto: desvia para o lado.
	var side := dir.orthogonal() * (1.0 if randf() < 0.5 else -1.0)
	var dash_dir := (dir + side * 0.6).normalized() if dist > 200.0 else side
	machine.transition_to(&"Dash", {"direction": dash_dir})
	return true
