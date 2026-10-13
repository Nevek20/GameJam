class_name JuiceConfig
extends Resource
## Intensidade e duração de todo o game feel. Desligue qualquer efeito pelo checkbox.

@export var enabled: bool = true

@export_group("Screen shake")
@export var shake_enabled: bool = true
@export var shake_light_strength: float = 3.0
@export var shake_light_duration: float = 0.1
@export var shake_heavy_strength: float = 8.0
@export var shake_heavy_duration: float = 0.2
@export var shake_ultimate_strength: float = 14.0
@export var shake_ultimate_duration: float = 0.35
@export var shake_dash_strength: float = 2.0
@export var shake_dash_duration: float = 0.08
@export var shake_hurt_strength: float = 7.0
@export var shake_hurt_duration: float = 0.2
@export var shake_boss_strength: float = 12.0
@export var shake_boss_duration: float = 0.45

@export_group("Hit stop")
@export var hitstop_enabled: bool = true
@export var hitstop_time_scale: float = 0.05
@export var hitstop_light: float = 0.035
@export var hitstop_heavy: float = 0.07
@export var hitstop_ultimate: float = 0.1
@export var hitstop_hurt: float = 0.08
@export var hitstop_parry: float = 0.15

@export_group("Flash")
@export var flash_enabled: bool = true
@export var flash_duration: float = 0.1
## Brilho do flash (multiplica o modulate; > 1 fica branco).
@export var flash_intensity: float = 4.0

@export_group("Knockback")
@export var knockback_enabled: bool = true
@export var knockback_multiplier: float = 1.0
## Desaceleração do knockback (px/s²).
@export var knockback_decay: float = 2600.0

@export_group("Squash and stretch")
@export var squash_enabled: bool = true
@export var squash_duration: float = 0.14
@export var squash_attack: Vector2 = Vector2(1.18, 0.86)
@export var squash_dash: Vector2 = Vector2(1.35, 0.7)
@export var squash_hurt: Vector2 = Vector2(0.8, 1.2)
@export var squash_impact: Vector2 = Vector2(1.5, 0.6)

@export_group("Partículas")
@export var particles_enabled: bool = true
@export var particles_hit: ParticlePreset
@export var particles_death: ParticlePreset
@export var particles_dash: ParticlePreset
@export var particles_parry: ParticlePreset
@export var particles_skill: ParticlePreset
@export var particles_spawn: ParticlePreset

@export_group("Números de dano")
@export var damage_numbers_enabled: bool = true
@export var damage_number_duration: float = 0.7
@export var damage_number_rise: float = 46.0
@export var damage_number_big_scale: float = 1.6
@export var color_damage_dealt: Color = Color(1, 0.95, 0.6)
@export var color_damage_taken: Color = Color(1, 0.35, 0.4)

@export_group("Rastro do dash")
@export var trail_enabled: bool = true
@export var trail_interval: float = 0.03
@export var trail_lifetime: float = 0.25

@export_group("Câmera")
@export var camera_smoothing: float = 7.0
@export var zoom_enabled: bool = true
@export var zoom_duration: float = 0.35
@export var zoom_ultimate: float = 0.08
@export var zoom_boss: float = 0.12
@export var zoom_parry: float = 0.05

@export_group("Transições e câmera lenta")
@export var fade_duration: float = 0.35
@export var boss_kill_time_scale: float = 0.25
@export var boss_kill_slowmo: float = 1.2
