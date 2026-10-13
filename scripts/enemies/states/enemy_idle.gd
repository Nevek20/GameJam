extends EnemyState
## Parado até encontrar um alvo no alcance de agressão.

var _think_left: float = 0.0


func enter(_msg: Dictionary) -> void:
	_think_left = randf() * enemy.stats.think_interval
	enemy.visual.play(&"idle")


func physics_update(delta: float) -> void:
	enemy.movement.stop(delta)
	_think_left -= delta
	if _think_left > 0.0:
		return
	_think_left = enemy.stats.think_interval
	enemy.target = enemy.find_target()
	if enemy.target:
		machine.transition_to(&"Chase")
