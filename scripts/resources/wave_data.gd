class_name WaveData
extends Resource
## Uma onda de inimigos.
## TODO: misturar elites na onda quando o inimigo elite existir.

@export var delay_before: float = 1.0
@export var enemy: EnemyStats
@export var count: int = 3
