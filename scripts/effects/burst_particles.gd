class_name BurstParticles
extends CPUParticles2D
## Estouro de partículas do pool. Configurado por ParticlePreset a cada uso.

var _gradient := Gradient.new()


func _ready() -> void:
	one_shot = true
	emitting = false
	_gradient.set_color(0, Color.WHITE)
	_gradient.set_color(1, Color(1, 1, 1, 0))
	color_ramp = _gradient
	local_coords = false


func play(preset: ParticlePreset, pos: Vector2, tint: Color, dir: Vector2) -> void:
	global_position = pos
	amount = maxi(preset.amount, 1)
	lifetime = preset.lifetime
	explosiveness = preset.explosiveness
	initial_velocity_min = preset.speed_min
	initial_velocity_max = preset.speed_max
	spread = preset.spread
	scale_amount_min = preset.scale_min
	scale_amount_max = preset.scale_max
	damping_min = preset.damping
	damping_max = preset.damping
	gravity = preset.gravity
	direction = dir if dir != Vector2.ZERO else Vector2.RIGHT
	_gradient.set_color(0, Color(tint, 1.0))
	_gradient.set_color(1, Color(tint.lightened(0.3), 0.0))
	restart()
	emitting = true
	# Devolve ao pool depois da vida útil (respeita pausa).
	get_tree().create_timer(preset.lifetime + 0.1, false).timeout.connect(_release, CONNECT_ONE_SHOT)


func on_pool_release() -> void:
	emitting = false


func _release() -> void:
	ObjectPool.release_node(self)
