class_name ReviveConfig
extends Resource
## Personagem caído e revive (só na luta final com ajudante vivo).

## Quanto tempo fica caído antes de morrer de vez.
@export var downed_time: float = 10.0
## Tempo segurando a tecla de interação para reviver.
@export var revive_time: float = 2.0
## Distância máxima para reviver (multiplicada pela escala do personagem).
@export var revive_distance: float = 90.0
## Vida ao reviver (fração da vida máxima).
@export_range(0.05, 1.0) var revive_health: float = 0.4
## Invulnerabilidade logo depois de reviver.
@export var invulnerability_after: float = 1.5
## Se soltar a tecla, o progresso volta nesta velocidade (fração por segundo).
@export var progress_decay: float = 1.0
@export var ring_color: Color = Color(0.5, 1, 0.6)
