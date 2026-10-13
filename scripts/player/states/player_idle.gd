extends PlayerState


func enter(_msg: Dictionary) -> void:
	player.visual.play(&"idle")


func physics_update(delta: float) -> void:
	if try_actions():
		return
	if player.controller.get_move_vector() != Vector2.ZERO:
		machine.transition_to(&"Move")
		return
	player.movement.stop(delta)
