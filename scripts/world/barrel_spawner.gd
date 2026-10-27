class_name BarrelSpawner
extends Node2D
## Pontos dos barris: cada Marker2D filho é uma posição (mova no editor).
## O Game chama respawn() no começo da vez de cada personagem.

@export var config: BarrelConfig


func respawn() -> void:
	var barrels := Pools.get_pool(&"barrels")
	var potions := Pools.get_pool(&"potions")
	if barrels == null or config == null:
		return
	if potions:
		potions.release_all()
	barrels.release_all()
	# Espera a devolução ao pool antes de pegar de novo.
	_spawn.call_deferred()


func _spawn() -> void:
	var barrels := Pools.get_pool(&"barrels")
	var count := 0
	for child: Node in get_children():
		var marker := child as Marker2D
		if marker == null or count >= config.max_barrels:
			continue
		var barrel := barrels.acquire() as Barrel
		if barrel:
			barrel.activate(config, marker.global_position)
			count += 1
