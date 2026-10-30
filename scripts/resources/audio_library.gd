class_name AudioLibrary
extends Resource
## Mapa nome -> AudioStream. Campo vazio = silêncio (sem erro).
## Para colocar um som: arraste o arquivo para o valor da chave no Inspector.

@export var sfx: Dictionary[StringName, AudioStream] = {}
@export var music: Dictionary[StringName, AudioStream] = {}
## Ajuste individual de volume de efeitos (dB), para equilibrar arquivos de origens diferentes.
@export var sfx_volume_db: Dictionary[StringName, float] = {}
## Quantos sons simultâneos.
@export var sfx_voices: int = 12
## Variação aleatória de pitch para sons repetidos não cansarem.
@export var pitch_variation: float = 0.08
@export var music_fade: float = 0.8
