extends EnemyState
## Atordoado (golpe ou parry).

var _time_left: float
var _stunned: bool


func enter(msg: Dictionary) -> void:
	_time_left = float(msg.get("duration", enemy.stats.hurt_stun))
	_stunned = bool(msg.get("stunned", false))
	enemy.visual.play(&"hurt")
	var cfg := Juice.cfg()
	if cfg:
		enemy.visual.squash(cfg.squash_hurt)
	if _stunned:
		enemy.visual.modulate = Color(0.75, 0.75, 1.3)


func exit() -> void:
	if _stunned:
		enemy.visual.modulate = Color.WHITE


func physics_update(delta: float) -> void:
	enemy.movement.stop(delta)
	_time_left -= delta
	if _time_left <= 0.0:
		machine.transition_to(&"Chase" if enemy.has_valid_target() else &"Idle")
