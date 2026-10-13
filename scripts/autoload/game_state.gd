extends Node
## Estado do mundo que passa do Personagem 1 para o 2 e chega às telas de final.
## Só dados e consultas; a gameplay fica nas cenas.

signal character_status_changed(character_id: StringName)

enum HouseState { OCCUPIED, RESCUED, LOST }

var character_ids: Array[StringName] = []
var current_index: int = 0
var houses: Dictionary = {}
var army_choices: Dictionary = {}
var final_fight_resolved: bool = false
var final_fight_player_won: bool = false
var final_fight_player_for_army: bool = false

var _alive: Dictionary = {}
var _defeated: Dictionary = {}


func reset(ids: Array[StringName]) -> void:
	character_ids = ids.duplicate()
	current_index = 0
	houses.clear()
	army_choices.clear()
	_alive.clear()
	_defeated.clear()
	for id: StringName in ids:
		_alive[id] = true
		_defeated[id] = false
	final_fight_resolved = false
	final_fight_player_won = false
	final_fight_player_for_army = false


func p1_id() -> StringName:
	return character_ids[0] if character_ids.size() > 0 else &""


func p2_id() -> StringName:
	return character_ids[1] if character_ids.size() > 1 else &""


func current_id() -> StringName:
	return character_ids[current_index] if current_index < character_ids.size() else &""


func is_alive(id: StringName) -> bool:
	return bool(_alive.get(id, false))


func mark_dead(id: StringName) -> void:
	_alive[id] = false
	character_status_changed.emit(id)


## O personagem aliado foi derrotado pelo outro (final: preso).
func mark_defeated(id: StringName) -> void:
	_defeated[id] = true
	character_status_changed.emit(id)


func is_defeated(id: StringName) -> bool:
	return bool(_defeated.get(id, false))


func set_house(house_id: StringName, state: HouseState, looted: bool) -> void:
	houses[house_id] = {"state": state, "looted": looted}


func get_house_state(house_id: StringName) -> HouseState:
	var data: Dictionary = houses.get(house_id, {})
	return data.get("state", HouseState.OCCUPIED)


func is_house_looted(house_id: StringName) -> bool:
	var data: Dictionary = houses.get(house_id, {})
	return bool(data.get("looted", false))


func set_army_choice(id: StringName, choice: StringName) -> void:
	army_choices[id] = choice


func get_army_choice(id: StringName) -> StringName:
	return army_choices.get(id, &"")


func record_final_fight(player_won: bool, player_for_army: bool) -> void:
	final_fight_resolved = true
	final_fight_player_won = player_won
	final_fight_player_for_army = player_for_army


func character_ending(id: StringName) -> StringName:
	return Endings.character_ending(is_alive(id), ReputationState.get_standing(id), is_defeated(id))


func kingdom_ending() -> StringName:
	return Endings.kingdom_ending(ReputationState.is_allied(p1_id()), ReputationState.is_allied(p2_id()),
		final_fight_resolved, final_fight_player_won, final_fight_player_for_army)
