class_name HurtboxComponent
extends Area2D
## Área que recebe golpes. Só repassa o HitData; o dono decide (parry, defesa, i-frames).

signal hit_received(hit: HitData)

var team: Team.Faction = Team.Faction.HEROES
var enabled: bool = true


func _ready() -> void:
	monitoring = false
	monitorable = true


func set_team(side: Team.Faction) -> void:
	if is_in_group(Team.hurtbox_group(team)):
		remove_from_group(Team.hurtbox_group(team))
	team = side
	collision_layer = Team.hurtbox_layer(side)
	collision_mask = 0
	add_to_group(Team.hurtbox_group(side))


func is_active() -> bool:
	return enabled and is_visible_in_tree() and can_process()


func receive_hit(hit: HitData) -> bool:
	if not is_active() or hit.team == team:
		return false
	hit_received.emit(hit)
	return true
