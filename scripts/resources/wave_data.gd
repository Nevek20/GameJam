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

@export_group("Inimigos rápidos (em grupos)")
@export var fast_enemy: EnemyStats
## Quantos grupos de inimigos rápidos nesta onda.
@export var fast_groups: int = 0
## Quantos inimigos rápidos em cada grupo (nascem juntos).
@export var fast_group_size: int = 3
## Quão espalhado fica cada grupo.
@export var fast_group_spread: float = 40.0
