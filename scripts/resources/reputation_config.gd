class_name ReputationConfig
extends Resource
## Ganhos, perdas e limiares de heroísmo. Nada disso fica no código.

@export var starting_heroism: float = 50.0
@export var max_heroism: float = 100.0
@export var rescue_gain: float = 15.0
@export var confront_gain: float = 10.0
## Por inimigo do exército derrotado enquanto enfrenta.
@export var kill_gain: float = 1.0
@export var loot_loss: float = 12.0
## Heroísmo mínimo para o desfecho Positivo (abaixo = Questionável).
@export var positive_threshold: float = 60.0
