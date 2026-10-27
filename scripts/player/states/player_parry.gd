class_name PlayerParryState
extends PlayerState
## Defesa (segurar) com janela curta de parry no início.
## Parry: anula o golpe, atordoa o atacante e dá uma reação forte de feedback.

var _elapsed: float = 0.0


func enter(_msg: Dictionary) -> void:
	_elapsed = 0.0
	player.guard.show_guard(player.stats.body_size)
	player.guard.set_parry_window(true)
	player.visual.play(&"parry")
	AudioManager.play_sfx(&"parry")


func exit() -> void:
	player.guard.hide_guard()
	player.parry_cooldown_left = player.stats.parry_cooldown


func physics_update(delta: float) -> void:
	_elapsed += delta
	var window := player.stats.parry_window
	player.guard.set_parry_window(_elapsed <= window)
	if _elapsed >= window and not player.controller.is_held(Actions.PARRY):
		go_idle_or_move()
		return
	player.movement.move(player.controller.get_move_vector(), player.stats.block_move_multiplier, delta)


## Retorna true se o golpe foi aparado (sem dano).
func try_parry(hit: HitData) -> bool:
	if _elapsed > player.stats.parry_window or not hit.parryable:
		return false
	var stats := player.stats
	if hit.source and is_instance_valid(hit.source) and hit.source.has_method(&"on_parried"):
		hit.source.call(&"on_parried", player, stats.parry_stun, stats.parry_knockback)
	player.invulnerable_left = 0.25
	player.guard.parry_flash()
	player.visual.flash(Color(1, 0.9, 0.5))
	AudioManager.play_sfx(&"parry_success")
	var cfg := Juice.cfg()
	if cfg:
		Juice.hit_stop(cfg.hitstop_parry)
		Juice.zoom_punch(cfg.zoom_parry)
		Juice.shake(Ability.JuiceLevel.HEAVY)
		Juice.burst(cfg.particles_parry, player.caster.global_position - hit.direction * player.stats.body_size.x * player.size_scale * 0.5, Color(1, 0.85, 0.3), -hit.direction)
	player.notify_parried()
	# Recompensa: o parry seguinte fica disponível logo.
	_elapsed = 0.0
	return true
