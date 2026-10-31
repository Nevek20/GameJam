class_name Barrel
extends StaticBody2D
## Barril destrutível (pool). Recebe dano de ataques e habilidades dos heróis;
## ao quebrar pode soltar uma poção (BarrelConfig.drop_chance).

signal destroyed(barrel: Barrel)

var config: BarrelConfig
var _broken_tween: Tween

@onready var visual: EntityVisual = $Visual
@onready var health: HealthComponent = $Health
@onready var hurtbox: HurtboxComponent = $Hurtbox
@onready var _collision: CollisionShape2D = $CollisionShape2D
@onready var _hurt_shape: CollisionShape2D = $Hurtbox/CollisionShape2D


func _ready() -> void:
	hurtbox.hit_received.connect(_on_hit)
	health.died.connect(_on_died)


func activate(cfg: BarrelConfig, pos: Vector2) -> void:
	config = cfg
	global_position = pos
	collision_layer = Layers.WORLD
	collision_mask = 0
	# Lado "inimigo": só os ataques dos heróis acertam o barril.
	hurtbox.set_team(Team.Faction.FOES)
	hurtbox.enabled = true
	health.setup(cfg.max_health)
	visual.apply_look(cfg.texture, null, cfg.body_color, cfg.band_color, PlaceholderShape.Accent.NONE,
		Vector2.ONE * cfg.texture_scale, Barrel.base_offset(cfg.texture))
	visual.placeholder.secondary_color = cfg.band_color
	var k := GameScale.of(GameScale.Kind.SCENERY)
	(_collision.shape as RectangleShape2D).size = cfg.collision_size * k
	_collision.position = Vector2(0, -cfg.collision_size.y * k * 0.5)
	(_hurt_shape.shape as RectangleShape2D).size = cfg.body_size * k
	hurtbox.position = Vector2(0, -cfg.body_size.y * k * 0.5)
	visual.placeholder.size = cfg.body_size
	visual.placeholder.position = Vector2(0, -cfg.body_size.y * 0.5)
	visual.base_scale = Vector2.ONE * k
	visual.reset_effects()


func _on_hit(hit: HitData) -> void:
	var applied := health.take_damage(hit.damage)
	visual.flash()
	var cfg := Juice.cfg()
	if cfg:
		visual.squash(cfg.squash_hurt)
		Juice.damage_number(hurtbox.global_position, applied, cfg.color_damage_dealt, false)
		Juice.burst(cfg.particles_hit, hurtbox.global_position, config.body_color, hit.direction)
	AudioManager.play_sfx(config.sfx_hit)


func _on_died() -> void:
	hurtbox.enabled = false
	var cfg := Juice.cfg()
	if cfg:
		Juice.burst(cfg.particles_death, hurtbox.global_position, config.body_color)
		Juice.shake(Ability.JuiceLevel.LIGHT)
	AudioManager.play_sfx(config.sfx_break)
	if randf() < config.drop_chance:
		_drop_potion.call_deferred(global_position)
	destroyed.emit(self)
	# Adiado: estamos dentro do callback de dano.
	if config.broken_texture:
		_show_broken.call_deferred()
	else:
		_release.call_deferred()


## Mostra o barril quebrado (sem colisão) e some aos poucos.
func _show_broken() -> void:
	collision_layer = 0
	visual.apply_look(config.broken_texture, null, config.body_color, config.band_color, PlaceholderShape.Accent.NONE,
		Vector2.ONE * config.texture_scale, Barrel.base_offset(config.broken_texture))
	_broken_tween = create_tween()
	_broken_tween.tween_interval(maxf(config.broken_time - 0.4, 0.0))
	_broken_tween.tween_property(visual, "modulate:a", 0.0, 0.4)
	_broken_tween.tween_callback(_release)


func on_pool_release() -> void:
	if _broken_tween:
		_broken_tween.kill()


func _release() -> void:
	ObjectPool.release_node(self)


## Offset para a base do desenho ficar nos pés do nó (pixels da textura).
static func base_offset(tex: Texture2D) -> Vector2:
	return Vector2(0, -tex.get_height() * 0.5) if tex else Vector2.ZERO


func _drop_potion(pos: Vector2) -> void:
	var pool := Pools.get_pool(&"potions")
	if pool == null:
		return
	var potion := pool.acquire() as Potion
	if potion:
		potion.activate(config, pos)
