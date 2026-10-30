class_name QTEConfig
extends Resource
## Quick Time Event do resgate: a barra esvazia; clique quando ela estiver na janela.

## Tempo para a barra esvaziar (menor = mais rápido).
@export var duration: float = 1.6
## Tamanho da janela de acerto (fração da barra).
@export_range(0.02, 1.0) var window_size: float = 0.18
## A janela é sorteada entre estes valores (fração da barra).
@export_range(0.0, 1.0) var window_start_min: float = 0.15
@export_range(0.0, 1.0) var window_start_max: float = 0.55
## Atraso antes de a barra começar a cair.
@export var start_delay: float = 0.35
## O jogador fica invulnerável durante o QTE.
@export var invulnerable: bool = true
