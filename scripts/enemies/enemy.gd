class_name Enemy
extends CharacterBody2D
## Inimigo genérico (soldado, elite, cavaleiro do reino). Tudo vem do EnemyStats.
## Vive em um ObjectPool: activate() reinicia, a morte devolve ao pool.

signal died(enemy: Enemy)
signal health_changed(current: float, maximum: float)

var stats: EnemyStats
var skin: EnemySkin
var team: Team.Faction = Team.Faction.FOES
var target: Node2D
var dead: bool = false
var attack_cooldown_left: float = 0.0
var dash_cooldown_left: float = 0.0
var block_cooldown_left: float = 0.0

@onready var visual: EntityVisual = $Visual
@onready var guard: GuardVisual = $Visual/Guard
@onready var health: HealthComponent = $Health
@onready var hurtbox: HurtboxComponent = $Hurtbox
@onready var movement: MovementComponent = $Movement
@onready var caster: AbilityCaster = $Caster
@onready var state_machine: StateMachine = $StateMachine
@onready var _body_shape: CollisionShape2D = $CollisionShape2D
@onready var _hurt_shape: CollisionShape2D = $Hurtbox/CollisionShape2D

var _spawn_tween: Tween


func _ready() -> void:
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)
	hurtbox.hit_received.connect(_on_hit_received)
	state_machine.setup(self)
	guard.hide_guard()


func activate(enemy_stats: EnemyStats, pos: Vector2, enemy_skin: EnemySkin = null) -> void:
	stats = enemy_stats
	skin = enemy_skin if enemy_skin else enemy_stats.skin
	if not is_in_group(Team.GROUP_FOES):
		add_to_group(Team.GROUP_FOES)
	collision_layer = Team.body_layer(team)
	collision_mask = Team.body_mask(team)
	hurtbox.set_team(team)
	hurtbox.enabled = true
	caster.setup(self, team)
	caster.show_telegraph = true
	caster.interrupt()
	caster.reset_cooldowns()
	movement.configure(stats.move_speed * current_speed_multiplier(), stats.acceleration, stats.friction)
	(_body_shape.shape as CircleShape2D).radius = stats.body_radius
	(_hurt_shape.shape as CircleShape2D).radius = stats.body_radius + 2.0
	if skin:
		visual.apply_look(skin.texture, skin.sprite_frames, skin.body_color, skin.accent_color,
			skin.placeholder_accent, stats.body_radius, stats.sprite_scale)
	health.setup(stats.max_health)
	global_position = pos
	velocity = Vector2.ZERO
	dead = false
	target = null
	attack_cooldown_left = randf_range(0.4, maxf(stats.attack_interval, 0.5))
	dash_cooldown_left = stats.dash_cooldown * 0.5
	block_cooldown_left = 0.0
	guard.hide_guard()
	visual.rotation = 0.0
	_play_spawn()
	state_machine.start()


func on_pool_release() -> void:
	caster.interrupt()
	if _spawn_tween:
		_spawn_tween.kill()


func is_targetable() -> bool:
	return not dead and visible


func is_attacking() -> bool:
	return caster.is_casting()


func find_target() -> Node2D:
	return Team.find_nearest(get_tree(), Team.opposite(team), global_position, stats.aggro_range)


func has_valid_target() -> bool:
	if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
		return false
	return not target.has_method(&"is_targetable") or target.call(&"is_targetable")


# --- Pontos que o Boss sobrescreve (fases) ---

func get_attacks() -> Array[Ability]:
	return stats.attacks


func get_attack_weights() -> Array[float]:
	return stats.attack_weights


func current_attack_interval() -> float:
	return stats.attack_interval


func current_speed_multiplier() -> float:
	return 1.0


## Sorteia um ataque (por peso) entre os que alcançam o alvo.
func choose_attack(distance: float) -> Ability:
	var attacks := get_attacks()
	var weights := get_attack_weights()
	var total := 0.0
	for i in attacks.size():
		if attacks[i] and distance <= attacks[i].ai_range and caster.is_ready(attacks[i]):
			total += weights[i] if i < weights.size() else 1.0
	if total <= 0.0:
		return null
	var roll := randf() * total
	for i in attacks.size():
		if attacks[i] and distance <= attacks[i].ai_range and caster.is_ready(attacks[i]):
			roll -= weights[i] if i < weights.size() else 1.0
			if roll <= 0.0:
				return attacks[i]
	return null


## Maior alcance entre os ataques (para saber quando parar de andar).
func max_attack_range() -> float:
	var best := 0.0
	for ability: Ability in get_attacks():
		if ability:
			best = maxf(best, ability.ai_range)
	return best


## Nosso golpe foi aparado: atordoado.
func on_parried(by: Node2D, stun: float, push: float) -> void:
	if dead:
		return
	caster.interrupt()
	movement.apply_knockback(by.global_position.direction_to(global_position) * push * (1.0 - stats.knockback_resistance))
	state_machine.transition_to(&"Hurt", {"duration": stun, "stunned": true})


func _play_spawn() -> void:
	if _spawn_tween:
		_spawn_tween.kill()
	visual.scale = Vector2(0.2, 1.6)
	visual.modulate = Color(3, 3, 3, 0.0)
	_spawn_tween = create_tween().set_parallel(true)
	_spawn_tween.tween_property(visual, "scale", visual.base_scale, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_spawn_tween.tween_property(visual, "modulate", Color.WHITE, 0.3)
	var cfg := Juice.cfg()
	if cfg and skin:
		Juice.burst(cfg.particles_spawn, global_position, skin.body_color)


func _on_hit_received(hit: HitData) -> void:
	if dead:
		return
	var blocked := state_machine.is_in(&"Block")
	var multiplier := stats.block_damage_multiplier if blocked else 1.0
	var applied := health.take_damage(hit.damage * multiplier)
	var cfg := Juice.cfg()
	visual.flash()
	if cfg:
		var heavy := hit.juice_level != Ability.JuiceLevel.LIGHT
		Juice.damage_number(global_position, applied, cfg.color_damage_dealt, heavy)
		Juice.hit_stop_for(hit.juice_level)
		Juice.shake(hit.juice_level)
		Juice.burst(cfg.particles_hit, global_position, hit.color, hit.direction)
		if cfg.knockback_enabled:
			var knock := hit.knockback * cfg.knockback_multiplier * (1.0 - stats.knockback_resistance)
			movement.apply_knockback(hit.direction * knock * (0.3 if blocked else 1.0))
	AudioManager.play_sfx(&"block" if blocked else hit.sfx_hit)
	if health.is_dead():
		return
	if blocked:
		guard.parry_flash()
		return
	if stats.armor_while_attacking and caster.is_casting():
		return
	if state_machine.is_in(&"Roar"):
		return
	state_machine.transition_to(&"Hurt", {"duration": stats.hurt_stun})


func _on_health_changed(current: float, maximum: float) -> void:
	health_changed.emit(current, maximum)


func _on_died() -> void:
	dead = true
	hurtbox.enabled = false
	caster.interrupt()
	guard.hide_guard()
	state_machine.transition_to(&"Dead")
	died.emit(self)
