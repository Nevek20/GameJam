extends PlayerState


func enter(_msg: Dictionary) -> void:
	player.visual.play(&"move")


func physics_update(delta: float) -> void:
	if try_actions():
		return
	var dir := player.controller.get_move_vector()
	if dir == Vector2.ZERO:
		machine.transition_to(&"Idle")
		return
	player.movement.move(dir, 1.0, delta)
