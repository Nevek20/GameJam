class_name AIController
extends CharacterController
## IA simples para o ajudante e para o personagem que vira boss:
## persegue o alvo, mantém distância preferida, usa ataque automático e habilidades.

var profile: AIProfile
var target: Node2D

var _think_left: float = 0.0
var _move: Vector2 = Vector2.ZERO
var _wants: Dictionary = {}
var _hold_attack: bool = false
var _parry_hold_left: float = 0.0
var _strafe_sign: float = 1.0


func _physics_process(delta: float) -> void:
	if not enabled or actor == null:
		return
	_parry_hold_left -= delta
	_think_left -= delta
	if _think_left > 0.0:
		return
	_think_left = profile.think_interval * randf_range(0.8, 1.2)
	_think()


func _think() -> void:
	_wants.clear()
	if not _target_valid():
		target = Team.find_nearest(actor.get_tree(), Team.opposite(actor.team), actor.global_position, 4000.0)
	if target == null:
		_move = Vector2.ZERO
		_hold_attack = false
		return
	var to := target.global_position - actor.global_position
	var dist := to.length()
	var dir := to / maxf(dist, 0.001)
	var forward := Vector2.ZERO
	if dist > profile.preferred_range + profile.range_tolerance:
		forward = dir
	elif dist < profile.preferred_range - profile.range_tolerance:
		forward = -dir
	if randf() < 0.25:
		_strafe_sign = -_strafe_sign
	_move = (forward + dir.orthogonal() * _strafe_sign * profile.strafe_amount).limit_length(1.0)

	var stats := actor.stats
	_hold_attack = stats.attack != null and dist <= stats.attack.ai_range
	if _usable(stats.ultimate, dist) and randf() < profile.ultimate_chance:
		_wants[Actions.ULTIMATE] = true
	elif _usable(stats.skill_q, dist) and randf() < profile.skill_chance:
		_wants[Actions.SKILL_Q] = true
	elif _usable(stats.skill_e, dist) and randf() < profile.skill_chance:
		_wants[Actions.SKILL_E] = true
	if randf() < profile.dash_chance:
		_wants[Actions.DASH] = true
	if profile.parry_chance > 0.0 and target.has_method(&"is_attacking") and target.call(&"is_attacking") \
			and dist < 160.0 and randf() < profile.parry_chance:
		_wants[Actions.PARRY] = true
		_parry_hold_left = 0.35


func _usable(ability: Ability, dist: float) -> bool:
	return ability != null and dist <= ability.ai_range and actor.caster.is_ready(ability)


func _target_valid() -> bool:
	if target == null or not is_instance_valid(target) or not target.is_visible_in_tree():
		return false
	return not target.has_method(&"is_targetable") or target.call(&"is_targetable")


func get_move_vector() -> Vector2:
	return _move if enabled else Vector2.ZERO


func get_aim_direction() -> Vector2:
	if enabled and _target_valid():
		return actor.global_position.direction_to(target.global_position)
	return actor.aim_dir


func is_held(action: StringName) -> bool:
	if not enabled:
		return false
	if action == Actions.ATTACK:
		return _hold_attack
	if action == Actions.PARRY:
		return _parry_hold_left > 0.0
	return false


func peek(action: StringName) -> bool:
	return enabled and bool(_wants.get(action, false))


func consume(action: StringName) -> bool:
	if peek(action):
		_wants[action] = false
		return true
	return false


func clear_buffer() -> void:
	_wants.clear()
