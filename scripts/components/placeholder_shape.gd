@tool
class_name PlaceholderShape
extends Node2D
## Forma geométrica desenhada por código enquanto não há sprites.
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
## Desenha olhos que seguem look_dir (personagens).
@export var eyes: bool = false:
	set(value):
		eyes = value
		queue_redraw()

var _style := StyleBoxFlat.new()

var look_dir: Vector2 = Vector2.RIGHT:
	set(value):
		# Só redesenha quando a direção muda de verdade.
		if value.dot(look_dir) < 0.995:
			look_dir = value
			queue_redraw()


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
		Kind.HOUSE:
			_draw_house(h)
		Kind.TENT:
			_draw_tent(h)
		Kind.TREE:
			_draw_tree(h)
		Kind.MUSHROOM:
			_draw_mushroom(h)
		Kind.TOMBSTONE:
			_draw_tombstone(h)
		Kind.WALL:
			_draw_wall(h)
		Kind.FLAME:
			_draw_flame(h)
		Kind.BANNER:
			_draw_banner(h)
		Kind.CHARACTER:
			_draw_character(h)
		Kind.BARREL:
			_draw_barrel(h)
		Kind.POTION:
			_draw_potion(h)
	if eyes:
		_draw_eyes(h)
	_draw_accent(h)


func _outline_circle(radius: float) -> void:
	if outline_width > 0.0:
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 32, outline_color, outline_width)


func _outline_poly(points: PackedVector2Array) -> void:
	if outline_width <= 0.0:
		return
	var closed := points.duplicate()
	closed.append(points[0])
	draw_polyline(closed, outline_color, outline_width)


func _draw_eyes(h: Vector2) -> void:
	var dir := look_dir.normalized() if look_dir != Vector2.ZERO else Vector2.RIGHT
	# Personagem retangular: olhos no terço de cima; senão, no centro.
	var head := Vector2(0, -h.y * 0.45) if kind == Kind.CHARACTER else Vector2(0, -h.y * 0.1)
	var center := head + Vector2(dir.x * h.x * 0.3, dir.y * h.y * 0.08)
	var side := Vector2(h.x * 0.3, 0)
	var r := h.x * 0.2
	for s: float in [-1.0, 1.0]:
		var p := center + side * s
		draw_circle(p, r, Color(1, 1, 1))
		draw_circle(p + dir * r * 0.4, r * 0.55, Color(0.08, 0.02, 0.12))


func _draw_accent(h: Vector2) -> void:
	var top := Vector2(0, -h.y)
	match accent:
		Accent.CROWN:
			var w := h.x * 0.8
			var crown := PackedVector2Array([
				top + Vector2(-w, 4), top + Vector2(-w, -10), top + Vector2(-w * 0.5, -3),
				top + Vector2(0, -14), top + Vector2(w * 0.5, -3), top + Vector2(w, -10), top + Vector2(w, 4)])
			draw_colored_polygon(crown, accent_color)
			_outline_poly(crown)
		Accent.HAT:
			var hat := PackedVector2Array([top + Vector2(-h.x * 1.2, 6), top + Vector2(h.x * 0.3, -h.y * 1.4), top + Vector2(h.x * 1.2, 6)])
			draw_colored_polygon(hat, accent_color)
			_outline_poly(hat)
			draw_circle(top + Vector2(h.x * 0.3, -h.y * 1.4), 4.0, Color(1, 0.9, 0.4))
		Accent.HELMET:
			draw_rect(Rect2(top + Vector2(-h.x * 0.9, -2), Vector2(h.x * 1.8, h.y * 0.55)), accent_color)
			var plume := PackedVector2Array([top + Vector2(-4, -2), top + Vector2(0, -16), top + Vector2(4, -2)])
			draw_colored_polygon(plume, accent_color.lightened(0.4))
		Accent.HORNS:
			for s: float in [-1.0, 1.0]:
				var horn := PackedVector2Array([top + Vector2(s * h.x * 0.4, 6), top + Vector2(s * h.x * 1.1, -12), top + Vector2(s * h.x * 0.8, 6)])
				draw_colored_polygon(horn, accent_color)
		Accent.HOOD:
			draw_arc(Vector2.ZERO, h.x + 3.0, PI * 1.05, PI * 1.95, 16, accent_color, 6.0)


func _draw_house(h: Vector2) -> void:
	var wall := Rect2(Vector2(-h.x, -h.y * 0.2), Vector2(size.x, h.y * 1.2))
	draw_rect(wall, color)
	var roof := PackedVector2Array([Vector2(-h.x - 12, -h.y * 0.2), Vector2(0, -h.y - 10), Vector2(h.x + 12, -h.y * 0.2)])
	draw_colored_polygon(roof, secondary_color)
	_outline_poly(roof)
	draw_rect(Rect2(Vector2(-12, h.y * 0.35), Vector2(24, h.y * 0.65)), secondary_color.darkened(0.3))
	draw_circle(Vector2(-h.x * 0.55, h.y * 0.25), 9.0, accent_color)
	draw_circle(Vector2(h.x * 0.55, h.y * 0.25), 9.0, accent_color)
	draw_rect(wall, outline_color, false, outline_width)


func _draw_tent(h: Vector2) -> void:
	var tent := PackedVector2Array([Vector2(0, -h.y), Vector2(h.x, h.y), Vector2(-h.x, h.y)])
	draw_colored_polygon(tent, color)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -h.y * 0.1), Vector2(h.x * 0.3, h.y), Vector2(-h.x * 0.3, h.y)]), secondary_color)
	_outline_poly(tent)
	draw_line(Vector2(0, -h.y), Vector2(0, -h.y - 16), outline_color, 2.0)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -h.y - 16), Vector2(14, -h.y - 11), Vector2(0, -h.y - 6)]), accent_color)


func _draw_tree(h: Vector2) -> void:
	draw_rect(Rect2(Vector2(-h.x * 0.15, 0), Vector2(h.x * 0.3, h.y)), secondary_color)
	draw_circle(Vector2(0, -h.y * 0.25), h.x, color)
	draw_circle(Vector2(-h.x * 0.35, -h.y * 0.45), h.x * 0.25, color.lightened(0.25))
	_outline_circle_at(Vector2(0, -h.y * 0.25), h.x)


func _draw_mushroom(h: Vector2) -> void:
	draw_rect(Rect2(Vector2(-h.x * 0.25, -h.y * 0.1), Vector2(h.x * 0.5, h.y * 1.1)), secondary_color)
	draw_arc(Vector2(0, -h.y * 0.1), h.x, PI, TAU, 24, color, h.y * 0.5)
	draw_circle(Vector2(-h.x * 0.4, -h.y * 0.45), h.x * 0.13, accent_color)
	draw_circle(Vector2(h.x * 0.3, -h.y * 0.6), h.x * 0.1, accent_color)


func _draw_tombstone(h: Vector2) -> void:
	var body := Rect2(Vector2(-h.x, -h.y * 0.4), Vector2(size.x, h.y * 1.4))
	draw_rect(body, color)
	draw_circle(Vector2(0, -h.y * 0.4), h.x, color)
	draw_rect(Rect2(Vector2(-h.x * 1.3, h.y * 0.85), Vector2(h.x * 2.6, h.y * 0.15)), secondary_color)
	draw_rect(Rect2(Vector2(-4, -h.y * 0.75), Vector2(8, h.y * 0.8)), secondary_color)
	draw_rect(Rect2(Vector2(-h.x * 0.4, -h.y * 0.55), Vector2(h.x * 0.8, 8)), secondary_color)


func _draw_wall(h: Vector2) -> void:
	draw_rect(Rect2(-h, size), color)
	# Ameias no topo.
	var merlon := 18.0
	var x := -h.x
	while x < h.x - 1.0:
		draw_rect(Rect2(Vector2(x, -h.y - 12.0), Vector2(minf(merlon, h.x - x), 12.0)), color)
		x += merlon * 2.0
	# Linhas dos tijolos.
	var y := -h.y + 14.0
	while y < h.y:
		draw_line(Vector2(-h.x, y), Vector2(h.x, y), secondary_color, 1.5)
		y += 14.0
	_outline_poly(PackedVector2Array([-h, Vector2(h.x, -h.y), h, Vector2(-h.x, h.y)]))


func _draw_flame(h: Vector2) -> void:
	for layer: int in 3:
		var k := 1.0 - layer * 0.3
		var col: Color = [color, accent_color, Color(1, 1, 0.85)][layer]
		var pts := PackedVector2Array([
			Vector2(0, -h.y * k), Vector2(h.x * 0.8 * k, -h.y * 0.1 * k), Vector2(h.x * 0.6 * k, h.y * 0.6),
			Vector2(0, h.y), Vector2(-h.x * 0.6 * k, h.y * 0.6), Vector2(-h.x * 0.8 * k, -h.y * 0.1 * k)])
		draw_colored_polygon(pts, col)


func _draw_banner(h: Vector2) -> void:
	draw_line(Vector2(0, h.y), Vector2(0, -h.y), secondary_color, 4.0)
	draw_circle(Vector2(0, -h.y), 4.0, accent_color)
	var w := size.x
	var fh := size.y * 0.55
	var flag := PackedVector2Array([Vector2(2, -h.y + 4), Vector2(2 + w, -h.y + 4), Vector2(2 + w, -h.y + fh),
		Vector2(2 + w * 0.5, -h.y + fh - 14), Vector2(2, -h.y + fh)])
	draw_colored_polygon(flag, color)
	_outline_poly(flag)
	draw_circle(Vector2(2 + w * 0.5, -h.y + fh * 0.45), w * 0.18, accent_color)


## Corpo de personagem: retângulo vertical com cantos arredondados e parte de baixo mais escura.
func _draw_character(h: Vector2) -> void:
	var body := Rect2(-h, size)
	var corner := minf(h.x, h.y) * 0.45
	var style := _style
	style.bg_color = color
	style.set_corner_radius_all(int(corner))
	style.border_color = outline_color
	style.set_border_width_all(int(outline_width))
	draw_style_box(style, body)
	draw_rect(Rect2(Vector2(-h.x + outline_width, h.y * 0.25), Vector2(size.x - outline_width * 2.0, h.y * 0.75 - outline_width)), color.darkened(0.25))


func _draw_barrel(h: Vector2) -> void:
	draw_rect(Rect2(-h, size), color)
	draw_rect(Rect2(Vector2(-h.x, -h.y * 0.55), Vector2(size.x, size.y * 0.12)), secondary_color)
	draw_rect(Rect2(Vector2(-h.x, h.y * 0.4), Vector2(size.x, size.y * 0.12)), secondary_color)
	draw_line(Vector2(-h.x * 0.35, -h.y), Vector2(-h.x * 0.35, h.y), color.darkened(0.2), 2.0)
	draw_line(Vector2(h.x * 0.35, -h.y), Vector2(h.x * 0.35, h.y), color.darkened(0.2), 2.0)
	_outline_poly(PackedVector2Array([-h, Vector2(h.x, -h.y), h, Vector2(-h.x, h.y)]))


func _draw_potion(h: Vector2) -> void:
	draw_circle(Vector2(0, h.y * 0.25), h.x, color)
	draw_rect(Rect2(Vector2(-h.x * 0.3, -h.y), Vector2(h.x * 0.6, h.y * 0.8)), color.lightened(0.3))
	draw_rect(Rect2(Vector2(-h.x * 0.4, -h.y - 4.0), Vector2(h.x * 0.8, 5.0)), secondary_color)
	draw_circle(Vector2(-h.x * 0.35, h.y * 0.1), h.x * 0.25, Color(1, 1, 1, 0.7))
	_outline_circle_at(Vector2(0, h.y * 0.25), h.x)


func _outline_circle_at(center: Vector2, radius: float) -> void:
	if outline_width > 0.0:
		draw_arc(center, radius, 0.0, TAU, 32, outline_color, outline_width)
