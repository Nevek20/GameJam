class_name IntroConfig
extends Resource
## Uma cutscene: sequência de imagens com legendas. Enter ou clique esquerdo avança.
## Usado na introdução, na troca para o Personagem 2 e antes do boss.
## Legendas vêm de data/intro.json (lista indicada em captions_key, na mesma ordem das imagens).
## Se houver mais legendas que imagens, as extras aparecem sobre um fundo placeholder.

@export var images: Array[Texture2D] = []
## Lista de legendas em data/intro.json (ex.: "slides", "switch", "boss").
@export var captions_key: String = "slides"
