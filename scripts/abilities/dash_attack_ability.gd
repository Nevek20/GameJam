class_name DashAttackAbility
extends ShapeAbility
## Dash de ataque compartilhado (elite, boss e Q da Princesa). Cada um tem seu .tres.
## Fases: telegraph (= windup) -> dash (= fase ativa) -> recuperação (parado e vulnerável).
## - Telegraph: mostra no chão a direção e o alcance; a mira acompanha o alvo e TRAVA no fim.
## - Dash: distância fixa, curva simples (rápido no começo, desacelera no fim).
##   A hitbox (forma do ShapeAbility) só existe durante o dash e anda junto.
## - Jogador humano: sem telegraph, sai na direção da mira no momento do aperto.

@export_group("Dash de ataque")
## Distância total do dash (pixels, multiplicada pela escala do personagem).
@export var dash_distance: float = 180.0
## Curva: 1 = velocidade constante; 2 ou mais = começa rápido e desacelera.
@export var ease_power: float = 2.0
## Controlado pelo jogador: pula o telegraph (dash imediato na direção da mira).
@export var skip_telegraph_for_player: bool = true
## Durante o telegraph a direção segue o alvo; trava no fim do telegraph.
@export var track_target_during_telegraph: bool = true
@export var telegraph_color: Color = Color(1, 0.3, 0.35, 1)


## Duração da anticipação para este lançador (0 para o jogador humano).
func get_windup(caster: AbilityCaster) -> float:
	if skip_telegraph_for_player and caster.actor and caster.actor.has_method(&"is_human") \
			and caster.actor.call(&"is_human"):
		return 0.0
	return windup


func tracks_aim_during_windup() -> bool:
	return track_target_during_telegraph


func active_physics(caster: AbilityCaster, _delta: float) -> void:
	if active_time <= 0.0:
		return
	var speed := speed_at(caster.phase_progress(), dash_distance * caster.geometry_scale, ease_power, active_time)
	caster.set_forced_velocity(caster.aim_dir * speed)


## Velocidade no instante u (0 a 1) do dash. Posição p(u) = d * (1 - (1 - u)^n),
## então a soma da velocidade ao longo do dash é exatamente a distância d.
static func speed_at(u: float, distance: float, power: float, duration: float) -> float:
	var n := maxf(power, 1.0)
	return distance * n * pow(clampf(1.0 - u, 0.0, 1.0), n - 1.0) / maxf(duration, 0.001)


## Telegraph: faixa no chão do tamanho do dash, enchendo até travar.
func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, _tint: Color) -> void:
	var k := AbilityCaster.scale_of(canvas)
	var length := (dash_distance + forward_offset + size.x * 0.5) * k
	var width := size.y * k
	canvas.draw_set_transform(Vector2.ZERO, aim.angle(), Vector2.ONE)
	canvas.draw_rect(Rect2(Vector2(0, -width * 0.5), Vector2(length, width)), Color(telegraph_color, 0.16))
	canvas.draw_rect(Rect2(Vector2(0, -width * 0.5), Vector2(length * progress, width)), Color(telegraph_color, 0.35))
	canvas.draw_rect(Rect2(Vector2(0, -width * 0.5), Vector2(length, width)), Color(telegraph_color, 0.8), false, 2.0)
	# Seta na ponta.
	var tip := Vector2(length, 0)
	canvas.draw_colored_polygon(PackedVector2Array([tip + Vector2(14, 0), tip + Vector2(-8, -width * 0.5), tip + Vector2(-8, width * 0.5)]),
		Color(telegraph_color, 0.9))
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
