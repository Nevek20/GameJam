class_name MatchConfig
extends Resource
## Parâmetros da partida: ordem dos personagens, tempos, ondas e QTE.

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
## TODO: ondas de cavaleiros do reino quando o jogador se alia (seção 4.3).
@export var confront_waves: Array[WaveData] = []
@export var max_active_enemies: int = 14

## TODO (seção 4.5/8): parâmetros do boss (vida, fases, ataques, intervalos).
