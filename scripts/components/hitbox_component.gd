class_name HitboxComponent
extends Area2D
## Base das áreas que causam dano (ataques e projéteis).
## Acerta cada alvo uma vez por ataque; com rehit_interval > 0, acerta em ticks (feixe).
## Mantém a lista de hurtboxes dentro dela pelos sinais (sem alocar por frame).

signal hit_landed(hurtbox: HurtboxComponent)

var team: Team.Faction = Team.Faction.HEROES
var rehit_interval: float = 0.0
var active: bool = false

var _next_hit_time: Dictionary = {}
var _inside: Array[HurtboxComponent] = []
var _clock: float = 0.0


func _ready() -> void:
	monitorable = false
	monitoring = true
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)


func set_team(side: Team.Faction, extra_layer: int = 0, extra_mask: int = 0) -> void:
	team = side
	collision_layer = Team.hitbox_layer(side) | extra_layer
	collision_mask = Team.hitbox_mask(side) | extra_mask


func reset_hits() -> void:
	_next_hit_time.clear()
	_inside.clear()
	_clock = 0.0


func _physics_process(delta: float) -> void:
	_clock += delta
	if active and rehit_interval > 0.0:
		for hurtbox: HurtboxComponent in _inside:
			_try_hit(hurtbox)


func _on_area_entered(area: Area2D) -> void:
	var hurtbox := area as HurtboxComponent
	if hurtbox == null:
		return
	if not _inside.has(hurtbox):
		_inside.append(hurtbox)
	_try_hit(hurtbox)


func _on_area_exited(area: Area2D) -> void:
	var hurtbox := area as HurtboxComponent
	if hurtbox:
		_inside.erase(hurtbox)


func _try_hit(hurtbox: HurtboxComponent) -> void:
	if not active or hurtbox.team == team:
		return
	var next_time: float = _next_hit_time.get(hurtbox, -1.0)
	if next_time >= 0.0 and _clock < next_time:
		return
	if _deliver(hurtbox):
		_next_hit_time[hurtbox] = _clock + rehit_interval if rehit_interval > 0.0 else INF
		hit_landed.emit(hurtbox)


## Subclasses montam o HitData e entregam. Retorna true se acertou.
func _deliver(_hurtbox: HurtboxComponent) -> bool:
	return false
