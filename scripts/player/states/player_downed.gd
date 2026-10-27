extends PlayerState
## Caído: no chão esperando o parceiro reviver. Se o tempo acabar, morre (Player.finish_death).

var _tween: Tween


func enter(_msg: Dictionary) -> void:
	player.velocity = Vector2.ZERO
	player.visual.play(&"dead")
	AudioManager.play_sfx(&"downed")
	if _tween:
		_tween.kill()
	_tween = player.create_tween().set_parallel(true)
	_tween.tween_property(player.visual, "rotation", PI * 0.5, 0.3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	_tween.tween_property(player.visual, "modulate", Color(0.7, 0.7, 0.8, 0.9), 0.3)
	player.revive_ring.show()


func exit() -> void:
	if _tween:
		_tween.kill()
	player.visual.rotation = 0.0
	player.visual.modulate = Color.WHITE
	player.revive_ring.hide()


func physics_update(delta: float) -> void:
	player.movement.stop(delta)
	player.revive_ring.queue_redraw()
