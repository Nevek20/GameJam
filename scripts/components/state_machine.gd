class_name StateMachine
extends Node
## Máquina de estados genérica: cada filho State é um estado, indexado pelo nome do nó.

signal state_changed(from: StringName, to: StringName)

@export var initial_state: State

var current: State
var _states: Dictionary = {}


func setup(actor: Node) -> void:
	for child: Node in get_children():
		var state := child as State
		if state:
			state.machine = self
			state.setup(actor)
			_states[StringName(child.name)] = state


func start(msg: Dictionary = {}) -> void:
	if current:
		current.exit()
	current = initial_state
	if current:
		current.enter(msg)


func transition_to(state_name: StringName, msg: Dictionary = {}) -> void:
	var next: State = _states.get(state_name)
	if next == null:
		push_error("StateMachine: estado inexistente %s" % state_name)
		return
	var previous := StringName(current.name) if current else &""
	if current:
		current.exit()
	current = next
	current.enter(msg)
	state_changed.emit(previous, state_name)


func is_in(state_name: StringName) -> bool:
	return current != null and StringName(current.name) == state_name


func current_name() -> StringName:
	return StringName(current.name) if current else &""


func _physics_process(delta: float) -> void:
	if current:
		current.physics_update(delta)
