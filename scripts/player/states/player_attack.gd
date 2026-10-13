extends PlayerState
## Executa uma habilidade. Na recuperação, dash ou outro ataque podem cancelar.

var _ability: Ability


func enter(msg: Dictionary) -> void:
	_ability = msg.get("ability") as Ability
	# Se não lançar, physics_update volta para Idle/Move no próximo frame.
	if _ability == null or not player.caster.cast(_ability, player.aim_dir):
		return
	player.visual.play(&"attack")
	var cfg := Juice.cfg()
	if cfg:
		player.visual.squash(cfg.squash_attack)
		if _ability.juice_level == Ability.JuiceLevel.ULTIMATE:
			Juice.shake(Ability.JuiceLevel.ULTIMATE)
			Juice.zoom_punch(cfg.zoom_ultimate)
			Juice.burst(cfg.particles_skill, player.global_position, _ability.color)
		elif _ability != player.stats.attack:
			Juice.burst(cfg.particles_skill, player.global_position, _ability.color, player.aim_dir)


func exit() -> void:
	if player.caster.is_casting():
		player.caster.interrupt()


func physics_update(delta: float) -> void:
	if not player.caster.is_casting():
		if not try_actions():
			go_idle_or_move()
		return
	if player.caster.can_cancel() and try_actions():
		return
	if player.caster.has_forced_velocity():
		player.movement.move_with_velocity(player.caster.get_forced_velocity())
	else:
		player.movement.move(player.controller.get_move_vector(), player.caster.current.move_multiplier, delta)
