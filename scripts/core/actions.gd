class_name Actions
extends RefCounted
## Nomes das ações do InputMap (definidas no project.godot).

const MOVE_UP := &"move_up"
const MOVE_DOWN := &"move_down"
const MOVE_LEFT := &"move_left"
const MOVE_RIGHT := &"move_right"
const DASH := &"dash"
const ATTACK := &"attack"
const PARRY := &"parry"
const SKILL_Q := &"skill_q"
const SKILL_E := &"skill_e"
const ULTIMATE := &"ultimate"
const CONFIRM := &"confirm"
const PAUSE := &"pause"

## Ordem em que aparecem na tela de remapeamento.
const REMAPPABLE: Array[StringName] = [
	MOVE_UP, MOVE_DOWN, MOVE_LEFT, MOVE_RIGHT, DASH, ATTACK, PARRY,
	SKILL_Q, SKILL_E, ULTIMATE, CONFIRM, PAUSE,
]
