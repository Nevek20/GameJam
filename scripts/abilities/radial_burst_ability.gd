class_name RadialBurstAbility
extends ProjectileAbility
## Disparo em todas as direções: projéteis em círculo, em várias ondas.
## A fase ativa precisa durar pelo menos (waves - 1) * wave_interval.

@export_group("Disparo em círculo")
## Projéteis em cada onda (espalhados igualmente em 360 graus).
@export var per_wave: int = 12
@export var waves: int = 3
@export var wave_interval: float = 0.45
## Gira o círculo a cada onda (graus), para alternar os buracos entre as ondas.
@export var angle_step_per_wave: float = 15.0


func begin_active(caster: AbilityCaster) -> void:
	caster.cast_state[&"waves_fired"] = 0
	_fire_due(caster)


func active_physics(caster: AbilityCaster, _delta: float) -> void:
	_fire_due(caster)


func _fire_due(caster: AbilityCaster) -> void:
	var fired: int = caster.cast_state.get(&"waves_fired", 0)
	while fired < waves and caster.phase_elapsed() >= fired * wave_interval:
		_fire_wave(caster, fired)
		fired += 1
	caster.cast_state[&"waves_fired"] = fired


func _fire_wave(caster: AbilityCaster, wave: int) -> void:
	var pool := Pools.get_pool(&"projectiles")
	if pool == null:
		return
	var n := maxi(per_wave, 1)
	var base := deg_to_rad(angle_step_per_wave * wave)
	for i in n:
		var dir := Vector2.from_angle(base + TAU * float(i) / float(n))
		var projectile := pool.acquire() as Projectile
		if projectile:
			projectile.launch(self, caster, caster.global_position + dir * spawn_offset * caster.geometry_scale, dir)
	if sfx_cast != &"":
		AudioManager.play_sfx(sfx_cast)


## Telegraph: raios saindo do boss nas direções da primeira onda.
func draw_telegraph(canvas: CanvasItem, _aim: Vector2, progress: float, tint: Color) -> void:
	var k := AbilityCaster.scale_of(canvas)
	var n := maxi(per_wave, 1)
	var length := 160.0 * k * progress
	for i in n:
		var dir := Vector2.from_angle(TAU * float(i) / float(n))
		canvas.draw_line(dir * 30.0 * k, dir * (30.0 * k + length), Color(tint, 0.7), 3.0)
	canvas.draw_arc(Vector2.ZERO, 30.0 * k, 0.0, TAU, 32, Color(tint, 0.9), 3.0)
