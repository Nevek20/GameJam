class_name Potion
extends Area2D
## Poção de cura (pool). O personagem coleta ao tocar.

var config: BarrelConfig
var _bob: Tween
var _life_left: float = 0.0
var _taken: bool = false

@onready var visual: EntityVisual = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	set_process(false)


func activate(cfg: BarrelConfig, pos: Vector2) -> void:
	config = cfg
	_taken = false
	global_position = pos
	collision_layer = 0
	collision_mask = Layers.PLAYER
	visual.apply_look(cfg.potion_texture, null, cfg.potion_color, cfg.potion_color, PlaceholderShape.Accent.NONE, Vector2.ONE)
	visual.placeholder.size = cfg.potion_size
	visual.placeholder.position = Vector2(0, -cfg.potion_size.y * 0.5 - 6.0)
	scale = Vector2.ONE * GameScale.of(GameScale.Kind.SCENERY)
	visual.position = Vector2.ZERO
	if _bob:
		_bob.kill()
	# Pulinho ao cair e flutuação suave.
	visual.squash(Vector2(0.6, 1.5))
	_bob = create_tween().set_loops()
	_bob.tween_property(visual, "position:y", -6.0, 0.5).set_trans(Tween.TRANS_SINE)
	_bob.tween_property(visual, "position:y", 0.0, 0.5).set_trans(Tween.TRANS_SINE)
	_life_left = cfg.potion_lifetime
	set_process(cfg.potion_lifetime > 0.0)


func on_pool_release() -> void:
	if _bob:
		_bob.kill()
	set_process(false)


func _process(delta: float) -> void:
	_life_left -= delta
	if _life_left <= 0.0:
		_release()


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if _taken or player == null or player.dead or player.team != Team.Faction.HEROES:
		return
	_taken = true
	var amount := player.health.max_health * config.heal_percent if config.heal_is_percent else config.heal_amount
	var before := player.health.current
	player.health.heal(amount)
	Juice.heal_number(player.hurtbox.global_position, player.health.current - before)
	player.visual.flash(Color(0.6, 1, 0.6))
	var cfg := Juice.cfg()
	if cfg:
		Juice.burst(cfg.particles_skill, global_position, config.potion_color)
	AudioManager.play_sfx(config.sfx_potion)
	_release.call_deferred()


func _release() -> void:
	ObjectPool.release_node(self)
