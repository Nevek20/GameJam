class_name ChainAbility
extends Ability
## Raio estilo laser que encadeia para o próximo inimigo perto.
## Primeiro alvo: o mais próximo dentro do alcance e do cone da mira.

@export_group("Raio")
@export var first_range: float = 440.0
## Tolerância da mira (graus para cada lado).
@export var aim_cone_degrees: float = 30.0
## Distância máxima de cada salto.
@export var chain_range: float = 230.0
## Quantos saltos depois do primeiro alvo.
@export var max_jumps: int = 3
## Multiplicador de dano a cada salto.
@export var damage_falloff: float = 0.85
@export var line_width: float = 5.0
@export var line_lifetime: float = 0.25

var _points := PackedVector2Array()
var _hit_list: Array[HurtboxComponent] = []


func begin_active(caster: AbilityCaster) -> void:
	var tree := caster.get_tree()
	var k := caster.geometry_scale
	var origin := caster.global_position + caster.aim_dir * 18.0 * k
	var group := Team.hurtbox_group(Team.opposite(caster.team))
	var candidates := tree.get_nodes_in_group(group)
	_hit_list.clear()
	_points.clear()
	_points.append(origin)
	var current := _find_first(candidates, origin, caster.aim_dir, first_range * k)
	if current == null:
		_points.append(origin + caster.aim_dir * first_range * k)
		_spawn_line(caster)
		return
	var scale := 1.0
	var jumps := 0
	while current != null:
		_hit_list.append(current)
		_points.append(current.global_position)
		var prev: Vector2 = _points[_points.size() - 2]
		var hit := make_hit(caster, prev.direction_to(current.global_position), scale)
		hit.hit_position = current.global_position
		current.receive_hit(hit)
		if jumps >= max_jumps:
			break
		jumps += 1
		scale *= damage_falloff
		current = _find_next(candidates, current.global_position, chain_range * k)
	_spawn_line(caster)


func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, tint: Color) -> void:
	var length := first_range * AbilityCaster.scale_of(canvas)
	canvas.draw_line(Vector2.ZERO, aim * length, Color(tint, 0.2), 2.0)
	canvas.draw_line(Vector2.ZERO, aim * length * progress, Color(tint, 0.8), line_width)


func _find_first(candidates: Array[Node], origin: Vector2, aim: Vector2, max_dist: float) -> HurtboxComponent:
	var best: HurtboxComponent = null
	var best_dist := max_dist
	var cone := deg_to_rad(aim_cone_degrees)
	for node: Node in candidates:
		var hb := node as HurtboxComponent
		if hb == null or not hb.is_active():
			continue
		var to := hb.global_position - origin
		var dist := to.length()
		if dist > best_dist or absf(aim.angle_to(to)) > cone:
			continue
		best_dist = dist
		best = hb
	return best


func _find_next(candidates: Array[Node], from: Vector2, max_dist: float) -> HurtboxComponent:
	var best: HurtboxComponent = null
	var best_dist := max_dist
	for node: Node in candidates:
		var hb := node as HurtboxComponent
		if hb == null or not hb.is_active() or _hit_list.has(hb):
			continue
		var dist := from.distance_to(hb.global_position)
		if dist < best_dist:
			best_dist = dist
			best = hb
	return best


func _spawn_line(_caster: AbilityCaster) -> void:
	var pool := Pools.get_pool(&"lightning")
	if pool == null:
		return
	var line := pool.acquire() as LightningLine
	if line:
		line.show_chain(_points, color, line_width, line_lifetime)
	var preset := Juice.cfg().particles_skill if Juice.cfg() else null
	for i in range(1, _points.size()):
		Juice.burst(preset, _points[i], color)
