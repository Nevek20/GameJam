class_name LeapSlamAbility
extends Ability
## "Desaparece e cai": o boss some, uma sombra segue o jogador, trava, enche um círculo
## de aviso e o boss cai causando dano em área. Depois fica vulnerável (recuperação).
## A anticipação = follow_time + warn_time (o campo windup não é usado aqui).

@export_group("Desaparece e cai")
## Tempo em que a sombra segue o alvo.
@export var follow_time: float = 1.6
## Velocidade da sombra (pixels por segundo).
@export var follow_speed: float = 420.0
## Depois de travar: tempo do aviso (círculo enchendo) antes do impacto.
@export var warn_time: float = 0.7
## Raio do dano da queda.
@export var impact_radius: float = 140.0
@export var shadow_color: Color = Color(0.05, 0.0, 0.1, 0.55)


func get_windup(_caster: AbilityCaster) -> float:
	return follow_time + warn_time


func windup_physics(caster: AbilityCaster, delta: float) -> void:
	var actor := caster.actor
	if not caster.cast_state.has(&"vanished"):
		caster.cast_state[&"vanished"] = true
		if actor.has_method(&"set_vanished"):
			actor.call(&"set_vanished", true)
		var cfg := Juice.cfg()
		if cfg:
			Juice.burst(cfg.particles_spawn, actor.global_position, Color(0.3, 0.1, 0.4))
	if caster.phase_elapsed() < follow_time and caster.target and is_instance_valid(caster.target):
		actor.global_position = actor.global_position.move_toward(caster.target.global_position,
			follow_speed * caster.geometry_scale * delta)


func begin_active(caster: AbilityCaster) -> void:
	_reappear(caster)
	AreaDamage.hit_ring(self, caster, caster.actor.global_position, 0.0, impact_radius * caster.geometry_scale, {})
	var cfg := Juice.cfg()
	if cfg:
		Juice.shake(Ability.JuiceLevel.ULTIMATE)
		Juice.zoom_punch(cfg.zoom_boss)
		Juice.burst(cfg.particles_death, caster.actor.global_position, color)
	AudioManager.play_sfx(&"boss_slam")


func cancel(caster: AbilityCaster) -> void:
	_reappear(caster)


func _reappear(caster: AbilityCaster) -> void:
	if caster.cast_state.get(&"vanished", false):
		caster.cast_state[&"vanished"] = false
		if caster.actor.has_method(&"set_vanished"):
			caster.actor.call(&"set_vanished", false)


func draw_telegraph(canvas: CanvasItem, _aim: Vector2, _progress: float, tint: Color) -> void:
	var c := canvas as AbilityCaster
	if c == null:
		return
	var k := c.geometry_scale
	var feet := c.feet_offset()
	var r := impact_radius * k
	var t := c.phase_elapsed()
	canvas.draw_set_transform(feet, 0.0, Vector2(1.0, 0.6))
	canvas.draw_circle(Vector2.ZERO, r * 0.6, shadow_color)
	if t >= follow_time:
		# Travou: aviso enchendo até o impacto.
		var warn := clampf((t - follow_time) / maxf(warn_time, 0.01), 0.0, 1.0)
		canvas.draw_circle(Vector2.ZERO, r * warn, Color(tint, 0.35))
		canvas.draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, Color(tint, 0.95), 4.0)
	else:
		canvas.draw_arc(Vector2.ZERO, r, 0.0, TAU, 64, Color(tint, 0.4), 2.0)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
