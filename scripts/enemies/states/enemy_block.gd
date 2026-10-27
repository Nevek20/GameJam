extends EnemyState
## Guarda erguida da elite: reduz o dano e contra-ataca ao baixar a guarda.

var _time_left: float


func enter(_msg: Dictionary) -> void:
	_time_left = enemy.stats.block_duration
	enemy.guard.show_guard(enemy.stats.body_radius)
	enemy.guard.set_parry_window(false)
	enemy.visual.play(&"block")


func exit() -> void:
	enemy.guard.hide_guard()
	enemy.block_cooldown_left = enemy.stats.block_cooldown


func physics_update(delta: float) -> void:
	enemy.movement.stop(delta)
	_time_left -= delta
	if _time_left > 0.0:
		return
	if enemy.has_valid_target():
		var dir := enemy.global_position.direction_to(enemy.target.global_position)
		var ability := enemy.choose_attack(enemy.global_position.distance_to(enemy.target.global_position))
		if ability:
			machine.transition_to(&"Attack", {"ability": ability, "direction": dir})
			return
	machine.transition_to(&"Chase")
