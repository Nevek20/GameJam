class_name Team
extends RefCounted
## Dois lados fixos. "Heróis" é sempre o lado do personagem controlado pelo jogador
## (mesmo quando ele se aliou ao exército); "Inimigos" é tudo que é hostil a ele.

enum Faction { HEROES, FOES }

const GROUP_HEROES := &"team_heroes"
const GROUP_FOES := &"team_foes"


static func opposite(side: Faction) -> Faction:
	if side == Faction.HEROES:
		return Faction.FOES
	return Faction.HEROES


static func group_of(side: Faction) -> StringName:
	return GROUP_HEROES if side == Faction.HEROES else GROUP_FOES


static func body_layer(side: Faction) -> int:
	return Layers.PLAYER if side == Faction.HEROES else Layers.ENEMY


static func body_mask(side: Faction) -> int:
	# Heróis só colidem com o cenário (atravessam inimigos no dash);
	# inimigos também se empurram entre si para não se empilharem.
	return Layers.WORLD if side == Faction.HEROES else Layers.WORLD | Layers.ENEMY


static func hurtbox_layer(side: Faction) -> int:
	return Layers.PLAYER_HURTBOX if side == Faction.HEROES else Layers.ENEMY_HURTBOX


static func hitbox_layer(side: Faction) -> int:
	return Layers.PLAYER_HITBOX if side == Faction.HEROES else Layers.ENEMY_HITBOX


## Uma hitbox detecta as hurtboxes do lado oposto.
static func hitbox_mask(side: Faction) -> int:
	return hurtbox_layer(opposite(side))


## Retorna o nó vivo mais próximo do lado indicado (ou null).
static func find_nearest(tree: SceneTree, side: Faction, from: Vector2, max_distance: float) -> Node2D:
	var best: Node2D = null
	var best_dist := max_distance * max_distance
	for node: Node in tree.get_nodes_in_group(group_of(side)):
		var n2d := node as Node2D
		if n2d == null or not n2d.is_visible_in_tree():
			continue
		if n2d.has_method(&"is_targetable") and not n2d.call(&"is_targetable"):
			continue
		var d := from.distance_squared_to(n2d.global_position)
		if d < best_dist:
			best_dist = d
			best = n2d
	return best


static func hurtbox_group(side: Faction) -> StringName:
	return &"hurtbox_heroes" if side == Faction.HEROES else &"hurtbox_foes"
