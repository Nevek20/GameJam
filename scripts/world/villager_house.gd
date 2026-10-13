class_name VillagerHouse
extends Node2D
## Casa com morador. Guarda o estado/visual e avisa quando o jogador chega perto;
## as decisões (diálogo, QTE, saque) ficam no InteractionDirector.

signal player_entered(house: VillagerHouse)

## Identificador salvo no GameState (estado passa do Personagem 1 para o 2).
@export var house_id: StringName = &"house_1"
## Textos em data/dialogues.json -> houses.<dialogue_key> (cai em "default" se não existir).
@export var dialogue_key: StringName = &"default"
@export var house_texture: Texture2D
@export var villager_texture: Texture2D
@export var poi_color: Color = Color(1, 0.85, 0.3)

var state: GameState.HouseState = GameState.HouseState.OCCUPIED
var looted: bool = false
var poi_active: bool = false

@onready var _zone: Area2D = $InteractionZone
@onready var _house_shape: PlaceholderShape = $Visual/Placeholder
@onready var _house_sprite: Sprite2D = $Visual/Sprite2D
@onready var _villager: EntityVisual = $Villager
@onready var _status: Label = $Status

var _status_tween: Tween


func _ready() -> void:
	add_to_group(&"poi")
	_zone.body_entered.connect(_on_body_entered)
	if house_texture:
		_house_sprite.texture = house_texture
		_house_sprite.visible = true
		_house_shape.visible = false
	_villager.apply_look(villager_texture, null, Color(0.55, 0.95, 0.8), Color(0.95, 0.5, 0.9),
		PlaceholderShape.Accent.HOOD, 12.0, Vector2.ONE)
	_status_tween = create_tween().set_loops()
	_status_tween.tween_property(_status, "position:y", _status.position.y - 8.0, 0.5).set_trans(Tween.TRANS_SINE)
	_status_tween.tween_property(_status, "position:y", _status.position.y, 0.5).set_trans(Tween.TRANS_SINE)
	load_state()


func load_state() -> void:
	state = GameState.get_house_state(house_id)
	looted = GameState.is_house_looted(house_id)
	_apply_visual()


func set_state(new_state: GameState.HouseState, is_looted: bool) -> void:
	state = new_state
	looted = is_looted
	GameState.set_house(house_id, state, looted)
	_apply_visual()


func set_poi_active(value: bool) -> void:
	poi_active = value
	_status.visible = value


func is_poi_active() -> bool:
	return poi_active


func get_poi_color() -> Color:
	return poi_color


func _apply_visual() -> void:
	_villager.visible = state != GameState.HouseState.LOST
	if state == GameState.HouseState.RESCUED:
		_villager.position = Vector2(-70, 70)
	var tint := Color.WHITE
	if looted:
		tint = Color(0.45, 0.4, 0.5)
	if state == GameState.HouseState.LOST:
		tint = Color(0.6, 0.55, 0.7)
	$Visual.modulate = tint


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if player and player.is_human():
		player_entered.emit(self)
