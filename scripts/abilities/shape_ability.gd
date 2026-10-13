class_name ShapeAbility
extends Ability
## Ataque de área com forma (retângulo, triângulo ou círculo), desenhado por código.
## Hoje só faz o básico: a forma aparece na frente do personagem, na direção da mira.
##
## TODO (habilidades da Princesa, seção 5.1 do briefing):
##  - Q, corte com dash: a hitbox triangular avança junto com o personagem
##    (dica: em active_physics(), chame caster.set_forced_velocity(...)).
##  - E, corte giratório: círculo que gira ao redor do personagem
##    (dica: um novo modo em AttackHitbox._update_transform()).
##  - R, grande corte: um retângulo grande (só configurar um .tres novo).

enum Shape { RECT, TRIANGLE, CIRCLE }

@export_group("Forma")
@export var shape: Shape = Shape.RECT
## RECT: comprimento x largura. TRIANGLE: comprimento x base. CIRCLE: x = raio.
@export var size: Vector2 = Vector2(70, 60)
## Distância do centro da forma até o lançador, na direção da mira.
@export var forward_offset: float = 50.0
## A hitbox acompanha o lançador enquanto está ativa.
@export var follow_caster: bool = true


func begin_active(caster: AbilityCaster) -> void:
	var pool := Pools.get_pool(&"hitboxes")
	if pool == null:
		return
	var hitbox := pool.acquire() as AttackHitbox
	if hitbox:
		hitbox.activate(self, caster)
		caster.track(hitbox)


func end_active(caster: AbilityCaster) -> void:
	caster.release_tracked()


func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, tint: Color) -> void:
	canvas.draw_set_transform(aim * forward_offset, aim.angle(), Vector2.ONE)
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
