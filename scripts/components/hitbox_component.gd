class_name HitboxComponent
extends Area2D
## Base das áreas que causam dano (ataques e projéteis).
## Cada ataque acerta cada alvo uma única vez (lista de alvos já atingidos).

signal hit_landed(hurtbox: HurtboxComponent)

var team: Team.Faction = Team.Faction.HEROES
var active: bool = false

var _already_hit: Dictionary = {}


func _ready() -> void:
	monitorable = false
	monitoring = true
	area_entered.connect(_on_area_entered)


func set_team(side: Team.Faction, extra_layer: int = 0, extra_mask: int = 0) -> void:
	team = side
	collision_layer = Team.hitbox_layer(side) | extra_layer
	collision_mask = Team.hitbox_mask(side) | extra_mask


func reset_hits() -> void:
	_already_hit.clear()


func _on_area_entered(area: Area2D) -> void:
	var hurtbox := area as HurtboxComponent
	if hurtbox == null or not active or hurtbox.team == team or _already_hit.has(hurtbox):
		return
	if _deliver(hurtbox):
		_already_hit[hurtbox] = true
		hit_landed.emit(hurtbox)


## Subclasses montam o HitData e entregam. Retorna true se acertou.
func _deliver(_hurtbox: HurtboxComponent) -> bool:
	return false
