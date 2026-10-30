class_name UIConfig
extends Resource
## Tempos e velocidades da interface.

## Letras por segundo do efeito de máquina de escrever no diálogo.
@export var typewriter_speed: float = 55.0
## Tempo da lápide durante o jogo (Enter pula).
@export var tombstone_duration: float = 3.0
@export var banner_duration: float = 2.2
## Créditos finais: pixels por segundo e multiplicador segurando Enter.
@export var credits_speed: float = 45.0
@export var credits_fast_multiplier: float = 5.0
@export var intro_fade: float = 0.3
## Ao voltar para a gameplay (depois de tela de imagem ou diálogo), o ataque fica
## bloqueado por este tempo, para o clique que avançou a tela não virar ataque.
@export var attack_block_after_screen: float = 0.2
## Setas de ponto de interesse: margem da borda e tamanho.
@export var poi_arrow_margin: float = 34.0
@export var poi_arrow_size: float = 16.0
