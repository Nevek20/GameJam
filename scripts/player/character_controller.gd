class_name CharacterController
extends Node
## Fonte de intenções do personagem (humano ou IA).
## Os estados do Player só conversam com esta interface.

var actor: Player
var enabled: bool = true


func setup(player: Player) -> void:
	actor = player


func get_move_vector() -> Vector2:
	return Vector2.ZERO


func get_aim_direction() -> Vector2:
	return actor.aim_dir if actor else Vector2.RIGHT


## Botão segurado (ataque automático, defesa).
func is_held(_action: StringName) -> bool:
	return false


## Há um aperto guardado no buffer?
func peek(_action: StringName) -> bool:
	return false


## Usa o aperto guardado no buffer.
func consume(_action: StringName) -> bool:
	return false


func clear_buffer() -> void:
	pass


func is_human() -> bool:
	return false
