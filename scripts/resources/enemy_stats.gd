class_name EnemyStats
extends Resource
## Parâmetros de um tipo de inimigo (Sombra, Olho seco, Coguolho, Siameses, elite, cavaleiro, boss).

## CHASE: persegue e ataca de perto (Sombra, Coguolho, elite, cavaleiro, boss).
## ORBIT_DASH: voa em volta do alvo e, de tempos em tempos, dá um dash em cima dele (Olho seco).
## ORBIT_WALL: voa em volta do alvo sem atacar e bloqueia o corpo dos heróis (Siameses).
enum Behavior { CHASE, ORBIT_DASH, ORBIT_WALL }

@export var id: StringName = &"shadow"
@export var skin: EnemySkin
## Tamanho do corpo (largura x altura): desenho placeholder e área que recebe dano.
@export var body_size: Vector2 = Vector2(36, 64)
## Colisão com o cenário: retângulo nos pés (largura x altura).
@export var collision_size: Vector2 = Vector2(30, 18)
## Ponto de onde saem golpes e projéteis, relativo ao centro do corpo (nó AttackOrigin).
@export var attack_origin_offset: Vector2 = Vector2.ZERO
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
## Distância em que para de andar até o alvo (0 = automático, 70% do maior alcance).
@export var preferred_distance: float = 0.0
## Pausa mínima entre ataques.
@export var attack_interval: float = 1.1
## Ataques possíveis (cada um é um Ability) e seus pesos.
@export var attacks: Array[Ability] = []
@export var attack_weights: Array[float] = []

@export_group("Voo em volta do alvo (Olho seco, Siameses)")
@export var behavior: Behavior = Behavior.CHASE
## Distância do alvo enquanto gira em volta.
@export var orbit_radius: float = 160.0
## Velocidade do giro (graus por segundo). O sentido é sorteado ao nascer.
@export var orbit_speed: float = 70.0
## ORBIT_DASH: tempo girando antes de cada dash (sorteado entre os dois valores).
@export var orbit_time_min: float = 1.5
@export var orbit_time_max: float = 3.0
## Altura do desenho acima da sombra (inimigos voadores).
@export var fly_height: float = 0.0
## Bloqueia o corpo dos heróis como uma parede (projéteis passam). Ver Layers.WALL_ENEMY.
@export var blocks_heroes: bool = false

@export_group("Ao morrer")
## Nuvem de dano deixada ao morrer (Coguolho). Vazio = nada.
@export var death_cloud: DeathCloudConfig

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
## Só ergue a guarda se o alvo atacar a esta distância ou menos.
@export var block_trigger_range: float = 160.0

@export_group("Recompensa")
## Se true, conta para heroísmo ao ser derrotado (quando o jogador enfrenta o exército).
@export var counts_for_heroism: bool = true
