class_name ProjectileAbility
extends Ability
## Dispara um projétil redondo do pool (hoje: o disparo de mana do Mago).
##
## TODO (habilidades do Mago, seção 5.2 do briefing):
##  - Q, bola de fogo: projétil maior e com mais dano (só configurar um .tres novo).
##  - E, raio laser que encadeia para o próximo inimigo perto (criar uma subclasse de Ability;
##    os alvos estão no grupo Team.hurtbox_group(...)). Alcance e número de saltos parametrizáveis.
##  - R, kamehameha: retângulo grande que dá dano por tick (precisa de "acertar de novo a cada X s"
##    no HitboxComponent).

@export_group("Projétil")
@export var radius: float = 8.0
@export var speed: float = 640.0
@export var max_range: float = 620.0
## Quantos alvos atravessa antes de sumir (0 = some no primeiro).
@export var pierce: int = 0
@export var spawn_offset: float = 24.0
## Tamanho do brilho em volta do núcleo.
@export var glow_scale: float = 2.2


func begin_active(caster: AbilityCaster) -> void:
	var pool := Pools.get_pool(&"projectiles")
	if pool == null:
		return
	var projectile := pool.acquire() as Projectile
	if projectile:
		projectile.launch(self, caster, caster.global_position + caster.aim_dir * spawn_offset, caster.aim_dir)


func draw_telegraph(canvas: CanvasItem, aim: Vector2, progress: float, tint: Color) -> void:
	var length := minf(max_range, 360.0)
	canvas.draw_line(Vector2.ZERO, aim * length, Color(tint, 0.25), radius * 1.2)
	canvas.draw_line(Vector2.ZERO, aim * length * progress, Color(tint, 0.7), 2.0)
	canvas.draw_circle(aim * spawn_offset, radius * (0.5 + progress), Color(tint, 0.8))
