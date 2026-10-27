class_name EntityVisual
extends Node2D
## Nó visual separado da física: troca de sprite não mexe em hitbox nem timing.
## Prioridade: SpriteFrames (AnimatedSprite2D) > Texture2D (Sprite2D) > placeholder.

@export var placeholder: PlaceholderShape
@export var sprite: Sprite2D
@export var animated: AnimatedSprite2D

var base_scale: Vector2 = Vector2.ONE
## Deslocamento do sprite (pixels da textura). Mexe só no desenho, nunca na hitbox.
var sprite_offset: Vector2 = Vector2.ZERO
var _flipped: bool = false
var _flash_tween: Tween
var _squash_tween: Tween


func apply_look(texture: Texture2D, frames: SpriteFrames, body_color: Color, accent_color: Color,
		accent: PlaceholderShape.Accent, radius: float, sprite_scale: Vector2, offset: Vector2 = Vector2.ZERO) -> void:
	sprite_offset = offset
	placeholder.color = body_color
	placeholder.accent_color = accent_color
	placeholder.accent = accent
	placeholder.size = Vector2(radius * 2.0, radius * 2.0)
	animated.visible = frames != null
	sprite.visible = frames == null and texture != null
	placeholder.visible = frames == null and texture == null
	if frames:
		animated.sprite_frames = frames
		animated.scale = sprite_scale
	elif texture:
		sprite.texture = texture
		sprite.scale = sprite_scale
	modulate = Color.WHITE
	scale = base_scale
	_apply_offset()


## Toca a animação se ela existir (sem erro quando ainda não há sprites).
## restart: recomeça mesmo se já estiver tocando (ataques repetidos).
func play(anim: StringName, fallback: StringName = &"", restart: bool = false) -> void:
	if not animated.visible or animated.sprite_frames == null:
		return
	var frames := animated.sprite_frames
	if not frames.has_animation(anim):
		if fallback == &"" or not frames.has_animation(fallback):
			return
		anim = fallback
	if restart or animated.animation != anim or not animated.is_playing():
		animated.play(anim)
		if restart:
			animated.frame = 0


func face(direction: Vector2) -> void:
	if direction == Vector2.ZERO:
		return
	placeholder.look_dir = direction
	var flip := direction.x < 0.0
	if flip == _flipped:
		return
	_flipped = flip
	sprite.flip_h = flip
	animated.flip_h = flip
	_apply_offset()


# O offset também espelha, para o corpo não "pular" ao virar.
func _apply_offset() -> void:
	var o := Vector2(-sprite_offset.x if _flipped else sprite_offset.x, sprite_offset.y)
	sprite.offset = o
	animated.offset = o


func flash(tint: Color = Color.WHITE) -> void:
	var c := Juice.cfg()
	if c == null or not c.enabled or not c.flash_enabled:
		return
	if _flash_tween:
		_flash_tween.kill()
	modulate = Color(tint.r * c.flash_intensity, tint.g * c.flash_intensity, tint.b * c.flash_intensity)
	_flash_tween = create_tween()
	_flash_tween.tween_property(self, "modulate", Color.WHITE, c.flash_duration)


func squash(amount: Vector2) -> void:
	var c := Juice.cfg()
	if c == null or not c.enabled or not c.squash_enabled:
		return
	if _squash_tween:
		_squash_tween.kill()
	scale = base_scale * amount
	_squash_tween = create_tween()
	_squash_tween.tween_property(self, "scale", base_scale, c.squash_duration) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func reset_effects() -> void:
	if _flash_tween:
		_flash_tween.kill()
	if _squash_tween:
		_squash_tween.kill()
	modulate = Color.WHITE
	scale = base_scale
