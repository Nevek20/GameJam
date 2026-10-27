class_name ArmyCamp
extends Node2D
## Acampamento do exército inimigo: ponto de interesse e zona da escolha
## (enfrentar ou se aliar). Também guarda os pontos de surgimento das ondas.

signal player_entered(camp: ArmyCamp)

@export var poi_color: Color = Color(1, 0.3, 0.4)

var poi_active: bool = true

@onready var _zone: Area2D = $InteractionZone
@onready var _decor: Node2D = $Soldiers
@onready var _ally_figure: EntityVisual = $AllyFigure
@onready var _spawns: Node2D = $Spawns
@onready var _status: Label = $Status


func _ready() -> void:
	add_to_group(&"poi")
	_zone.body_entered.connect(_on_body_entered)
	_ally_figure.visible = false


func is_poi_active() -> bool:
	return poi_active


func get_poi_color() -> Color:
	return poi_color


func set_poi_active(value: bool) -> void:
	poi_active = value
	_status.visible = value


func set_decor_visible(value: bool) -> void:
	_decor.visible = value


## Mostra o Personagem 1 junto do exército quando ele se aliou (estado do mundo para o P2).
func show_ally_figure(stats: CharacterStats) -> void:
	_ally_figure.visible = stats != null
	if stats:
		_ally_figure.apply_look(stats.texture, stats.sprite_frames, stats.body_color, stats.accent_color,
			stats.placeholder_accent, stats.sprite_scale, stats.sprite_offset)
		_ally_figure.placeholder.size = stats.body_size
		_ally_figure.placeholder.position = Vector2(0, -stats.body_size.y * 0.5)


func get_spawn_points() -> Array[Vector2]:
	var points: Array[Vector2] = []
	for child: Node in _spawns.get_children():
		points.append((child as Node2D).global_position)
	return points


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player and player.is_human():
		player_entered.emit(self)
