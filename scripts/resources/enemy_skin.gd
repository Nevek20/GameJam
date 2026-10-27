class_name EnemySkin
extends Resource
## Aparência trocável de um inimigo (ex.: cavaleiro com skin do exército ou do reino).

@export var body_color: Color = Color(0.8, 0.2, 0.25)
@export var accent_color: Color = Color(0.2, 0.05, 0.1)
@export var placeholder_accent: PlaceholderShape.Accent = PlaceholderShape.Accent.HELMET
@export var texture: Texture2D
@export var sprite_frames: SpriteFrames
## Posição do desenho em relação ao corpo (pixels da textura).
@export var sprite_offset: Vector2 = Vector2.ZERO
@export var name_key: StringName = &""
