@tool
class_name MapBoundary
extends Node2D
## Muralha em volta do mapa: é o limite jogável. Nada passa por ela (jogador, inimigos,
## boss e projéteis colidem com a camada world). Os limites da câmera vêm daqui.
## Para mudar o tamanho do mapa: altere map_size (o retângulo aparece no editor).

## Tamanho da área jogável (por dentro das muralhas), a partir da posição deste nó.
@export var map_size: Vector2 = Vector2(3200, 2000):
	set(value):
		map_size = value
		queue_redraw()
## Espessura da colisão de cada lado (parede invisível atrás das muralhas visíveis).
@export var wall_thickness: float = 200.0
## Desenho da muralha como MOLDURA (9-slice): os cantos ficam iguais e as laterais repetem.
## Se estiver vazio, usa os segmentos (segment_scene).
@export var frame_texture: Texture2D
## Margens da moldura na imagem (pixels da textura): esquerda, cima, direita, baixo.
@export var frame_margins: Vector4i = Vector4i(150, 150, 150, 150)
## Quanto a moldura passa para FORA da área jogável (as pedras ficam fora, a terra fica dentro).
@export var frame_outset: float = 55.0
## Tamanho da moldura no jogo (1 = pixels da textura).
@export var frame_scale: float = 1.0
## Cena de um segmento de muralha (visual + colisão), usada quando não há frame_texture.
@export var segment_scene: PackedScene
## Comprimento de cada segmento (o mesmo tamanho da cena prop_wall).
@export var segment_length: float = 160.0
## Quanto da muralha a câmera mostra além da área jogável.
@export var camera_margin: Vector2 = Vector2(40, 90)
## Cor da prévia no editor.
@export var editor_color: Color = Color(1, 0.6, 0.2, 0.9)


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_build_collision()
	if frame_texture:
		_build_frame()
	else:
		_build_segments()


## Área jogável em coordenadas globais.
func inner_rect() -> Rect2:
	return Rect2(global_position, map_size)


## Limites da câmera: área jogável mais um pouco da muralha.
func camera_rect() -> Rect2:
	return inner_rect().grow_individual(camera_margin.x, camera_margin.y, camera_margin.x, camera_margin.x)


func _build_collision() -> void:
	var body := StaticBody2D.new()
	body.name = "Collision"
	body.collision_layer = Layers.WORLD
	body.collision_mask = 0
	add_child(body)
	var t := wall_thickness
	var w := map_size.x
	var h := map_size.y
	for r: Rect2 in [Rect2(-t, -t, w + t * 2.0, t), Rect2(-t, h, w + t * 2.0, t), Rect2(-t, 0, t, h), Rect2(w, 0, t, h)]:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = r.size
		shape.shape = rect
		shape.position = r.get_center()
		body.add_child(shape)


func _build_frame() -> void:
	var frame := NinePatchRect.new()
	frame.name = "Frame"
	frame.texture = frame_texture
	frame.patch_margin_left = frame_margins.x
	frame.patch_margin_top = frame_margins.y
	frame.patch_margin_right = frame_margins.z
	frame.patch_margin_bottom = frame_margins.w
	frame.axis_stretch_horizontal = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	frame.axis_stretch_vertical = NinePatchRect.AXIS_STRETCH_MODE_TILE_FIT
	frame.draw_center = false
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Atrás dos personagens e na frente do chão.
	frame.z_index = -7
	frame.scale = Vector2.ONE * frame_scale
	frame.position = Vector2.ONE * -frame_outset
	frame.size = (map_size + Vector2.ONE * frame_outset * 2.0) / frame_scale
	add_child(frame)


func _build_segments() -> void:
	if segment_scene == null:
		return
	var k := GameScale.of(GameScale.Kind.SCENERY)
	var step := segment_length * k
	var half := 20.0 * k
	# Horizontais (em cima e embaixo).
	var x := step * 0.5
	while x < map_size.x + step * 0.5:
		_add_segment(Vector2(x, -half), 0.0, k)
		_add_segment(Vector2(x, map_size.y + half), 0.0, k)
		x += step
	# Verticais (esquerda e direita).
	var y := step * 0.5
	while y < map_size.y + step * 0.5:
		_add_segment(Vector2(-half, y), PI * 0.5, k)
		_add_segment(Vector2(map_size.x + half, y), PI * 0.5, k)
		y += step


func _add_segment(pos: Vector2, angle: float, k: float) -> void:
	var seg := segment_scene.instantiate() as Node2D
	seg.position = pos
	seg.rotation = angle
	seg.scale = Vector2.ONE * k
	add_child(seg)


func _draw() -> void:
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(Vector2.ZERO, map_size), editor_color, false, 6.0)
	draw_string(ThemeDB.fallback_font, Vector2(16, 40), "Área jogável (MapBoundary.map_size)", HORIZONTAL_ALIGNMENT_LEFT, -1, 28, editor_color)
