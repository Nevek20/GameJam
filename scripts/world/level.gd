class_name Level
extends Node2D
## A vila: limites do mapa, marcadores de posição, casas e acampamento.

## Limites da câmera e do mapa.
@export var bounds: Rect2 = Rect2(0, 0, 3200, 2000)

@onready var world: Node2D = $World
@onready var actors: Node2D = $World/Actors
@onready var camp: ArmyCamp = $World/ArmyCamp
@onready var _houses: Node2D = $World/Houses
@onready var _markers: Node2D = $Markers


func get_houses() -> Array[VillagerHouse]:
	var list: Array[VillagerHouse] = []
	for child: Node in _houses.get_children():
		if child is VillagerHouse:
			list.append(child as VillagerHouse)
	return list


func marker(marker_name: String) -> Vector2:
	var node := _markers.get_node_or_null(marker_name) as Node2D
	if node == null:
		push_warning("Level: marcador %s não existe" % marker_name)
		return bounds.get_center()
	return node.global_position


func marker_group(group_name: String) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var group := _markers.get_node_or_null(group_name)
	if group:
		for child: Node in group.get_children():
			points.append((child as Node2D).global_position)
	return points
