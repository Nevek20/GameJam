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
@export var qte: QTEConfig

@export_group("Exército")
## Ondas ao enfrentar o exército.
@export var confront_waves: Array[WaveData] = []
## Ondas de cavaleiros do reino ao se aliar.
@export var alliance_waves: Array[WaveData] = []
## Intervalo entre ondas de cavaleiros quando aliado.
@export var alliance_wave_interval: float = 14.0
## Personagem 1 aliado: as ondas de cavaleiros se repetem até o tempo acabar.
@export var p1_alliance_loops: bool = true
@export var max_active_enemies: int = 14

@export_group("Boss")
@export var knight_boss: BossStats
## Ajustes do personagem que vira boss (a IA vem do CharacterStats.ai_profile).
@export var character_boss_profile: BossCharacterProfile
## Personagem 2 vai para o boss assim que a luta com o exército termina (senão, quando o tempo acaba).
@export var p2_boss_after_encounter: bool = true
