class_name Pools
extends Node
## Registro dos pools da fase. Os pools são nós comuns (ObjectPool) na cena do jogo,
## com tamanho inicial editável no Inspector; aqui só guardamos as referências.

static var instance: Pools

@export var hitboxes: ObjectPool
@export var projectiles: ObjectPool
@export var particles: ObjectPool
@export var damage_numbers: ObjectPool
@export var afterimages: ObjectPool
@export var lightning: ObjectPool
@export var enemies: ObjectPool


func _enter_tree() -> void:
	instance = self


func _exit_tree() -> void:
	if instance == self:
		instance = null


static func get_pool(pool_name: StringName) -> ObjectPool:
	if instance == null:
		return null
	return instance.get(pool_name) as ObjectPool


## Libera tudo o que é temporário (troca de personagem, início do boss).
func clear_combat() -> void:
	for pool: ObjectPool in [hitboxes, projectiles, lightning, enemies]:
		if pool:
			pool.release_all()
