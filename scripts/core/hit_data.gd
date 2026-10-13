class_name HitData
extends RefCounted
## Pacote de informações de um golpe, criado pela hitbox e entregue à hurtbox.

var damage: float = 0.0
var knockback: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var source: Node2D = null
var team: Team.Faction = Team.Faction.HEROES
var juice_level: Ability.JuiceLevel = Ability.JuiceLevel.LIGHT
var parryable: bool = true
var hit_position: Vector2 = Vector2.ZERO
var color: Color = Color.WHITE
var sfx_hit: StringName = &"hit"
