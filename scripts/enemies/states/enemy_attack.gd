extends EnemyState
## Ataque com telegraph (a mira trava no início da anticipação, dá para desviar).

var _ability: Ability
var _was_active: bool = false


func enter(msg: Dictionary) -> void:
	_ability = msg.get("ability") as Ability
	_was_active = false
	var dir: Vector2 = msg.get("direction", Vector2.RIGHT)
	if _ability == null or not enemy.caster.cast(_ability, dir):
		return
	enemy.visual.play(&"attack")
	AudioManager.play_sfx(&"enemy_attack")


func exit() -> void:
	if enemy.caster.is_casting():
		enemy.caster.interrupt()
	enemy.attack_cooldown_left = enemy.current_attack_interval() * randf_range(0.8, 1.2)


func physics_update(delta: float) -> void:
	if not enemy.caster.is_casting():
		machine.transition_to(&"Chase")
		return
	var active := enemy.caster.phase == AbilityCaster.Phase.ACTIVE
	if active and not _was_active:
		var cfg := Juice.cfg()
		if cfg:
			enemy.visual.squash(cfg.squash_attack)
	_was_active = active
	# Dash de ataque: a direção segue o alvo no telegraph e trava no fim dele.
	if enemy.caster.is_aim_tracking() and enemy.has_valid_target():
		enemy.caster.set_aim(enemy.global_position.direction_to(enemy.target.global_position))
		enemy.caster.queue_redraw()
	if enemy.caster.has_forced_velocity():
		enemy.movement.move_with_velocity(enemy.caster.get_forced_velocity())
	else:
		enemy.movement.stop(delta)
