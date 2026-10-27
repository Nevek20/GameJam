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
		var offset := Vector2.from_angle(_orbit_angle) * ability.orbit_radius
		global_position = origin + offset
		rotation = _orbit_angle + PI * 0.5
		return
	if ability.follow_aim:
		_dir = caster.aim_dir
	global_position = origin + _dir * ability.forward_offset
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
		ShapeAbility.Style.BEAM:
			var pulse := 0.85 + 0.15 * sin(_elapsed * 40.0)
			ability.draw_local_scaled(self, Color(col, 0.35), pulse)
			draw_rect(Rect2(Vector2(-ability.size.x * 0.5, -ability.size.y * 0.22 * pulse), Vector2(ability.size.x, ability.size.y * 0.44 * pulse)), Color(col, 0.85))
			draw_rect(Rect2(Vector2(-ability.size.x * 0.5, -ability.size.y * 0.08), Vector2(ability.size.x, ability.size.y * 0.16)), Color(1, 1, 1, 0.95))
