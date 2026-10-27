class_name BossPhase
extends Resource
## Uma fase do boss. A fase ativa é a última cujo limiar de vida já foi atingido.

## Fração de vida (1.0 = começo) em que esta fase começa.
@export_range(0.0, 1.0) var health_threshold: float = 1.0
@export var speed_multiplier: float = 1.0
## Velocidade dos ataques: 1.3 = telegraph e recuperação 30% mais curtos.
@export var attack_speed: float = 1.0
@export var attack_interval: float = 1.2
@export var attacks: Array[Ability] = []
@export var attack_weights: Array[float] = []
