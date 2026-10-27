class_name BarrelConfig
extends Resource
## Barris destrutíveis e a poção que eles podem soltar.

@export_group("Barril")
@export var max_health: float = 30.0
## Tamanho do barril (largura x altura) e da colisão.
@export var body_size: Vector2 = Vector2(34, 42)
@export var collision_size: Vector2 = Vector2(30, 18)
## Máximo de barris (usa os primeiros pontos do BarrelSpawner).
@export var max_barrels: int = 12
## Os barris voltam no começo da vez de cada personagem.
@export var respawn_each_phase: bool = true
@export var body_color: Color = Color(0.62, 0.4, 0.25)
@export var band_color: Color = Color(0.3, 0.2, 0.15)
## Arte do barril (vazio = placeholder).
@export var texture: Texture2D

@export_group("Poção")
## Chance (0 a 1) de soltar uma poção ao quebrar.
@export_range(0.0, 1.0) var drop_chance: float = 0.5
## true = cura uma porcentagem da vida máxima; false = cura um valor fixo.
@export var heal_is_percent: bool = false
@export var heal_amount: float = 30.0
@export_range(0.0, 1.0) var heal_percent: float = 0.25
@export var potion_size: Vector2 = Vector2(18, 24)
@export var potion_color: Color = Color(1, 0.3, 0.5)
## Arte da poção (vazio = placeholder).
@export var potion_texture: Texture2D
## Some depois deste tempo (0 = fica até ser pega).
@export var potion_lifetime: float = 0.0

@export_group("Áudio")
@export var sfx_hit: StringName = &"barrel_hit"
@export var sfx_break: StringName = &"barrel_break"
@export var sfx_potion: StringName = &"potion_pickup"
