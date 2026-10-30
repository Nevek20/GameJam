class_name ShockwaveAbility
extends Ability
## Dano em área parado: anéis que expandem a partir dos pés do boss, em ondas.
## Telegraph: círculo do alcance máximo enchendo. Fase ativa = (waves - 1) * wave_interval + expand_time.

@export_group("Onda de choque")
@export var radius: float = 230.0
## Espessura do anel que causa dano.
@export var ring_thickness: float = 40.0
## Tempo para o anel ir do centro até o raio máximo.
@export var expand_time: float = 0.35
@export var waves: int = 2
@export var wave_interval: float = 0.5
@export var ring_color: Color = Color(1, 0.4, 0.45, 1)


func begin_active(caster: AbilityCaster) -> void:
	for w in waves:
		caster.cast_state[w] = {}
	var cfg := Juice.cfg()
	if cfg:
		Juice.shake(Ability.JuiceLevel.HEAVY)
		Juice.burst(cfg.particles_death, caster.actor.global_position, ring_color)


func active_physics(caster: AbilityCaster, _delta: float) -> void:
	var k := caster.geometry_scale
	var t := caster.phase_elapsed()
	var center := caster.actor.global_position
	for w in waves:
		var r := _radius_at(t - w * wave_interval) * k
		if r <= 0.0:
			continue
		var hit_set: Dictionary = caster.cast_state.get(w, {})
		AreaDamage.hit_ring(self, caster, center, maxf(r - ring_thickness * k, 0.0), r, hit_set)


func _radius_at(local_t: float) -> float:
	if local_t < 0.0 or local_t > expand_time:
		return 0.0
	return radius * local_t / maxf(expand_time, 0.01)


func has_active_visual() -> bool:
	return true


func draw_active(canvas: CanvasItem, _aim: Vector2, _progress: float) -> void:
	var c := canvas as AbilityCaster
	if c == null:
		return
	var k := c.geometry_scale
	var feet := c.feet_offset()
	var t := c.phase_elapsed()
	for w in waves:
		var r := _radius_at(t - w * wave_interval) * k
		if r > 0.0:
			canvas.draw_arc(feet, r, 0.0, TAU, 64, Color(ring_color, 0.9), ring_thickness * k * 0.5)
			canvas.draw_arc(feet, r, 0.0, TAU, 64, Color(1, 1, 1, 0.8), 3.0)


func draw_telegraph(canvas: CanvasItem, _aim: Vector2, progress: float, tint: Color) -> void:
	var c := canvas as AbilityCaster
	var k := AbilityCaster.scale_of(canvas)
	var feet := c.feet_offset() if c else Vector2.ZERO
	canvas.draw_circle(feet, radius * k, Color(tint, 0.12))
	canvas.draw_circle(feet, radius * k * progress, Color(tint, 0.22))
	canvas.draw_arc(feet, radius * k, 0.0, TAU, 64, Color(tint, 0.85), 3.0)
