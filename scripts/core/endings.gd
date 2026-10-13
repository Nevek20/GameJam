class_name Endings
extends RefCounted
## Seleção dos finais: funções puras, isoladas e alimentadas por dados.
## As chaves retornadas indexam data/endings.json e o Resource EndingImages.

const DEATH := &"death"
const POSITIVE := &"positive"
const QUESTIONABLE := &"questionable"
const NEGATIVE_VICTORIOUS := &"negative_victorious"
const NEGATIVE_IMPRISONED := &"negative_imprisoned"

const KINGDOM_POSITIVE := &"positive"
const KINGDOM_NEGATIVE := &"negative"
const KINGDOM_DOUBLE_ALLIANCE := &"double_alliance"


## Final de um personagem.
## defeated_by_other: o personagem aliado foi derrotado pelo outro (que vira o herói).
static func character_ending(alive: bool, standing: Reputation.Standing, defeated_by_other: bool) -> StringName:
	if not alive:
		return DEATH
	if standing == Reputation.Standing.NEGATIVE:
		return NEGATIVE_IMPRISONED if defeated_by_other else NEGATIVE_VICTORIOUS
	if standing == Reputation.Standing.POSITIVE:
		return POSITIVE
	return QUESTIONABLE


## Final do reino. O exército vence se a luta final não terminou com vitória
## do lado do reino (o jogador morreu antes, ou um aliado do exército venceu).
## Saquear não entra aqui: só altera o final do personagem.
static func kingdom_ending(p1_allied: bool, p2_allied: bool, final_fight_resolved: bool,
		player_won: bool, player_fought_for_army: bool) -> StringName:
	var army_won := not final_fight_resolved or player_won == player_fought_for_army
	if not army_won:
		return KINGDOM_POSITIVE
	if p1_allied and p2_allied:
		return KINGDOM_DOUBLE_ALLIANCE
	return KINGDOM_NEGATIVE
