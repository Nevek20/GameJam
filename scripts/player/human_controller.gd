class_name HumanController
extends CharacterController
## Lê o InputMap. Guarda apertos por alguns milissegundos (buffer) para o
## ataque e o dash responderem mesmo se apertados um pouco antes da hora.

const BUFFERED: Array[StringName] = [
	Actions.DASH, Actions.PARRY, Actions.ATTACK, Actions.SKILL_Q, Actions.SKILL_E, Actions.ULTIMATE,
]
const NEVER := -1000000
const UI_CONFIG_PATH := "res://resources/config/ui_config.tres"

var buffer_ms: int = 150
var _pressed_at: Dictionary = {}
var _attack_blocked_until: int = 0
var _block_ms: int = 200


func setup(player: Player) -> void:
	super(player)
	buffer_ms = int(player.stats.input_buffer * 1000.0)
	var ui := load(UI_CONFIG_PATH) as UIConfig
	if ui:
		_block_ms = int(ui.attack_block_after_screen * 1000.0)


func _physics_process(_delta: float) -> void:
	if not enabled:
		return
	var now := Time.get_ticks_msec()
	for action: StringName in BUFFERED:
		if Input.is_action_just_pressed(action):
			_pressed_at[action] = now


func get_move_vector() -> Vector2:
	if not enabled:
		return Vector2.ZERO
	# get_vector já normaliza: diagonal com a mesma velocidade.
	return Input.get_vector(Actions.MOVE_LEFT, Actions.MOVE_RIGHT, Actions.MOVE_UP, Actions.MOVE_DOWN)


func get_aim_direction() -> Vector2:
	var to_mouse := actor.get_global_mouse_position() - actor.global_position
	if to_mouse.length_squared() < 16.0:
		return actor.aim_dir
	return to_mouse.normalized()


func is_held(action: StringName) -> bool:
	return enabled and not _attack_blocked(action) and Input.is_action_pressed(action)


func peek(action: StringName) -> bool:
	if not enabled or _attack_blocked(action):
		return false
	return Time.get_ticks_msec() - int(_pressed_at.get(action, NEVER)) <= buffer_ms


func consume(action: StringName) -> bool:
	if peek(action):
		_pressed_at[action] = NEVER
		return true
	return false


func clear_buffer() -> void:
	_pressed_at.clear()
	# Chamado sempre que o input liga/desliga: bloqueia o ataque por um instante.
	_attack_blocked_until = Time.get_ticks_msec() + _block_ms


func _attack_blocked(action: StringName) -> bool:
	return action == Actions.ATTACK and Time.get_ticks_msec() < _attack_blocked_until


func is_human() -> bool:
	return true
