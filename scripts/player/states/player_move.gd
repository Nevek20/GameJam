extends PlayerState


func enter(_msg: Dictionary) -> void:
	player.visual.play(&"move")
	if player.stats.id == &"mage":
		AudioManager.play_sfx(&"mage_run")


func exit() -> void:
	if player.stats.id == &"mage":
		AudioManager.stop_sfx(&"mage_run")


func physics_update(delta: float) -> void:
	if try_actions():
		return
	var dir := player.controller.get_move_vector()
	if dir == Vector2.ZERO:
		machine.transition_to(&"Idle")
		return
	player.movement.move(dir, 1.0, delta)
