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
var _elapsed: float = 0.0

@onready var _collision: CollisionShape2D = $CollisionShape2D


func activate(shape_ability: ShapeAbility, by: AbilityCaster) -> void:
	ability = shape_ability
	caster = by
	set_team(by.team)
	reset_hits()
	active = true
	_elapsed = 0.0
	_origin = by.global_position
	_dir = by.aim_dir
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
	_update_transform()
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
	_update_transform()
	queue_redraw()


func _update_transform() -> void:
	var origin := caster.global_position if ability.follow_caster else _origin
	global_position = origin + _dir * ability.forward_offset
	rotation = _dir.angle()


func _deliver(hurtbox: HurtboxComponent) -> bool:
	var hit := ability.make_hit(caster, _dir)
	hit.hit_position = hurtbox.global_position
	return hurtbox.receive_hit(hit)


func _draw() -> void:
	if ability == null:
		return
	# Brilhante no começo, some no fim da fase ativa.
	var t := clampf(_elapsed / maxf(ability.active_time, 0.001), 0.0, 1.0)
	var col := ability.color
	ability.draw_local(self, Color(col, col.a * (1.0 - t * 0.8)), true)
	ability.draw_local_scaled(self, Color(1, 1, 1, 0.6 * (1.0 - t)), 0.55)
