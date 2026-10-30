class_name State
extends Node
## Estado base. Subclasses sobrescrevem setup() para guardar o dono tipado.

var machine: StateMachine


func setup(_actor: Node) -> void:
	pass


func enter(_msg: Dictionary) -> void:
	pass


func exit() -> void:
	pass


func physics_update(_delta: float) -> void:
	pass
