class_name Afterimage
extends Node2D
## "Fantasma" do rastro do dash (pool). Copia o sprite atual ou desenha o placeholder.

var _texture: Texture2D
var _flip: bool = false
## Deslocamento do desenho (o mesmo do sprite, que põe o personagem em cima dos pés).
var _offset: Vector2 = Vector2.ZERO
var _radius: float = 16.0
var _color: Color = Color.WHITE
var _tween: Tween


func copy_from(visual: EntityVisual, tint: Color, lifetime: float) -> void:
	global_position = visual.global_position
	scale = visual.scale
	_color = tint
	_texture = null
	_offset = Vector2.ZERO
	if visual.animated.visible and visual.animated.sprite_frames:
		_texture = visual.animated.sprite_frames.get_frame_texture(visual.animated.animation, visual.animated.frame)
		_flip = visual.animated.flip_h
		_offset = visual.animated.offset
		scale *= visual.animated.scale
	elif visual.sprite.visible:
		_texture = visual.sprite.texture
		_flip = visual.sprite.flip_h
		_offset = visual.sprite.offset
		scale *= visual.sprite.scale
	_radius = visual.placeholder.size.x * 0.5
	modulate = Color(tint, 0.55)
	queue_redraw()
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, lifetime)
	_tween.tween_callback(_release)


func on_pool_release() -> void:
	if _tween:
		_tween.kill()


func _draw() -> void:
	if _texture:
		var size := _texture.get_size()
		var rect := Rect2(-size * 0.5 + _offset, size)
		if _flip:
			# Espelhado em volta do próprio centro (o offset já vem espelhado do EntityVisual).
			rect = Rect2(Vector2(size.x * 0.5 + _offset.x, -size.y * 0.5 + _offset.y), Vector2(-size.x, size.y))
		draw_texture_rect(_texture, rect, false)
	else:
		draw_circle(Vector2.ZERO, _radius, Color.WHITE)


func _release() -> void:
	ObjectPool.release_node(self)
