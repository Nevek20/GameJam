class_name Level
extends Node2D
## A vila: limites do mapa (MapBoundary), marcadores de posição, casas e acampamento.
## Objetos no grupo "scenery" recebem a escala de cenário do GameScale.

## Área jogável (calculada a partir da MapBoundary).
var bounds: Rect2 = Rect2(0, 0, 3200, 2000)

@onready var world: Node2D = $World
@onready var boundary: MapBoundary = $World/MapBoundary
@onready var _ground: ColorRect = $Ground
@onready var _decor: DreamDecor = $Decor
@onready var actors: Node2D = $World/Actors
@onready var camp: ArmyCamp = $World/ArmyCamp
@onready var _houses: Node2D = $World/Houses
@onready var _markers: Node2D = $Markers


func _ready() -> void:
	bounds = boundary.inner_rect()
	# O chão e a decoração acompanham o tamanho do mapa.
	_ground.position = bounds.position - Vector2(400, 400)
	_ground.size = bounds.size + Vector2(800, 800)
	var mat := _ground.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter(&"world_size", _ground.size)
	_decor.area = bounds
	var k := GameScale.of(GameScale.Kind.SCENERY)
	if not is_equal_approx(k, 1.0):
		for node: Node in get_tree().get_nodes_in_group(&"scenery"):
			(node as Node2D).scale *= k


## Limites da câmera (um pouco além da área jogável para mostrar a muralha).
func camera_bounds() -> Rect2:
	return boundary.camera_rect()


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
