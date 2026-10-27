class_name BossCharacterProfile
extends Resource
## Ajustes aplicados a um personagem jogável quando ele vira boss (usa o próprio moveset).

@export var health_multiplier: float = 3.5
@export var damage_multiplier: float = 0.8
@export var speed_multiplier: float = 0.85
## Anticipação maior para os ataques serem telegrafados e justos.
@export var windup_multiplier: float = 2.2
@export var cooldown_multiplier: float = 1.6
## Velocidade (graus/s) com que o feixe do boss acompanha o jogador.
@export var aim_turn_speed: float = 70.0
