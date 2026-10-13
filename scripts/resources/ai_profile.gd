class_name AIProfile
extends Resource
## IA simples usada pelo ajudante e pelos personagens que viram boss.

## Distância que tenta manter do alvo.
@export var preferred_range: float = 70.0
## Tolerância em volta da distância preferida.
@export var range_tolerance: float = 40.0
@export var think_interval: float = 0.25
## Chance (por decisão) de usar cada habilidade quando pronta.
@export_range(0.0, 1.0) var skill_chance: float = 0.35
@export_range(0.0, 1.0) var ultimate_chance: float = 0.15
@export_range(0.0, 1.0) var dash_chance: float = 0.12
@export_range(0.0, 1.0) var parry_chance: float = 0.0
## Quanto anda de lado (strafe) em vez de ir reto.
@export_range(0.0, 1.0) var strafe_amount: float = 0.4
