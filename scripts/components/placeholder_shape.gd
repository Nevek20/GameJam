@tool
class_name PlaceholderShape
extends Node2D
## Forma desenhada por código enquanto não há sprite.
## Formas simples (círculo, retângulo, triângulo, elipse, losango) servem para sombras e marcações.
## Os outros tipos (casa, personagem, fogo...) não desenham nada enquanto não houver arte.
## Fica escondida automaticamente quando o EntityVisual recebe uma textura.

enum Kind { CIRCLE, RECT, TRIANGLE, ELLIPSE, DIAMOND, HOUSE, TENT, TREE, TOMBSTONE, MUSHROOM, WALL, FLAME, BANNER, CHARACTER, BARREL, POTION }
enum Accent { NONE, CROWN, HAT, HELMET, HORNS, HOOD }

@export var kind: Kind = Kind.CIRCLE:
	set(value):
		kind = value
		queue_redraw()
@export var size: Vector2 = Vector2(36, 36):
	set(value):
		size = value
		queue_redraw()
@export var color: Color = Color.WHITE:
	set(value):
		color = value
		queue_redraw()
@export var secondary_color: Color = Color(0.2, 0.1, 0.3):
	set(value):
		secondary_color = value
		queue_redraw()
@export var outline_color: Color = Color(0.05, 0.02, 0.1, 0.85):
	set(value):
		outline_color = value
		queue_redraw()
@export var outline_width: float = 2.5:
	set(value):
		outline_width = value
		queue_redraw()
@export var accent: Accent = Accent.NONE:
	set(value):
		accent = value
		queue_redraw()
@export var accent_color: Color = Color(1, 0.85, 0.3):
	set(value):
		accent_color = value
		queue_redraw()
## Não usado (era dos desenhos antigos); mantido para as cenas continuarem abrindo.
@export var eyes: bool = false:
	set(value):
		eyes = value
		queue_redraw()

var look_dir: Vector2 = Vector2.RIGHT


func _draw() -> void:
	var h := size * 0.5
	match kind:
		Kind.CIRCLE:
			draw_circle(Vector2.ZERO, h.x, color)
			_outline_circle(h.x)
		Kind.ELLIPSE:
			draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0, h.y / maxf(h.x, 0.01)))
			draw_circle(Vector2.ZERO, h.x, color)
			draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		Kind.RECT:
			draw_rect(Rect2(-h, size), color)
			_outline_poly(PackedVector2Array([-h, Vector2(h.x, -h.y), h, Vector2(-h.x, h.y)]))
		Kind.TRIANGLE:
			var tri := PackedVector2Array([Vector2(0, -h.y), Vector2(h.x, h.y), Vector2(-h.x, h.y)])
			draw_colored_polygon(tri, color)
			_outline_poly(tri)
		Kind.DIAMOND:
			var dia := PackedVector2Array([Vector2(0, -h.y), Vector2(h.x, 0), Vector2(0, h.y), Vector2(-h.x, 0)])
			draw_colored_polygon(dia, color)
			_outline_poly(dia)
		_:
			_draw_missing(h)


## Tipos sem arte (casa, personagem, fogo...) não desenham nada: no jogo nunca aparece
## caixa de "sprite faltando". Coloque a arte no Sprite2D / AnimatedSprite2D do objeto.
func _draw_missing(_h: Vector2) -> void:
	pass


func _outline_circle(radius: float) -> void:
	if outline_width > 0.0:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, outline_color, outline_width)


func _outline_poly(points: PackedVector2Array) -> void:
	if outline_width <= 0.0:
		return
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, outline_color, outline_width)
