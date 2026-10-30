class_name BossStats
extends EnemyStats
## Boss = inimigo com fases e duas skins (exército / reino), mesmo moveset.

@export var army_skin: EnemySkin
@export var kingdom_skin: EnemySkin
@export var phases: Array[BossPhase] = []
## Pausa invencível ao trocar de fase (rugido).
@export var phase_change_duration: float = 1.0
## Quantas vezes seguidas o mesmo ataque pode sair (1 = nunca repete em sequência).
@export var max_same_attack_in_row: int = 1
