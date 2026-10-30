class_name EnemyState
extends State
## Base dos estados de inimigo com acesso tipado.

var enemy: Enemy


func setup(actor: Node) -> void:
	enemy = actor as Enemy
