class_name EnemyStats
extends Resource
## Parâmetros de um tipo de inimigo (soldado, elite, cavaleiro do reino, boss).

@export var id: StringName = &"soldier"
@export var skin: EnemySkin
@export var body_radius: float = 17.0
@export var sprite_scale: Vector2 = Vector2.ONE

@export_group("Vida e movimento")
@export var max_health: float = 40.0
@export var move_speed: float = 150.0
@export var acceleration: float = 1200.0
@export var friction: float = 1600.0
## 0 = sofre knockback total, 1 = imune.
@export_range(0.0, 1.0) var knockback_resistance: float = 0.0
@export var hurt_stun: float = 0.25

@export_group("IA")
@export var aggro_range: float = 700.0
## Intervalo entre decisões da IA (procura de alvo, dash etc.).
@export var think_interval: float = 0.3
## Pausa mínima entre ataques.
@export var attack_interval: float = 1.1
## Ataques possíveis (cada um é um Ability).
@export var attacks: Array[Ability] = []

## TODO (elite, seção 4.3/9): chance de dash, defesa e variação de ataque.
## Hoje o inimigo só persegue e usa o primeiro ataque da lista que alcança o alvo.

@export_group("Recompensa")
## Se true, conta para heroísmo ao ser derrotado (quando o jogador enfrenta o exército).
@export var counts_for_heroism: bool = true
