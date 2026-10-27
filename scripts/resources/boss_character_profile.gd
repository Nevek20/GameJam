class_name BossCharacterProfile
extends Resource
## Ajustes aplicados a um personagem jogável quando ele vira boss (usa o próprio moveset).
## Ele fica muito difícil com as mesmas habilidades do jogador; equilibre aqui.

@export var health_multiplier: float = 3.5
@export var damage_multiplier: float = 0.8
@export var speed_multiplier: float = 0.85
## Anticipação maior para os ataques serem telegrafados e justos.
@export var windup_multiplier: float = 2.2
## Velocidade de ataque: 0.7 = anticipação e recuperação 30% mais lentas.
@export var attack_speed_multiplier: float = 0.8

@export_group("Cooldowns")
## Multiplica todos os cooldowns (2.0 = duas vezes maiores).
@export var cooldown_multiplier: float = 2.0
## Cooldown próprio de cada habilidade quando é boss (0 = usa o da habilidade).
## O multiplicador global também vale para estes.
@export var attack_cooldown: float = 0.0
@export var skill_q_cooldown: float = 0.0
@export var skill_e_cooldown: float = 0.0
@export var ultimate_cooldown: float = 0.0

## Velocidade (graus/s) com que o feixe do boss acompanha o jogador.
@export var aim_turn_speed: float = 70.0


## Tabela Ability -> cooldown próprio, para o AbilityCaster.
func cooldown_table(stats: CharacterStats) -> Dictionary:
	var table := {}
	for pair: Array in [[stats.attack, attack_cooldown], [stats.skill_q, skill_q_cooldown],
			[stats.skill_e, skill_e_cooldown], [stats.ultimate, ultimate_cooldown]]:
		if pair[0] != null and float(pair[1]) > 0.0:
			table[pair[0]] = float(pair[1])
	return table
