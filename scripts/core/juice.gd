class_name Juice
extends Node
## Ponto único de game feel: shake, hit stop, zoom, partículas, números de dano e rastro.
## Tudo lê JuiceConfig, então cada efeito pode ser ajustado ou desligado no Inspector.
## Funções estáticas para qualquer entidade chamar sem precisar de referência.

static var _instance: Juice

@export var config: JuiceConfig
@export var camera: CameraRig

var _time_scale_until_ms: int = 0


func _enter_tree() -> void:
	_instance = self
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process(false)


func _exit_tree() -> void:
	if _instance == self:
		_instance = null
	Engine.time_scale = 1.0


# Usa tempo real para restaurar o time_scale, então pausa e hit stop não se travam.
func _process(_delta: float) -> void:
	if Time.get_ticks_msec() >= _time_scale_until_ms:
		Engine.time_scale = 1.0
		set_process(false)


static func cfg() -> JuiceConfig:
	return _instance.config if _instance else null


static func shake(level: Ability.JuiceLevel) -> void:
	var c := cfg()
	if c == null:
		return
	match level:
		Ability.JuiceLevel.LIGHT:
			shake_custom(c.shake_light_strength, c.shake_light_duration)
		Ability.JuiceLevel.HEAVY:
			shake_custom(c.shake_heavy_strength, c.shake_heavy_duration)
		Ability.JuiceLevel.ULTIMATE:
			shake_custom(c.shake_ultimate_strength, c.shake_ultimate_duration)


static func shake_custom(strength: float, duration: float) -> void:
	var c := cfg()
	if c == null or not c.enabled or not c.shake_enabled or _instance.camera == null:
		return
	_instance.camera.add_shake(strength, duration)


static func hit_stop_for(level: Ability.JuiceLevel) -> void:
	var c := cfg()
	if c == null:
		return
	match level:
		Ability.JuiceLevel.LIGHT:
			hit_stop(c.hitstop_light)
		Ability.JuiceLevel.HEAVY:
			hit_stop(c.hitstop_heavy)
		Ability.JuiceLevel.ULTIMATE:
			hit_stop(c.hitstop_ultimate)


static func hit_stop(duration: float) -> void:
	var c := cfg()
	if c == null or not c.enabled or not c.hitstop_enabled:
		return
	time_scale(c.hitstop_time_scale, duration)


## Câmera lenta genérica (hit stop é um caso curto disso).
static func time_scale(scale: float, duration: float) -> void:
	if _instance == null or duration <= 0.0:
		return
	var until := Time.get_ticks_msec() + int(duration * 1000.0)
	if until > _instance._time_scale_until_ms:
		_instance._time_scale_until_ms = until
	Engine.time_scale = minf(Engine.time_scale, scale)
	_instance.set_process(true)


static func zoom_punch(amount: float) -> void:
	var c := cfg()
	if c == null or not c.enabled or not c.zoom_enabled or _instance.camera == null:
		return
	_instance.camera.zoom_punch(amount, c.zoom_duration)


static func burst(preset: ParticlePreset, pos: Vector2, color: Color, direction: Vector2 = Vector2.ZERO) -> void:
	var c := cfg()
	if c == null or not c.enabled or not c.particles_enabled or preset == null or Pools.instance == null:
		return
	var p := Pools.instance.particles.acquire() as BurstParticles
	if p:
		p.play(preset, pos, color, direction)


static func damage_number(pos: Vector2, amount: float, color: Color, big: bool = false) -> void:
	var c := cfg()
	if c == null or not c.enabled or not c.damage_numbers_enabled or Pools.instance == null:
		return
	var n := Pools.instance.damage_numbers.acquire() as DamageNumber
	if n:
		n.show_number(pos, amount, color, big, c)


## Número verde de cura ("+30").
static func heal_number(pos: Vector2, amount: float) -> void:
	var c := cfg()
	if c == null or not c.enabled or not c.damage_numbers_enabled or Pools.instance == null:
		return
	var n := Pools.instance.damage_numbers.acquire() as DamageNumber
	if n:
		n.show_number(pos, amount, c.color_heal, true, c, "+")


static func afterimage(visual: EntityVisual, color: Color) -> void:
	var c := cfg()
	if c == null or not c.enabled or not c.trail_enabled or Pools.instance == null:
		return
	var a := Pools.instance.afterimages.acquire() as Afterimage
	if a:
		a.copy_from(visual, color, c.trail_lifetime)
