class_name BossSelector
extends RefCounted
## Regra fixa do boss (seção 4.5), como função pura e testável.
##  a) ninguém se aliou: P2 x cavaleiro com skin do exército; P1 vivo ajuda (IA).
##  b) só um se aliou: quem NÃO se aliou enfrenta o aliado (aliado = boss com o próprio moveset).
##     Se quem não se aliou estiver morto, o aliado enfrenta o cavaleiro do reino.
##  c) ambos se aliaram: P2 x cavaleiro do reino, final de aliança dupla.
## Personagem morto nunca aparece (nem como ajudante, nem como boss).

enum Kind { KNIGHT_ARMY_SKIN, KNIGHT_KINGDOM_SKIN, CHARACTER }


class Setup:
	extends RefCounted
	var kind: Kind = Kind.KNIGHT_ARMY_SKIN
	## Personagem controlado pelo jogador na luta.
	var player_id: StringName = &""
	## Personagem que vira boss (só quando kind == CHARACTER).
	var boss_character_id: StringName = &""
	## Ajudante controlado por IA (vazio = luta sozinho).
	var helper_id: StringName = &""
	## O jogador luta pelo exército? (decide quem "venceu" no final do reino)
	var player_fights_for_army: bool = false
	var double_alliance: bool = false
	## O controle mudou para o Personagem 1.
	var control_switched: bool = false


static func select(p1_id: StringName, p2_id: StringName, p1_alive: bool,
		p1_allied: bool, p2_allied: bool) -> Setup:
	var s := Setup.new()
	s.player_id = p2_id
	s.double_alliance = p1_allied and p2_allied
	if p2_allied:
		if p1_alive and not p1_allied:
			# b) P1 (não aliado) enfrenta P2 (aliado): o controle troca para P1.
			s.kind = Kind.CHARACTER
			s.player_id = p1_id
			s.boss_character_id = p2_id
			s.control_switched = true
		else:
			# c) ambos aliados, ou b) com quem não se aliou morto.
			s.kind = Kind.KNIGHT_KINGDOM_SKIN
			s.player_fights_for_army = true
	else:
		if p1_alive and p1_allied:
			# b) P2 (não aliado) enfrenta P1 (aliado).
			s.kind = Kind.CHARACTER
			s.boss_character_id = p1_id
		else:
			# a) ninguém aliado (um P1 aliado e morto não conta: não aparece).
			s.kind = Kind.KNIGHT_ARMY_SKIN
			if p1_alive:
				s.helper_id = p1_id
	return s
