class_name ObjectPool
extends Node2D
## Pool genérico: pré-instancia a cena e alterna process_mode/visibilidade
## em vez de instantiate/queue_free a cada uso.
## Itens podem implementar on_pool_release() para limpar estado.
## Itens de física (Area2D/CharacterBody2D) saem do espaço de física quando
## desativados (disable_mode REMOVE, padrão do Godot).

@export var scene: PackedScene
## Quantos itens criar ao iniciar a fase.
@export var initial_size: int = 16
## Se acabar, cria mais (com aviso no console) em vez de falhar silenciosamente.
@export var allow_growth: bool = true

var _free: Array[Node] = []
var _active: Array[Node] = []


func _ready() -> void:
	for i in initial_size:
		_free.append(_create())


func acquire() -> Node:
	if _free.is_empty():
		if not allow_growth:
			return null
		_free.append(_create())
	var item: Node = _free.pop_back()
	item.process_mode = Node.PROCESS_MODE_INHERIT
	if item is CanvasItem:
		(item as CanvasItem).visible = true
	_active.append(item)
	return item


## Devolve o item. A desativação é adiada para ser segura dentro de callbacks de física.
func release(item: Node) -> void:
	var index := _active.find(item)
	if index == -1:
		return
	_active.remove_at(index)
	if item is CanvasItem:
		(item as CanvasItem).visible = false
	_park.call_deferred(item)


func release_all() -> void:
	for i in range(_active.size() - 1, -1, -1):
		release(_active[i])


func active_count() -> int:
	return _active.size()


## Cópia da lista de itens ativos (para iterar enquanto libera).
func get_active() -> Array[Node]:
	return _active.duplicate()


func _create() -> Node:
	var item := scene.instantiate()
	item.set_meta(&"pool", self)
	add_child(item)
	item.process_mode = Node.PROCESS_MODE_DISABLED
	if item is CanvasItem:
		(item as CanvasItem).visible = false
	return item


func _park(item: Node) -> void:
	if not is_instance_valid(item) or _active.has(item):
		return
	item.process_mode = Node.PROCESS_MODE_DISABLED
	if item.has_method(&"on_pool_release"):
		item.call(&"on_pool_release")
	_free.append(item)


## Atalho usado pelos itens: devolve a si mesmo ao pool de origem.
static func release_node(item: Node) -> void:
	if item.has_meta(&"pool"):
		(item.get_meta(&"pool") as ObjectPool).release(item)
