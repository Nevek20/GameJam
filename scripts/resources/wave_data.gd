class_name WaveData
extends Resource
## Uma onda de inimigos.

@export var delay_before: float = 1.0
@export var primary_enemy: EnemyStats
@export var primary_count: int = 3
@export var elite_enemy: EnemyStats
@export var elite_count: int = 0
## Distância aleatória em volta do ponto de surgimento.
@export var spawn_spread: float = 60.0

## Inimigos que chegam em grupos (Olho seco, Coguolho, Siameses...).
@export var groups: Array[EnemyGroup] = []
