class_name BodySetup
extends RefCounted
## Monta o corpo retangular de uma entidade (jogador, inimigo, boss, NPC).
## A origem do nó fica nos PÉS (bom para y-sort). A colisão com o cenário é um retângulo
## baixo nos pés; a hurtbox cobre o corpo todo; o ponto de origem dos golpes (AttackOrigin)
## fica no centro do corpo, mais o offset exportado.


static func apply(body_size: Vector2, collision_size: Vector2, origin_offset: Vector2, scale: float,
		collision: CollisionShape2D, hurt: CollisionShape2D, hurtbox: Node2D, caster: Node2D,
		origin_marker: Node2D, visual: EntityVisual) -> void:
	var size := body_size * scale
	var coll := collision_size * scale
	(collision.shape as RectangleShape2D).size = coll
	collision.position = Vector2(0, -coll.y * 0.5)
	(hurt.shape as RectangleShape2D).size = size
	hurtbox.position = Vector2(0, -size.y * 0.5)
	hurt.position = Vector2.ZERO
	var origin := Vector2(0, -size.y * 0.5) + origin_offset * scale
	caster.position = origin
	if origin_marker:
		origin_marker.position = origin
	visual.placeholder.size = body_size
	visual.placeholder.position = Vector2(0, -body_size.y * 0.5)
	visual.base_scale = Vector2.ONE * scale
	visual.scale = visual.base_scale
