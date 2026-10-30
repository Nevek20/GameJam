class_name EndingCard
extends Control
## Cartão de final genérico: imagem (ou placeholder), título e texto.

var _tween: Tween

@onready var _image: TextureRect = %Image
@onready var _placeholder: ColorRect = %Placeholder
@onready var _tag: Label = %Tag
@onready var _title: Label = %Title
@onready var _text: RichTextLabel = %Text
@onready var _content: Control = %Content


func show_ending(tag: String, title: String, text: String, image: Texture2D, tint: Color) -> void:
	_tag.text = tag
	_title.text = title
	_text.text = text
	_image.texture = image
	_image.visible = image != null
	_placeholder.visible = image == null
	# Placeholder psicodélico tingido com a cor do final (some quando há imagem).
	var mat := _placeholder.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter(&"color_a", tint.darkened(0.7))
		mat.set_shader_parameter(&"color_b", tint.darkened(0.3))
		mat.set_shader_parameter(&"color_c", tint.lightened(0.25))
	show()
	_content.modulate.a = 0.0
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_content, "modulate:a", 1.0, 0.5)
