class_name Player
extends CharacterBody2D
## Classe base dos dois personagens: vida, movimento, dash, parry e cooldowns.
## O que muda entre Princesa e Mago vem do CharacterStats (habilidades são Resources).
## A mesma cena serve para o jogador, para o ajudante (IA) e para o personagem que vira boss.

signal died(player: Player)
signal health_changed(current: float, maximum: float)
signal parried(player: Player)
signal hurt(player: Player)

enum Slot { ATTACK, SKILL_Q, SKILL_E, ULTIMATE }

const SLOT_ACTIONS: Array[StringName] = [Actions.ATTACK, Actions.SKILL_Q, Actions.SKILL_E, Actions.ULTIMATE]

var stats: CharacterStats
var team: Team.Faction = Team.Faction.HEROES
var controller: CharacterController
var boss_profile: BossCharacterProfile
var aim_dir: Vector2 = Vector2.RIGHT
var dead: bool = false
## Escala do corpo (GameScale). Distâncias como o dash são multiplicadas por ela.
var size_scale: float = 1.0
var dash_cooldown_left: float = 0.0
var parry_cooldown_left: float = 0.0
var invulnerable_left: float = 0.0

@onready var visual: EntityVisual = $Visual
@onready var guard: GuardVisual = $Visual/Guard
@onready var aim_indicator: AimIndicator = $AimIndicator
@onready var health: HealthComponent = $Health
@onready var hurtbox: HurtboxComponent = $Hurtbox
@onready var movement: MovementComponent = $Movement
@onready var caster: AbilityCaster = $Caster
@onready var state_machine: StateMachine = $StateMachine
@onready var _body_shape: CollisionShape2D = $CollisionShape2D
@onready var _hurt_shape: CollisionShape2D = $Hurtbox/CollisionShape2D
## Marcador visível no editor: de onde saem golpes e projéteis.
@onready var attack_origin: Marker2D = $AttackOrigin


func _ready() -> void:
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)
	hurtbox.hit_received.connect(_on_hit_received)
	state_machine.setup(self)
	guard.hide_guard()


## Configura o personagem para um papel (jogador, ajudante ou boss).
func setup(character: CharacterStats, side: Team.Faction, new_controller: CharacterController,
		profile: BossCharacterProfile = null) -> void:
	stats = character
	team = side
	boss_profile = profile
	for group: StringName in [Team.GROUP_HEROES, Team.GROUP_FOES]:
		if is_in_group(group):
			remove_from_group(group)
	add_to_group(Team.group_of(side))
	collision_layer = Team.body_layer(side)
	collision_mask = Team.body_mask(side)
	hurtbox.set_team(side)
	caster.setup(self, side)
	# Telegraph visível para todo personagem controlado pela IA (boss ou ajudante).
	caster.show_telegraph = side == Team.Faction.FOES or not new_controller.is_human()
	caster.damage_multiplier = profile.damage_multiplier if profile else 1.0
	caster.windup_multiplier = profile.windup_multiplier if profile else 1.0
	caster.cooldown_multiplier = profile.cooldown_multiplier if profile else 1.0
	var speed_mult := profile.speed_multiplier if profile else 1.0
	var s := GameScale.of(GameScale.Kind.BOSS if profile else GameScale.Kind.PLAYER)
	movement.configure(stats.move_speed * speed_mult * s, stats.acceleration * s, stats.friction * s)
	visual.apply_look(stats.texture, stats.sprite_frames, stats.body_color, stats.accent_color,
		stats.placeholder_accent, stats.sprite_scale, stats.sprite_offset)
	size_scale = GameScale.of(GameScale.Kind.BOSS if profile else GameScale.Kind.PLAYER)
	BodySetup.apply(stats.body_size, stats.collision_size, stats.attack_origin_offset, size_scale,
		_body_shape, _hurt_shape, hurtbox, caster, attack_origin, visual)
	caster.geometry_scale = size_scale
	aim_indicator.position = caster.position
	aim_indicator.distance = stats.body_size.x * size_scale * 0.5 + 18.0
	_set_controller(new_controller)
	aim_indicator.visible = new_controller.is_human()
	aim_indicator.color = Color(stats.accent_color, 0.8)
	aim_indicator.queue_redraw()


## Recoloca o personagem vivo e com vida cheia.
func spawn_at(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	dead = false
	dash_cooldown_left = 0.0
	parry_cooldown_left = 0.0
	invulnerable_left = 0.0
	var hp_mult := boss_profile.health_multiplier if boss_profile else 1.0
	health.setup(stats.max_health * hp_mult)
	hurtbox.enabled = true
	caster.interrupt()
	caster.reset_cooldowns()
	visual.reset_effects()
	visual.rotation = 0.0
	visible = true
	process_mode = Node.PROCESS_MODE_INHERIT
	controller.clear_buffer()
	state_machine.start()


## Desliga totalmente (personagem fora de cena).
func deactivate() -> void:
	caster.interrupt()
	hurtbox.enabled = false
	visible = false
	process_mode = Node.PROCESS_MODE_DISABLED


func set_input_enabled(value: bool) -> void:
	if controller:
		controller.enabled = value
		controller.clear_buffer()


func is_human() -> bool:
	return controller != null and controller.is_human()


func is_targetable() -> bool:
	return not dead and visible


func is_attacking() -> bool:
	return caster.is_casting()


func get_ability(slot: Slot) -> Ability:
	match slot:
		Slot.SKILL_Q:
			return stats.skill_q
		Slot.SKILL_E:
			return stats.skill_e
		Slot.ULTIMATE:
			return stats.ultimate
	return stats.attack


func can_dash() -> bool:
	return dash_cooldown_left <= 0.0


func can_parry() -> bool:
	return parry_cooldown_left <= 0.0


func dash_ratio() -> float:
	return clampf(dash_cooldown_left / maxf(stats.dash_cooldown, 0.001), 0.0, 1.0)


func parry_ratio() -> float:
	return clampf(parry_cooldown_left / maxf(stats.parry_cooldown, 0.001), 0.0, 1.0)


## Avisa (HUD) que este personagem aparou um golpe.
func notify_parried() -> void:
	parried.emit(self)


## Chamado quando um golpe nosso é aparado pelo inimigo.
func on_parried(by: Node2D, stun: float, push: float) -> void:
	if dead:
		return
	caster.interrupt()
	movement.apply_knockback(by.global_position.direction_to(global_position) * push)
	state_machine.transition_to(&"Hurt", {"duration": stun})


func _physics_process(delta: float) -> void:
	dash_cooldown_left -= delta
	parry_cooldown_left -= delta
	invulnerable_left -= delta
	if dead or controller == null:
		return
	aim_dir = controller.get_aim_direction()
	visual.face(aim_dir)
	aim_indicator.rotation = aim_dir.angle()
	_update_cast_aim(delta)


# A mira de um ataque fica travada ao lançar; só o feixe acompanha a mira
# e o dash de ataque segue o alvo durante o telegraph (trava no fim).
func _update_cast_aim(delta: float) -> void:
	if not caster.is_casting() or caster.is_aim_tracking():
		caster.set_aim(aim_dir)
		return
	var shape := caster.current as ShapeAbility
	if shape == null or not shape.follow_aim:
		return
	if boss_profile:
		var step := deg_to_rad(boss_profile.aim_turn_speed) * delta
		var angle := rotate_toward(caster.aim_dir.angle(), aim_dir.angle(), step)
		caster.set_aim(Vector2.from_angle(angle))
	else:
		caster.set_aim(aim_dir)


func _set_controller(new_controller: CharacterController) -> void:
	if controller and controller != new_controller:
		controller.queue_free()
	controller = new_controller
	if new_controller.get_parent() == null:
		add_child(new_controller)
	# Lê o input antes da máquina de estados no mesmo frame.
	move_child(new_controller, state_machine.get_index())
	new_controller.setup(self)


func _on_hit_received(hit: HitData) -> void:
	if dead or invulnerable_left > 0.0:
		return
	if state_machine.is_in(&"Dash") and stats.dash_invulnerable:
		return
	var multiplier := 1.0
	var blocked := false
	if state_machine.is_in(&"Parry"):
		var parry_state := state_machine.current as PlayerParryState
		if parry_state.try_parry(hit):
			return
		multiplier = stats.block_damage_multiplier
		blocked = true
	_apply_damage(hit, multiplier, blocked)


func _apply_damage(hit: HitData, multiplier: float, blocked: bool) -> void:
	var cfg := Juice.cfg()
	var applied := health.take_damage(hit.damage * multiplier)
	visual.flash()
	if cfg:
		var knock := hit.knockback * cfg.knockback_multiplier * (0.35 if blocked else 1.0)
		if cfg.knockback_enabled:
			movement.apply_knockback(hit.direction * knock)
		Juice.burst(cfg.particles_hit, hurtbox.global_position, hit.color, hit.direction)
		if is_human():
			Juice.damage_number(hurtbox.global_position, applied, cfg.color_damage_taken, false)
			Juice.hit_stop(cfg.hitstop_hurt)
			Juice.shake_custom(cfg.shake_hurt_strength, cfg.shake_hurt_duration)
		else:
			Juice.damage_number(hurtbox.global_position, applied, cfg.color_damage_dealt, hit.juice_level != Ability.JuiceLevel.LIGHT)
			Juice.hit_stop_for(hit.juice_level)
			Juice.shake(hit.juice_level)
	AudioManager.play_sfx(&"block" if blocked else (&"hurt" if is_human() else hit.sfx_hit))
	if health.is_dead():
		return
	hurt.emit(self)
	if blocked:
		return
	invulnerable_left = stats.hurt_invulnerability if is_human() else 0.0
	if not caster.has_super_armor() and not boss_profile:
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


# Ponto de interesse (só quando é o boss).
func is_poi_active() -> bool:
	return boss_profile != null and not dead and visible


func get_poi_color() -> Color:
	return Color(1, 0.2, 0.3)
