extends PlayerState
## Morte (ou derrota, quando é um personagem-boss): cai e escurece.

var _tween: Tween


func enter(_msg: Dictionary) -> void:
	player.visual.play(&"dead")
	AudioManager.play_sfx(&"death")
	var cfg := Juice.cfg()
	if cfg:
		Juice.burst(cfg.particles_death, player.global_position, player.stats.body_color)
		Juice.shake(Ability.JuiceLevel.HEAVY)
	if _tween:
		_tween.kill()
	_tween = player.create_tween().set_parallel(true)
	if player.boss_profile:
		# Derrotado (não morto): ajoelha.
		_tween.tween_property(player.visual, "scale", Vector2(1.2, 0.7), 0.4)
		_tween.tween_property(player.visual, "modulate", Color(0.6, 0.6, 0.7), 0.4)
	else:
		_tween.tween_property(player.visual, "rotation", PI * 0.5, 0.35).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		_tween.tween_property(player.visual, "modulate", Color(0.4, 0.35, 0.5, 0.8), 0.6)


func exit() -> void:
	if _tween:
		_tween.kill()


func physics_update(delta: float) -> void:
	player.movement.stop(delta)
