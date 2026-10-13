extends EnemyState
## Pausa invencível do boss (entrada e troca de fase) com muito feedback.

var _time_left: float


func enter(msg: Dictionary) -> void:
	_time_left = float(msg.get("duration", 1.0))
	enemy.caster.interrupt()
	enemy.hurtbox.enabled = false
	enemy.visual.play(&"roar")
	AudioManager.play_sfx(&"boss_roar")
	var cfg := Juice.cfg()
	if cfg:
		Juice.shake_custom(cfg.shake_boss_strength, cfg.shake_boss_duration)
		Juice.zoom_punch(cfg.zoom_boss)
		if enemy.skin:
			Juice.burst(cfg.particles_skill, enemy.global_position, enemy.skin.body_color)
		enemy.visual.squash(Vector2(1.4, 0.7))


func exit() -> void:
	if not enemy.dead:
		enemy.hurtbox.enabled = true


func physics_update(delta: float) -> void:
	enemy.movement.stop(delta)
	_time_left -= delta
	if _time_left <= 0.0:
		machine.transition_to(&"Chase")
