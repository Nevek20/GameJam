extends EnemyState
## Persegue o alvo e ataca quando ele está no alcance.
## TODO (elite): decidir dash e defesa aqui, a cada think_interval.


func enter(_msg: Dictionary) -> void:
	enemy.visual.play(&"move")


func physics_update(delta: float) -> void:
	enemy.attack_cooldown_left -= delta
	if not enemy.has_valid_target():
		enemy.target = enemy.find_target()
		if enemy.target == null:
			machine.transition_to(&"Idle")
			return
	var to := enemy.target.global_position - enemy.global_position
	var dist := to.length()
	var dir := to / maxf(dist, 0.001)
	enemy.visual.face(dir)

	if enemy.attack_cooldown_left <= 0.0:
		var ability := enemy.choose_attack(dist)
		if ability:
			machine.transition_to(&"Attack", {"ability": ability, "direction": dir})
			return

	# Para um pouco antes do alcance para não grudar no alvo.
	var stop_distance := enemy.max_attack_range() * 0.7
	var move_dir := dir if dist > stop_distance else Vector2.ZERO
	enemy.movement.move(move_dir, 1.0, delta)
