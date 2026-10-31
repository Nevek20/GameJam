class_name DeathCloudConfig
extends Resource
## Nuvem que um inimigo deixa ao morrer (Coguolho): área que causa dano por tick a quem estiver dentro.

@export var radius: float = 90.0
## Quanto tempo a nuvem fica no chão (segundos).
@export var duration: float = 3.0
## Atraso antes de começar a causar dano (dá tempo de sair).
@export var arm_delay: float = 0.35
@export var tick_interval: float = 0.5
@export var damage_per_tick: float = 6.0
## Acerta também os outros inimigos (false = só os heróis).
@export var hurts_enemies: bool = false
@export var color: Color = Color(0.55, 0.9, 0.35, 0.45)
@export var sfx_tick: StringName = &""
