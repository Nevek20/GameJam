class_name HUD
extends Control
## HUD: vida, heroísmo, tempo, objetivo, cooldowns, boss e guia de mapa.
## Escuta sinais (Player, ReputationState); não conhece regras de jogo.

@export var ui_config: UIConfig

var _player: Player
var _boss_source: Node
var _chip_tween: Tween
var _parry_tween: Tween
var _vignette_tween: Tween
var _time_warning: bool = false

@onready var _name: Label = %CharName
@onready var _health: ProgressBar = %HealthBar
@onready var _health_chip: ProgressBar = %HealthChip
@onready var _heroism: ProgressBar = %HeroismBar
@onready var _heroism_label: Label = %HeroismLabel
@onready var _alliance: Label = %AllianceTag
@onready var _timer: Label = %TimerLabel
@onready var _objective: Label = %Objective
@onready var _boss_panel: Control = %BossPanel
@onready var _boss_name: Label = %BossName
@onready var _boss_bar: ProgressBar = %BossBar
@onready var _parry: Label = %ParryLabel
@onready var _vignette: TextureRect = %Vignette
@onready var _slot_dash: CooldownSlot = %SlotDash
@onready var _slot_parry: CooldownSlot = %SlotParry
@onready var _slot_q: CooldownSlot = %SlotQ
@onready var _slot_e: CooldownSlot = %SlotE
@onready var _slot_r: CooldownSlot = %SlotR
@onready var banner: Banner = %Banner
@onready var _prompt: Label = %Prompt
@onready var poi_arrows: PoiArrows = %PoiArrows


func _ready() -> void:
	ReputationState.heroism_changed.connect(_on_heroism_changed)
	ReputationState.alliance_changed.connect(_on_alliance_changed)
	_boss_panel.hide()
	_parry.hide()
	_vignette.modulate.a = 0.0
	_heroism_label.text = Texts.ui("hud.heroism")
	_alliance.text = Texts.ui("hud.allied")
	_alliance.hide()
	_slot_dash.label_text = Texts.ui("hud.slot_dash")
	_slot_parry.label_text = Texts.ui("hud.slot_parry")
	_slot_q.label_text = Texts.ui("hud.slot_q")
	_slot_e.label_text = Texts.ui("hud.slot_e")
	_slot_r.label_text = Texts.ui("hud.slot_r")
	set_process(false)


func bind_player(player: Player) -> void:
	if _player and is_instance_valid(_player):
		_player.health_changed.disconnect(_on_health_changed)
		_player.parried.disconnect(_on_parried)
		_player.hurt.disconnect(_on_hurt)
	_player = player
	_player.health_changed.connect(_on_health_changed)
	_player.parried.connect(_on_parried)
	_player.hurt.connect(_on_hurt)
	var id := player.stats.id
	_name.text = Texts.character_name(id)
	_slot_q.icon = player.stats.skill_q.icon if player.stats.skill_q else null
	_slot_e.icon = player.stats.skill_e.icon if player.stats.skill_e else null
	_slot_r.icon = player.stats.ultimate.icon if player.stats.ultimate else null
	_health.max_value = player.health.max_health
	_health.value = player.health.current
	_health_chip.max_value = player.health.max_health
	_health_chip.value = player.health.current
	_on_heroism_changed(id, ReputationState.get_heroism(id), ReputationState.get_max_heroism())
	_alliance.visible = ReputationState.is_allied(id)
	set_process(true)


func set_time(seconds: float) -> void:
	var s := maxi(ceili(seconds), 0)
	_timer.text = "%d:%02d" % [floori(s / 60.0), s % 60]
	var warning := seconds <= 10.0
	if warning != _time_warning:
		_time_warning = warning
		_timer.modulate = Color(1, 0.4, 0.45) if warning else Color.WHITE


func show_timer(value: bool) -> void:
	_timer.visible = value


func set_objective(text: String) -> void:
	_objective.text = text


## Aviso no centro de baixo (revive, avançar etapa). Texto vazio esconde.
func set_prompt(text: String) -> void:
	if _prompt.text != text:
		_prompt.text = text
	_prompt.visible = not text.is_empty()


func show_boss(display_name: String, source: Node, current: float, maximum: float) -> void:
	_boss_source = source
	_boss_name.text = display_name
	_boss_bar.max_value = maximum
	_boss_bar.value = current
	_boss_panel.show()
	if source.has_signal(&"health_changed") and not source.is_connected(&"health_changed", _on_boss_health):
		source.connect(&"health_changed", _on_boss_health)


func hide_boss() -> void:
	_boss_panel.hide()


func show_banner(title: String, subtitle: String = "") -> void:
	banner.show_banner(title, subtitle)


func _process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	var caster := _player.caster
	_slot_dash.set_ratio(_player.dash_ratio())
	_slot_parry.set_ratio(_player.parry_ratio())
	_slot_q.set_ratio(caster.cooldown_ratio(_player.stats.skill_q))
	_slot_e.set_ratio(caster.cooldown_ratio(_player.stats.skill_e))
	_slot_r.set_ratio(caster.cooldown_ratio(_player.stats.ultimate))


func _on_health_changed(current: float, maximum: float) -> void:
	_health.max_value = maximum
	_health_chip.max_value = maximum
	_health.value = current
	# Barra "fantasma" desce devagar para mostrar o dano recebido.
	if _chip_tween:
		_chip_tween.kill()
	if current >= _health_chip.value:
		_health_chip.value = current
		return
	_chip_tween = create_tween()
	_chip_tween.tween_interval(0.25)
	_chip_tween.tween_property(_health_chip, "value", current, 0.4)


func _on_heroism_changed(id: StringName, value: float, maximum: float) -> void:
	if _player == null or _player.stats.id != id:
		return
	_heroism.max_value = maximum
	var tween := create_tween()
	tween.tween_property(_heroism, "value", value, 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)


func _on_alliance_changed(id: StringName, allied: bool) -> void:
	if _player and _player.stats.id == id:
		_alliance.visible = allied


func _on_boss_health(current: float, maximum: float) -> void:
	_boss_bar.max_value = maximum
	_boss_bar.value = current


func _on_parried(_p: Player) -> void:
	_parry.text = Texts.ui("hud.parry")
	_parry.show()
	_parry.pivot_offset = _parry.size * 0.5
	_parry.scale = Vector2(1.8, 1.8)
	_parry.modulate.a = 1.0
	if _parry_tween:
		_parry_tween.kill()
	_parry_tween = create_tween()
	_parry_tween.tween_property(_parry, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_parry_tween.tween_interval(0.4)
	_parry_tween.tween_property(_parry, "modulate:a", 0.0, 0.3)
	_parry_tween.tween_callback(_parry.hide)


func _on_hurt(_p: Player) -> void:
	if _vignette_tween:
		_vignette_tween.kill()
	_vignette.modulate.a = 0.85
	_vignette_tween = create_tween()
	_vignette_tween.tween_property(_vignette, "modulate:a", 0.0, 0.45)
