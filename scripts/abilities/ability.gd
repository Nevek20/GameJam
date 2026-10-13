class_name Ability
extends Resource
## Base das habilidades (padrão Strategy). Cada habilidade é um Resource .tres:
## trocar ou ajustar não exige mexer no personagem.
## Fases: anticipação (windup) -> ativo -> recuperação. Só a fase ativa causa dano.
## O AbilityCaster controla as fases e chama os ganchos abaixo.

enum JuiceLevel { LIGHT, HEAVY, ULTIMATE }

@export var id: StringName = &""
## Ícone no HUD (opcional).
@export var icon: Texture2D
## Cor do placeholder do ataque.
@export var color: Color = Color(1, 1, 1, 0.85)

@export_group("Dano")
@export var damage: float = 10.0
@export var knockback: float = 220.0
## Intensidade do feedback ao lançar (shake/zoom da ultimate).
@export var juice_level: JuiceLevel = JuiceLevel.LIGHT
## Intensidade do feedback em cada acerto (hit stop, shake, número grande).
@export var hit_juice_level: JuiceLevel = JuiceLevel.LIGHT
## Pode ser aparado (parry) pelo alvo.
@export var parryable: bool = true

@export_group("Tempo")
@export var cooldown: float = 0.4
## Anticipação: o inimigo vê o telegraph nesta fase.
@export var windup: float = 0.06
## Fase ativa: a hitbox só existe aqui.
@export var active_time: float = 0.1
@export var recovery: float = 0.12
## Velocidade de movimento enquanto usa a habilidade (0 = parado).
@export_range(0.0, 1.0) var move_multiplier: float = 0.4
## Não é interrompido por dano.
@export var super_armor: bool = false
## Dash ou outro ataque podem cancelar a recuperação.
@export var cancel_recovery: bool = true

@export_group("IA")
## Distância máxima em que a IA tenta usar este ataque.
@export var ai_range: float = 90.0

@export_group("Áudio")
@export var sfx_cast: StringName = &""
@export var sfx_hit: StringName = &"hit"


# --- Ganchos da Strategy (sobrescrever nas subclasses) ---

func begin_windup(_caster: AbilityCaster) -> void:
	pass


func begin_active(_caster: AbilityCaster) -> void:
	pass


func active_physics(_caster: AbilityCaster, _delta: float) -> void:
	pass


func end_active(_caster: AbilityCaster) -> void:
	pass


## Desenha o aviso visual durante a anticipação (coordenadas locais do lançador).
func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, tint: Color) -> void:
	var length := ai_range
	canvas.draw_line(Vector2.ZERO, aim * length, Color(tint, 0.35), 3.0)
	canvas.draw_line(Vector2.ZERO, aim * length * progress, Color(tint, 0.8), 3.0)


## Monta o pacote de dano (dano multiplicado pelo lançador).
func make_hit(caster: AbilityCaster, direction: Vector2, damage_scale: float = 1.0) -> HitData:
	var hit := HitData.new()
	hit.damage = damage * caster.damage_multiplier * damage_scale
	hit.knockback = knockback
	hit.direction = direction
	hit.source = caster.actor
	hit.team = caster.team
	hit.juice_level = hit_juice_level
	hit.parryable = parryable
	hit.color = color
	hit.sfx_hit = sfx_hit
	return hit
