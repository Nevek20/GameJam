class_name ParticlePreset
extends Resource
## Configuração de um estouro de partículas (aplicada em um CPUParticles2D do pool).

@export var amount: int = 12
@export var lifetime: float = 0.45
@export var speed_min: float = 80.0
@export var speed_max: float = 240.0
## Abertura em graus (180 = todas as direções).
@export_range(0.0, 180.0) var spread: float = 180.0
@export var scale_min: float = 3.0
@export var scale_max: float = 6.0
@export var damping: float = 300.0
@export var gravity: Vector2 = Vector2.ZERO
@export_range(0.0, 1.0) var explosiveness: float = 1.0
