@tool
class_name PropVisual
extends Node2D
## Visual de cenário (muralha, fogo, bandeira): mostra a textura se houver, senão o placeholder.
## Para colocar a arte: arraste a imagem no campo "texture" (o placeholder some sozinho).

@export var texture: Texture2D:
	set(value):
		texture = value
		_apply()
## Balanço em graus (bandeiras). 0 = parado.
@export var sway_degrees: float = 0.0
## Tremulação de escala (fogo). 0 = parado.
@export var flicker: float = 0.0


func _ready() -> void:
	_apply()
	if Engine.is_editor_hint():
		return
	# Animações leves por Tween (sem _process).
	if sway_degrees > 0.0:
		var sway := create_tween().set_loops()
		var period := randf_range(1.0, 1.6)
		sway.tween_property(self, "rotation", deg_to_rad(sway_degrees), period).set_trans(Tween.TRANS_SINE)
		sway.tween_property(self, "rotation", deg_to_rad(-sway_degrees), period).set_trans(Tween.TRANS_SINE)
	if flicker > 0.0:
		var fire := create_tween().set_loops()
		var step := randf_range(0.1, 0.18)
		fire.tween_property(self, "scale", Vector2(1.0 - flicker * 0.5, 1.0 + flicker), step)
		fire.tween_property(self, "scale", Vector2(1.0 + flicker * 0.3, 1.0 - flicker * 0.4), step)


func _apply() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	var placeholder := get_node_or_null("Placeholder") as Node2D
	if sprite:
		sprite.texture = texture
		sprite.visible = texture != null
	if placeholder:
		placeholder.visible = texture == null
