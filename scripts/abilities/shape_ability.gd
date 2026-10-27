class_name ShapeAbility
extends Ability
## Ataque de área com forma (retângulo, triângulo ou círculo), desenhado por código.
## Cobre: corte de espada, corte com dash (lunge), corte giratório (orbit),
## grande corte e o feixe do mago (rehit_interval = dano por tick).

enum Shape { RECT, TRIANGLE, CIRCLE }
enum Style { SLASH, SOLID, BEAM }

@export_group("Forma")
@export var shape: Shape = Shape.RECT
## RECT: comprimento x largura. TRIANGLE: comprimento x base. CIRCLE: x = raio.
@export var size: Vector2 = Vector2(70, 60)
## Distância do centro da forma até o lançador, na direção da mira.
@export var forward_offset: float = 50.0
@export var style: Style = Style.SLASH

@export_group("Comportamento")
## A hitbox acompanha o lançador.
@export var follow_caster: bool = true
## A hitbox gira junto com a mira enquanto ativa (feixe).
@export var follow_aim: bool = false
## O lançador avança esta distância durante a fase ativa (corte com dash).
@export var lunge_distance: float = 0.0
## Raio e velocidade (graus/s) de órbita ao redor do lançador (corte giratório).
@export var orbit_radius: float = 0.0
@export var orbit_speed: float = 0.0
## 0 = acerta cada alvo uma vez. > 0 = dano contínuo a cada X segundos.
@export var rehit_interval: float = 0.0


func begin_active(caster: AbilityCaster) -> void:
	var pool := Pools.get_pool(&"hitboxes")
	if pool == null:
		return
	var hitbox := pool.acquire() as AttackHitbox
	if hitbox:
		hitbox.activate(self, caster)
		caster.track(hitbox)


func active_physics(caster: AbilityCaster, _delta: float) -> void:
	if lunge_distance > 0.0 and active_time > 0.0:
		caster.set_forced_velocity(caster.aim_dir * (lunge_distance * caster.geometry_scale / active_time))


func end_active(caster: AbilityCaster) -> void:
	caster.release_tracked()


func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, tint: Color) -> void:
	var k := AbilityCaster.scale_of(canvas)
	if orbit_radius > 0.0:
		canvas.draw_arc(Vector2.ZERO, (orbit_radius + size.x) * k, 0.0, TAU, 48, Color(tint, 0.35), 4.0)
		canvas.draw_arc(Vector2.ZERO, (orbit_radius + size.x) * k, 0.0, TAU * progress, 48, Color(tint, 0.85), 4.0)
		return
	var reach := (forward_offset + lunge_distance) * k
	canvas.draw_set_transform(aim * reach, aim.angle(), Vector2.ONE * k)
	draw_local(canvas, Color(tint, 0.18), true)
	draw_local(canvas, Color(tint, 0.7), false, 2.0)
	draw_local_scaled(canvas, Color(tint, 0.35), progress)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


## Desenha a forma centrada na origem, apontando para +X.
func draw_local(canvas: CanvasItem, col: Color, filled: bool, width: float = -1.0) -> void:
	draw_local_scaled(canvas, col, 1.0, filled, width)


func draw_local_scaled(canvas: CanvasItem, col: Color, scale: float, filled: bool = true, width: float = -1.0) -> void:
	var s := size * scale
	match shape:
		Shape.RECT:
			canvas.draw_rect(Rect2(-s * 0.5, s), col, filled, width)
		Shape.CIRCLE:
			if filled:
				canvas.draw_circle(Vector2.ZERO, s.x, col)
			else:
				canvas.draw_arc(Vector2.ZERO, s.x, 0.0, TAU, 32, col, width)
		Shape.TRIANGLE:
			var pts := triangle_points(s)
			if filled:
				canvas.draw_colored_polygon(pts, col)
			else:
				canvas.draw_polyline(PackedVector2Array([pts[0], pts[1], pts[2], pts[0]]), col, width)


static func triangle_points(s: Vector2) -> PackedVector2Array:
	return PackedVector2Array([Vector2(s.x * 0.5, 0.0), Vector2(-s.x * 0.5, -s.y * 0.5), Vector2(-s.x * 0.5, s.y * 0.5)])
