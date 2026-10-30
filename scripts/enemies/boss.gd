class_name Boss
extends Enemy
## Cavaleiro boss: mesmo moveset com skin do exército ou do reino, e fases por vida.

signal phase_changed(index: int)

var boss_stats: BossStats
var phase_index: int = 0
var _last_attack: Ability
var _same_in_row: int = 0


## Os multiplicadores fortalecem o boss (ex.: depois que o Personagem 1 morre).
func activate_boss(stats_data: BossStats, pos: Vector2, army_skin: bool,
		health_multiplier: float = 1.0, damage_multiplier: float = 1.0) -> void:
	boss_stats = stats_data
	phase_index = 0
	_last_attack = null
	_same_in_row = 0
	activate(stats_data, pos, stats_data.army_skin if army_skin else stats_data.kingdom_skin,
		health_multiplier, damage_multiplier)
	_apply_phase_speed()


func _apply_phase_speed() -> void:
	var phase := current_phase()
	var speed := maxf(phase.attack_speed, 0.1) if phase else 1.0
	caster.windup_multiplier = 1.0 / speed
	caster.recovery_multiplier = 1.0 / speed


# Seletor simples: evita o mesmo ataque mais de max_same_attack_in_row vezes seguidas.
func _can_choose(ability: Ability, distance: float) -> bool:
	if not super(ability, distance):
		return false
	return ability != _last_attack or _same_in_row < boss_stats.max_same_attack_in_row


func _on_attack_chosen(ability: Ability) -> void:
	_same_in_row = _same_in_row + 1 if ability == _last_attack else 1
	_last_attack = ability


func display_name_key() -> StringName:
	return skin.name_key if skin else &""


func current_phase() -> BossPhase:
	if boss_stats == null or boss_stats.phases.is_empty():
		return null
	return boss_stats.phases[clampi(phase_index, 0, boss_stats.phases.size() - 1)]


func get_attacks() -> Array[Ability]:
	var phase := current_phase()
	return phase.attacks if phase else stats.attacks


func get_attack_weights() -> Array[float]:
	var phase := current_phase()
	return phase.attack_weights if phase else stats.attack_weights


func current_attack_interval() -> float:
	var phase := current_phase()
	return phase.attack_interval if phase else stats.attack_interval


func scale_kind() -> GameScale.Kind:
	return GameScale.Kind.BOSS


func current_speed_multiplier() -> float:
	var phase := current_phase()
	return phase.speed_multiplier if phase else 1.0


func _on_health_changed(current: float, maximum: float) -> void:
	super(current, maximum)
	if dead or boss_stats == null:
		return
	var ratio := current / maximum
	var next := phase_index
	for i in range(phase_index + 1, boss_stats.phases.size()):
		if ratio <= boss_stats.phases[i].health_threshold:
			next = i
	if next != phase_index:
		phase_index = next
		_apply_phase_speed()
		movement.configure(stats.move_speed * current_speed_multiplier() * size_scale,
			stats.acceleration * size_scale, stats.friction * size_scale)
		phase_changed.emit(phase_index)
		# Adiado: estamos dentro do callback de dano.
		_start_roar.call_deferred()


func _start_roar() -> void:
	if not dead:
		state_machine.transition_to(&"Roar", {"duration": boss_stats.phase_change_duration})


# Ponto de interesse do guia de mapa.
func is_poi_active() -> bool:
	return not dead and visible


func get_poi_color() -> Color:
	return Color(1, 0.2, 0.3)
