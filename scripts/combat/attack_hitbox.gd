class_name AttackHitbox
extends HitboxComponent
## Hitbox temporária (do pool) com a forma de um ShapeAbility.
## A colisão e o desenho são independentes do sprite do personagem.

var ability: ShapeAbility
var caster: AbilityCaster

var _rect := RectangleShape2D.new()
var _circle := CircleShape2D.new()
var _poly := ConvexPolygonShape2D.new()
var _origin: Vector2
var _dir: Vector2 = Vector2.RIGHT
var _orbit_angle: float = 0.0
var _elapsed: float = 0.0
## Lado do golpe (SWING): alterna a cada ataque, como golpes de ida e volta.
var _swing_sign: float = 1.0
static var _next_swing_sign: float = 1.0

@onready var _collision: CollisionShape2D = $CollisionShape2D


func activate(shape_ability: ShapeAbility, by: AbilityCaster) -> void:
	ability = shape_ability
	caster = by
	set_team(by.team)
	rehit_interval = shape_ability.rehit_interval
	reset_hits()
	active = true
	_elapsed = 0.0
	_origin = by.global_position
	_dir = by.aim_dir
	_orbit_angle = _dir.angle()
	if shape_ability.style == ShapeAbility.Style.SWING:
		_swing_sign = _next_swing_sign
		_next_swing_sign = -_next_swing_sign
	# Área não é corpo físico: escalar o nó escala colisão e desenho juntos.
	scale = Vector2.ONE * by.geometry_scale
	match shape_ability.shape:
		ShapeAbility.Shape.RECT:
			_rect.size = shape_ability.size
			_collision.shape = _rect
		ShapeAbility.Shape.CIRCLE:
			_circle.radius = shape_ability.size.x
			_collision.shape = _circle
		ShapeAbility.Shape.TRIANGLE:
			_poly.points = ShapeAbility.triangle_points(shape_ability.size)
			_collision.shape = _poly
	_update_transform(0.0)
	queue_redraw()


func on_pool_release() -> void:
	active = false
	ability = null
	caster = null
	reset_hits()


func _physics_process(delta: float) -> void:
	if ability == null:
		return
	_elapsed += delta
	_update_transform(delta)
	super(delta)
	queue_redraw()


func _update_transform(delta: float) -> void:
	var origin := caster.global_position if ability.follow_caster else _origin
	if ability.orbit_radius > 0.0:
		_orbit_angle += deg_to_rad(ability.orbit_speed) * delta
		var offset := Vector2.from_angle(_orbit_angle) * ability.orbit_radius * caster.geometry_scale
		global_position = origin + offset
		rotation = _orbit_angle + PI * 0.5
		return
	if ability.follow_aim:
		_dir = caster.aim_dir
	global_position = origin + _dir * ability.forward_offset * caster.geometry_scale
	rotation = _dir.angle()


func _deliver(hurtbox: HurtboxComponent) -> bool:
	var dir := _dir
	if ability.orbit_radius > 0.0 or ability.shape == ShapeAbility.Shape.CIRCLE:
		dir = caster.global_position.direction_to(hurtbox.global_position)
	var hit := ability.make_hit(caster, dir)
	hit.hit_position = hurtbox.global_position
	return hurtbox.receive_hit(hit)


func _draw() -> void:
	if ability == null:
		return
	var t := clampf(_elapsed / maxf(ability.active_time, 0.001), 0.0, 1.0)
	var col := ability.color
	match ability.style:
		ShapeAbility.Style.SLASH:
			# Rápido e brilhante no começo, some no fim.
			ability.draw_local(self, Color(col, col.a * (1.0 - t * 0.8)), true)
			ability.draw_local_scaled(self, Color(1, 1, 1, 0.6 * (1.0 - t)), 0.55)
		ShapeAbility.Style.SOLID:
			ability.draw_local(self, Color(col, col.a * 0.8), true)
			ability.draw_local(self, Color(1, 1, 1, 0.8), false, 2.0)
		ShapeAbility.Style.SWING:
			_draw_swing(t, col)
		ShapeAbility.Style.BEAM:
			var pulse := 0.85 + 0.15 * sin(_elapsed * 40.0)
			ability.draw_local_scaled(self, Color(col, 0.35), pulse)
			draw_rect(Rect2(Vector2(-ability.size.x * 0.5, -ability.size.y * 0.22 * pulse), Vector2(ability.size.x, ability.size.y * 0.44 * pulse)), Color(col, 0.85))
			draw_rect(Rect2(Vector2(-ability.size.x * 0.5, -ability.size.y * 0.08), Vector2(ability.size.x, ability.size.y * 0.16)), Color(1, 1, 1, 0.95))


## Arco de espada: meia-lua em volta do lançador (que fica forward_offset atrás do centro da forma).
## A ponta varre de um lado ao outro; o rastro afina para trás e some no fim do golpe.
func _draw_swing(t: float, col: Color) -> void:
	var pivot := Vector2(-ability.forward_offset, 0.0)
	var outer := ability.forward_offset + ability.size.x * 0.5
	var inner := maxf(outer - ability.size.x * 0.8, 8.0)
	var half := clampf(atan2(ability.size.y * 0.5, maxf(ability.forward_offset, 1.0)), 0.7, 1.35)
	var head := lerpf(-half, half, 1.0 - pow(1.0 - minf(t * 1.5, 1.0), 3.0))
	var tail := maxf(-half, head - half * 1.7)
	if head - tail < 0.04:
		return
	var fade := 1.0 - smoothstep(0.55, 1.0, t)
	var steps := 16
	var edge := PackedVector2Array()
	var crescent := PackedVector2Array()
	for i in steps + 1:
		var a := lerpf(tail, head, float(i) / steps) * _swing_sign
		edge.append(pivot + Vector2.from_angle(a) * outer)
	crescent.append_array(edge)
	for i in range(steps, -1, -1):
		var k := float(i) / steps
		var a := lerpf(tail, head, k) * _swing_sign
		# Grosso na ponta (lâmina), fino no rastro.
		crescent.append(pivot + Vector2.from_angle(a) * lerpf(outer, inner, k * k))
	draw_colored_polygon(crescent, Color(col, col.a * 0.7 * fade))
	draw_polyline(edge, Color(1, 1, 1, 0.9 * fade), 3.0, true)
