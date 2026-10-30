class_name ProjectileAbility
extends Ability
## Dispara projéteis redondos do pool (disparo de mana, bola de fogo, ondas do boss).

@export_group("Projétil")
@export var radius: float = 8.0
@export var speed: float = 640.0
@export var max_range: float = 620.0
## Quantos alvos atravessa antes de sumir (0 = some no primeiro).
@export var pierce: int = 0
@export var spawn_offset: float = 24.0
## Tamanho do brilho em volta do núcleo.
@export var glow_scale: float = 2.2
## Vários projéteis em leque.
@export var count: int = 1
@export var spread_degrees: float = 0.0
## Estouro de área ao colidir (0 = sem área).
@export var impact_radius: float = 0.0


func begin_active(caster: AbilityCaster) -> void:
	var pool := Pools.get_pool(&"projectiles")
	if pool == null:
		return
	var total := maxi(count, 1)
	for i in total:
		var offset := 0.0
		if total > 1:
			offset = deg_to_rad(lerpf(-spread_degrees * 0.5, spread_degrees * 0.5, float(i) / float(total - 1)))
		var dir := caster.aim_dir.rotated(offset)
		var projectile := pool.acquire() as Projectile
		if projectile:
			projectile.launch(self, caster, caster.global_position + dir * spawn_offset * caster.geometry_scale, dir)


func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, tint: Color) -> void:
	var k := AbilityCaster.scale_of(canvas)
	var length := minf(max_range, 360.0) * k
	var total := maxi(count, 1)
	for i in total:
		var offset := 0.0
		if total > 1:
			offset = deg_to_rad(lerpf(-spread_degrees * 0.5, spread_degrees * 0.5, float(i) / float(total - 1)))
		var dir := aim.rotated(offset)
		canvas.draw_line(Vector2.ZERO, dir * length, Color(tint, 0.25), radius * 1.2 * k)
		canvas.draw_line(Vector2.ZERO, dir * length * progress, Color(tint, 0.7), 2.0)
	canvas.draw_circle(aim * spawn_offset * k, radius * k * (0.5 + progress), Color(tint, 0.8))
