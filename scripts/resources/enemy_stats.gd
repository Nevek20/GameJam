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
## Não é interrompido por golpes enquanto ataca (elites e boss).
@export var armor_while_attacking: bool = false

@export_group("IA")
@export var aggro_range: float = 700.0
## Intervalo entre decisões da IA (procura de alvo, dash etc.).
@export var think_interval: float = 0.3
## Pausa mínima entre ataques.
@export var attack_interval: float = 1.1
## Ataques possíveis (cada um é um Ability) e seus pesos.
@export var attacks: Array[Ability] = []
@export var attack_weights: Array[float] = []

@export_group("Elite")
## Chance (por decisão) de dar dash.
@export_range(0.0, 1.0) var dash_chance: float = 0.0
@export var dash_distance: float = 180.0
@export var dash_duration: float = 0.2
@export var dash_cooldown: float = 2.0
## Chance de erguer a guarda quando o alvo ataca por perto.
@export_range(0.0, 1.0) var block_chance: float = 0.0
@export var block_duration: float = 0.8
@export var block_damage_multiplier: float = 0.15
@export var block_cooldown: float = 2.5

@export_group("Recompensa")
## Se true, conta para heroísmo ao ser derrotado (quando o jogador enfrenta o exército).
@export var counts_for_heroism: bool = true
