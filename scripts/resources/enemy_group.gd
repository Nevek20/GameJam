class_name EnemyGroup
extends Resource
## Grupo de inimigos de uma onda: nascem juntos, cada grupo num ponto de surgimento.
## Ex.: Olho seco em grupos de 3; Siameses em grupos de 3 (formam o arco-parede).

@export var enemy: EnemyStats
## Quantos grupos nesta onda.
@export var groups: int = 1
## Quantos inimigos em cada grupo.
@export var group_size: int = 3
## Quão espalhado fica cada grupo.
@export var spread: float = 40.0
