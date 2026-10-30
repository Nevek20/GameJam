class_name AreaDamage
extends RefCounted
## Dano em área sem hitbox física (anel, queda do boss): procura as hurtboxes do lado
## oposto pela distância. Usa o grupo de hurtboxes de cada time.


## Acerta quem estiver entre min_r e max_r do centro (ignora quem já está em `already`).
static func hit_ring(ability: Ability, caster: AbilityCaster, center: Vector2, min_r: float, max_r: float,
		already: Dictionary) -> void:
	var group := Team.hurtbox_group(Team.opposite(caster.team))
	for node: Node in caster.get_tree().get_nodes_in_group(group):
		var hurtbox := node as HurtboxComponent
		if hurtbox == null or not hurtbox.is_active() or already.has(hurtbox):
			continue
		var d := hurtbox.global_position.distance_to(center)
		if d < min_r or d > max_r:
			continue
		var hit := ability.make_hit(caster, center.direction_to(hurtbox.global_position))
		hit.hit_position = hurtbox.global_position
		if hurtbox.receive_hit(hit):
			already[hurtbox] = true
