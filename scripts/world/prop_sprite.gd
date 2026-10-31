@tool
class_name PropSprite
extends StaticBody2D
## Objeto de cenário com imagem (árvore, pedra, igreja, fonte, casa de enfeite).
## A origem do nó é a BASE do objeto (bom para y-sort): a imagem fica em cima dela
## e a colisão é um retângulo na base. Tudo editável no Inspector.

@export var texture: Texture2D:
	set(value):
		texture = value
		_apply()
## Tamanho da imagem no jogo (1 = tamanho original do PNG).
@export var texture_scale: float = 0.4:
	set(value):
		texture_scale = value
		_apply()
## Ajuste fino do desenho (pixels do jogo). Y positivo desce o desenho.
@export var texture_offset: Vector2 = Vector2.ZERO:
	set(value):
		texture_offset = value
		_apply()
## Retângulo de colisão na base (largura x altura). (0, 0) = sem colisão.
@export var collision_size: Vector2 = Vector2(40, 20):
	set(value):
		collision_size = value
		_apply()
## Espelha o desenho (variação).
@export var flip: bool = false:
	set(value):
		flip = value
		_apply()

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	add_to_group(&"scenery")
	collision_layer = Layers.WORLD
	collision_mask = 0
	_apply()


func _apply() -> void:
	if not is_node_ready():
		return
	_sprite.texture = texture
	_sprite.flip_h = flip
	_sprite.scale = Vector2.ONE * texture_scale
	# Base da imagem na origem do nó.
	var h := texture.get_height() if texture else 0
	_sprite.position = Vector2(0, -h * texture_scale * 0.5) + texture_offset
	var rect := _collision.shape as RectangleShape2D
	_collision.disabled = collision_size.x <= 0.0 or collision_size.y <= 0.0
	if rect and not _collision.disabled:
		rect.size = collision_size
		_collision.position = Vector2(0, -collision_size.y * 0.5)
