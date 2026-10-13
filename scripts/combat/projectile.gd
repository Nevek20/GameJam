class_name Projectile
extends HitboxComponent
## Projétil redondo do pool, com brilho. Some ao bater no cenário ou no alcance máximo.

var ability: ProjectileAbility
var caster: AbilityCaster

var _velocity: Vector2 = Vector2.ZERO
var _traveled: float = 0.0
var _pierce_left: int = 0
var _impacting: bool = false
var _circle := CircleShape2D.new()
var _impact_tween: Tween

@onready var _collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	super()
	body_entered.connect(_on_body_entered)
	_collision.shape = _circle


func launch(projectile_ability: ProjectileAbility, by: AbilityCaster, from: Vector2, direction: Vector2) -> void:
	ability = projectile_ability
	caster = by
	set_team(by.team, Layers.PROJECTILE, Layers.WORLD)
	reset_hits()
	active = true
	_impacting = false
	_traveled = 0.0
	_pierce_left = projectile_ability.pierce
	_velocity = direction * projectile_ability.speed
	_circle.radius = projectile_ability.radius
	global_position = from
	rotation = direction.angle()
	scale = Vector2(1.25, 0.85)
	modulate = Color.WHITE
	queue_redraw()


func on_pool_release() -> void:
	active = false
	ability = null
	caster = null
	if _impact_tween:
		_impact_tween.kill()


func _physics_process(delta: float) -> void:
	if ability == null or _impacting:
		return
	global_position += _velocity * delta
	_traveled += ability.speed * delta
	if _traveled >= ability.max_range:
		_impact()


func _deliver(hurtbox: HurtboxComponent) -> bool:
	var hit := ability.make_hit(caster, _velocity.normalized())
	hit.hit_position = global_position
	if not hurtbox.receive_hit(hit):
		return false
	_pierce_left -= 1
	if _pierce_left < 0:
		_impact.call_deferred()
	return true


func _on_body_entered(_body: Node2D) -> void:
	if active and not _impacting:
		_impact.call_deferred()


## Pouso: estouro de partículas e squash antes de sumir.
func _impact() -> void:
	if _impacting or ability == null:
		return
	_impacting = true
	active = false
	var c := Juice.cfg()
	if c:
		Juice.burst(c.particles_hit, global_position, ability.color, -_velocity.normalized())
	var squash := c.squash_impact if c and c.squash_enabled else Vector2.ONE
	if _impact_tween:
		_impact_tween.kill()
	_impact_tween = create_tween().set_parallel(true)
	_impact_tween.tween_property(self, "scale", squash, 0.09)
	_impact_tween.tween_property(self, "modulate:a", 0.0, 0.09)
	_impact_tween.chain().tween_callback(_release)


func _draw() -> void:
	if ability == null:
		return
	var r := ability.radius
	draw_circle(Vector2.ZERO, r * ability.glow_scale, Color(ability.color, 0.18))
	draw_circle(Vector2.ZERO, r * (1.0 + (ability.glow_scale - 1.0) * 0.5), Color(ability.color, 0.4))
	draw_circle(Vector2.ZERO, r, ability.color)
	draw_circle(Vector2(r * 0.2, 0), r * 0.5, Color(1, 1, 1, 0.9))


func _release() -> void:
	ObjectPool.release_node(self)
