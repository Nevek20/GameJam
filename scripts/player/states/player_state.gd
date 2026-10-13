class_name PlayerState
extends State
## Base dos estados do jogador: acesso tipado e checagem comum de ações.

var player: Player


func setup(actor: Node) -> void:
	player = actor as Player


## Tenta iniciar dash, defesa ou ataque a partir do input (com buffer). True se trocou de estado.
func try_actions() -> bool:
	var c := player.controller
	if c.peek(Actions.DASH) and player.can_dash():
		c.consume(Actions.DASH)
		machine.transition_to(&"Dash")
		return true
	if c.peek(Actions.PARRY) and player.can_parry():
		c.consume(Actions.PARRY)
		machine.transition_to(&"Parry")
		return true
	for slot: Player.Slot in [Player.Slot.ULTIMATE, Player.Slot.SKILL_Q, Player.Slot.SKILL_E]:
		var action := Player.SLOT_ACTIONS[slot]
		var ability := player.get_ability(slot)
		if c.peek(action) and player.caster.is_ready(ability):
			c.consume(action)
			machine.transition_to(&"Attack", {"ability": ability})
			return true
	var basic := player.stats.attack
	if (c.is_held(Actions.ATTACK) or c.peek(Actions.ATTACK)) and player.caster.is_ready(basic):
		c.consume(Actions.ATTACK)
		machine.transition_to(&"Attack", {"ability": basic})
		return true
	return false


func go_idle_or_move() -> void:
	if player.controller.get_move_vector() != Vector2.ZERO:
		machine.transition_to(&"Move")
	else:
		machine.transition_to(&"Idle")
