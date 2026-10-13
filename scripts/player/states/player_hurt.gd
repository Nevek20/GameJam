extends PlayerState
## Atordoado por um instante após o golpe (o knockback é desfeito pelo atrito).

var _time_left: float


func enter(msg: Dictionary) -> void:
	_time_left = float(msg.get("duration", player.stats.hurt_stun))
	player.visual.play(&"hurt")
	var cfg := Juice.cfg()
	if cfg:
		player.visual.squash(cfg.squash_hurt)


func physics_update(delta: float) -> void:
	player.movement.stop(delta)
	_time_left -= delta
	if _time_left <= 0.0:
		go_idle_or_move()
