class_name AbilityCaster
extends Node2D
## Executa habilidades em fases (anticipação -> ativo -> recuperação) e guarda cooldowns.
## Também desenha o telegraph (aviso) durante a anticipação para atacantes inimigos.
## Para usar AnimationPlayer no lugar das fases por código: chame begin_active_phase()
## e end_active_phase() a partir de method tracks nos keyframes.

signal cast_started(ability: Ability)
signal cast_activated(ability: Ability)
signal cast_finished(ability: Ability)

enum Phase { NONE, WINDUP, ACTIVE, RECOVERY }

var actor: CharacterBody2D
var team: Team.Faction = Team.Faction.HEROES
var aim_dir: Vector2 = Vector2.RIGHT
var damage_multiplier: float = 1.0
var windup_multiplier: float = 1.0
var cooldown_multiplier: float = 1.0
## Escala do dono (GameScale): tamanho, alcance e avanço dos golpes acompanham.
var geometry_scale: float = 1.0
## Multiplica a recuperação (velocidade de ataque do personagem-boss).
var recovery_multiplier: float = 1.0
## Cooldown próprio de uma habilidade (Ability -> segundos), usado pelo personagem-boss.
var cooldown_overrides: Dictionary = {}
## Alvo atual (o dono atualiza): ataques que seguem o alvo usam isto.
var target: Node2D
## Estado do golpe atual (as habilidades são Resources compartilhados, então o
## que muda durante um golpe fica aqui). Limpo a cada cast.
var cast_state: Dictionary = {}
var show_telegraph: bool = false
var telegraph_color: Color = Color(1, 0.25, 0.35)

var current: Ability
var phase: Phase = Phase.NONE

var _phase_left: float = 0.0
var _phase_total: float = 0.0
var _cooldowns: Dictionary = {}
var _cooldown_totals: Dictionary = {}
var _tracked: Array[Node] = []
var _forced_velocity: Vector2 = Vector2.ZERO
var _has_forced: bool = false


func setup(owner_body: CharacterBody2D, side: Team.Faction) -> void:
	actor = owner_body
	team = side
	z_as_relative = false
	z_index = -1


func is_casting() -> bool:
	return phase != Phase.NONE


func in_recovery() -> bool:
	return phase == Phase.RECOVERY


## A mira ainda pode mudar (anticipação de habilidade que segue o alvo).
func is_aim_tracking() -> bool:
	return phase == Phase.WINDUP and current != null and current.tracks_aim_during_windup()


func can_cancel() -> bool:
	return phase == Phase.RECOVERY and current != null and current.cancel_recovery


func has_super_armor() -> bool:
	return current != null and current.super_armor and phase != Phase.RECOVERY


func is_ready(ability: Ability) -> bool:
	return ability != null and float(_cooldowns.get(ability, 0.0)) <= 0.0


## 0 = pronto, 1 = cooldown acabou de começar.
func cooldown_ratio(ability: Ability) -> float:
	if ability == null:
		return 0.0
	var total: float = _cooldown_totals.get(ability, 0.0)
	if total <= 0.0:
		return 0.0
	return clampf(float(_cooldowns.get(ability, 0.0)) / total, 0.0, 1.0)


func cast(ability: Ability, aim: Vector2) -> bool:
	if not is_ready(ability):
		return false
	if is_casting():
		interrupt()
	current = ability
	cast_state.clear()
	if aim != Vector2.ZERO:
		aim_dir = aim.normalized()
	var base_cd: float = cooldown_overrides.get(ability, ability.cooldown)
	var cd := base_cd * cooldown_multiplier
	_cooldowns[ability] = cd
	_cooldown_totals[ability] = cd
	_enter(Phase.WINDUP, ability.get_windup(self) * windup_multiplier)
	ability.begin_windup(self)
	cast_started.emit(ability)
	if ability.sfx_cast != &"":
		AudioManager.play_sfx(ability.sfx_cast)
	_advance_while_done()
	return true


## Cancela o ataque atual (dano recebido, morte, cancelamento por dash).
func interrupt() -> void:
	if phase == Phase.ACTIVE and current:
		current.end_active(self)
	if current:
		current.cancel(self)
	release_tracked()
	phase = Phase.NONE
	current = null
	_has_forced = false
	queue_redraw()


func reset_cooldowns() -> void:
	_cooldowns.clear()
	_cooldown_totals.clear()


func set_aim(direction: Vector2) -> void:
	if direction != Vector2.ZERO:
		aim_dir = direction.normalized()


func set_forced_velocity(velocity: Vector2) -> void:
	_forced_velocity = velocity
	_has_forced = true


func has_forced_velocity() -> bool:
	return _has_forced


func get_forced_velocity() -> Vector2:
	return _forced_velocity


## Hitboxes que vivem só durante a fase ativa deste ataque.
func track(node: Node) -> void:
	_tracked.append(node)


func release_tracked() -> void:
	for node: Node in _tracked:
		if is_instance_valid(node):
			ObjectPool.release_node(node)
	_tracked.clear()


func phase_progress() -> float:
	if _phase_total <= 0.0:
		return 1.0
	return clampf(1.0 - _phase_left / _phase_total, 0.0, 1.0)


# Ganchos para AnimationPlayer (method tracks).
func begin_active_phase() -> void:
	if phase == Phase.WINDUP:
		_phase_left = 0.0
		_advance_while_done()


func end_active_phase() -> void:
	if phase == Phase.ACTIVE:
		_phase_left = 0.0
		_advance_while_done()


func _physics_process(delta: float) -> void:
	for ability: Ability in _cooldowns:
		var left: float = _cooldowns[ability]
		if left > 0.0:
			_cooldowns[ability] = left - delta
	_has_forced = false
	if phase == Phase.NONE:
		return
	_phase_left -= delta
	if phase == Phase.ACTIVE:
		current.active_physics(self, delta)
		if current.has_active_visual():
			queue_redraw()
	elif phase == Phase.WINDUP:
		current.windup_physics(self, delta)
		if show_telegraph:
			queue_redraw()
	_advance_while_done()


func _enter(next: Phase, duration: float) -> void:
	phase = next
	_phase_total = maxf(duration, 0.0)
	_phase_left = _phase_total


func _advance_while_done() -> void:
	while phase != Phase.NONE and _phase_left <= 0.0:
		match phase:
			Phase.WINDUP:
				_enter(Phase.ACTIVE, current.active_time)
				current.begin_active(self)
				cast_activated.emit(current)
				queue_redraw()
			Phase.ACTIVE:
				current.end_active(self)
				_enter(Phase.RECOVERY, current.recovery * recovery_multiplier)
				queue_redraw()
			Phase.RECOVERY:
				var finished := current
				phase = Phase.NONE
				current = null
				cast_finished.emit(finished)


func _draw() -> void:
	if current == null:
		return
	if phase == Phase.WINDUP and show_telegraph:
		current.draw_telegraph(self, aim_dir, phase_progress(), telegraph_color)
	elif phase == Phase.ACTIVE and current.has_active_visual():
		current.draw_active(self, aim_dir, phase_progress())


## Pés do dono em coordenadas locais do lançador (o lançador fica no centro do corpo).
func feet_offset() -> Vector2:
	return -position


## Tempo já passado na fase atual.
func phase_elapsed() -> float:
	return _phase_total - _phase_left


## Escala usada pelos telegraphs (o canvas do desenho é o próprio AbilityCaster).
static func scale_of(canvas: CanvasItem) -> float:
	var c := canvas as AbilityCaster
	return c.geometry_scale if c else 1.0
