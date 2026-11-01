class_name MatchConfig
extends Resource
## Parâmetros da partida: ordem dos personagens, tempos, ondas, QTE e boss.

@export_group("Personagens")
## [Personagem 1, Personagem 2]
@export var characters: Array[CharacterStats] = []
## Duração da gameplay de cada personagem (segundos).
@export var character_durations: Array[float] = [120.0, 120.0]
## Pausa o cronômetro durante diálogo e QTE.
@export var pause_timer_during_dialogue: bool = true

@export_group("Moradores")
## Com inimigo a menos desta distância do jogador, as casas não abrem conversa (nada de diálogo no meio da luta).
@export var house_block_radius: float = 520.0
@export var qte: QTEConfig

@export_group("Exército")
## O exército chega (e aparece a pergunta enfrentar/aliar) depois deste tempo de fase, em segundos.
@export var army_arrival_time: float = 45.0
## Chega antes se todas as casas já foram resolvidas.
@export var army_arrives_when_houses_done: bool = true
## Mesmo com as casas resolvidas, espera pelo menos isto (segundos) depois do começo da fase.
@export var army_min_delay: float = 3.0
## Os inimigos surgem nos cantos (Markers/ArmySpawns), mas nunca a menos desta distância do herói.
@export var spawn_min_distance: float = 600.0
## Quantos cantos (os mais perto do herói) recebem inimigos em cada onda.
@export var spawn_corner_count: int = 2
## Ondas ao enfrentar o exército.
@export var confront_waves: Array[WaveData] = []
## Ondas de cavaleiros do reino ao se aliar.
@export var alliance_waves: Array[WaveData] = []
## Intervalo entre ondas de cavaleiros quando aliado.
@export var alliance_wave_interval: float = 14.0
## Personagem 1 aliado: as ondas de cavaleiros se repetem até o tempo acabar.
@export var p1_alliance_loops: bool = true
@export var max_active_enemies: int = 14

@export_group("Morte do Personagem 1")
## GDD 4.2: se o P1 morrer, os inimigos ficam mais fortes para o P2.
@export var death_enemy_health_multiplier: float = 1.3
@export var death_enemy_damage_multiplier: float = 1.25
## Os inimigos fortalecidos ficam um pouco maiores (aviso visual).
@export var death_enemy_scale: float = 1.12

@export_group("Boss")
@export var knight_boss: BossStats
## Ajustes do personagem que vira boss (a IA vem do CharacterStats.ai_profile).
@export var character_boss_profile: BossCharacterProfile
## Caído e revive na luta final com ajudante.
@export var revive: ReviveConfig
