extends EnemyState
## Morte: partículas, encolhe e volta ao pool.

var _tween: Tween


func enter(_msg: Dictionary) -> void:
	enemy.velocity = Vector2.ZERO
	enemy.visual.play(&"dead")
	AudioManager.play_sfx(&"death")
	var cfg := Juice.cfg()
	if cfg and enemy.skin:
		Juice.burst(cfg.particles_death, enemy.global_position, enemy.skin.body_color)
	if _tween:
		_tween.kill()
	_tween = enemy.create_tween()
	if enemy.has_meta(&"pool"):
		_tween.set_parallel(true)
		_tween.tween_property(enemy.visual, "scale", Vector2(1.6, 0.1), 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		_tween.tween_property(enemy.visual, "modulate:a", 0.0, 0.25)
		_tween.chain().tween_callback(_release)
	else:
		_tween.tween_property(enemy.visual, "rotation", PI * 0.5, 0.5).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
		_tween.parallel().tween_property(enemy.visual, "modulate", Color(0.4, 0.4, 0.5, 0.85), 0.8)


func exit() -> void:
	if _tween:
		_tween.kill()


func physics_update(delta: float) -> void:
	enemy.movement.stop(delta)


func _release() -> void:
	ObjectPool.release_node(enemy)
