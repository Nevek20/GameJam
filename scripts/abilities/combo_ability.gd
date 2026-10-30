class_name ComboAbility
extends Ability
## Combo de golpes (5º ataque do boss): N cortes seguidos; antes de cada um o boss vira
## para o alvo, dá um passo e mostra o contorno do próximo corte (telegraph curto).
## Fase ativa = hits * hit_interval. O corte usado é o ShapeAbility em `slash`.

@export_group("Combo")
## Forma, tamanho e dano de cada golpe.
@export var slash: ShapeAbility
@export var hits: int = 3
@export var hit_interval: float = 0.5
## Fração do intervalo usada como aviso antes de cada golpe.
@export_range(0.1, 0.9) var warn_fraction: float = 0.55
## Quanto avança antes de cada golpe.
@export var step_distance: float = 60.0


func begin_active(caster: AbilityCaster) -> void:
	caster.cast_state[&"next_hit"] = 0


func active_physics(caster: AbilityCaster, _delta: float) -> void:
	if slash == null:
		return
	var t := caster.phase_elapsed()
	var next: int = caster.cast_state.get(&"next_hit", 0)
	var local := t - next * hit_interval
	var warn := hit_interval * warn_fraction
	if next < hits and local < warn:
		# Aviso: vira para o alvo e avança um pouco.
		if caster.target and is_instance_valid(caster.target):
			caster.set_aim(caster.global_position.direction_to(caster.target.global_position))
		caster.set_forced_velocity(caster.aim_dir * step_distance * caster.geometry_scale / maxf(warn, 0.01))
	elif next < hits:
		caster.release_tracked()
		slash.begin_active(caster)
		Juice.shake(Ability.JuiceLevel.LIGHT)
		caster.cast_state[&"next_hit"] = next + 1


func end_active(caster: AbilityCaster) -> void:
	caster.release_tracked()


func has_active_visual() -> bool:
	return true


## Contorno do próximo golpe durante o aviso.
func draw_active(canvas: CanvasItem, aim: Vector2, _progress: float) -> void:
	var c := canvas as AbilityCaster
	if c == null or slash == null:
		return
	var next: int = c.cast_state.get(&"next_hit", 0)
	if next >= hits or c.phase_elapsed() - next * hit_interval >= hit_interval * warn_fraction:
		return
	var k := c.geometry_scale
	canvas.draw_set_transform(aim * slash.forward_offset * k, aim.angle(), Vector2.ONE * k)
	slash.draw_local(canvas, Color(c.telegraph_color, 0.25), true)
	slash.draw_local(canvas, Color(c.telegraph_color, 0.9), false, 2.0)
	canvas.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, tint: Color) -> void:
	if slash:
		slash.draw_telegraph(canvas, aim, progress, tint)
