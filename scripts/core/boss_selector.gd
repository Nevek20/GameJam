class_name BossSelector
extends RefCounted
## Regra fixa da luta final (seção 6.2), como função pura e testável.
## Cavaleiro do reino e do exército são o MESMO personagem: só muda a skin.
##  a) Ninguém se aliou: cavaleiro com skin do exército. Escolha de personagem se os dois
##     estão vivos (o outro vira ajudante da IA).
##  b) Ambos se aliaram: o mesmo cavaleiro com a skin do reino (variação do bem).
##     Escolha se os dois estão vivos (o outro vira ajudante).
##  c) Só um se aliou e os dois vivos: o aliado é o boss (moveset dele); o jogador controla
##     quem NÃO se aliou (troca o controle se preciso). Sem escolha, sem ajudante.
##  d) Só um se aliou e um morreu:
##     - aliado morto: cavaleiro com skin do exército; jogador = não aliado.
##     - não aliado morto: cavaleiro com skin do reino; jogador = aliado.

enum Kind { KNIGHT_ARMY_SKIN, KNIGHT_KINGDOM_SKIN, CHARACTER }


class Setup:
	extends RefCounted
	var kind: Kind = Kind.KNIGHT_ARMY_SKIN
	## Personagem controlado pelo jogador (vazio até a escolha, quando há escolha).
	var player_id: StringName = &""
	## Personagem que vira boss (só quando kind == CHARACTER).
	var boss_character_id: StringName = &""
	## Ajudante controlado pela IA (vazio = luta sozinho).
	var helper_id: StringName = &""
	## Mostrar a tela de escolha de personagem.
	var choice: bool = false
	## Quem pode ser escolhido.
	var choice_options: Array[StringName] = []
	## O jogador luta pelo exército? (decide o final do reino)
	var player_fights_for_army: bool = false
	var double_alliance: bool = false
	## O controle mudou para o Personagem 1 (o turno é do Personagem 2).
	var control_switched: bool = false
	var _p2: StringName = &""
	var _allied: Dictionary = {}

	## Aplica a escolha feita na tela: o outro vira ajudante.
	func apply_choice(chosen: StringName) -> void:
		player_id = chosen
		helper_id = &""
		for id: StringName in choice_options:
			if id != chosen:
				helper_id = id
		_finish()

	func _finish() -> void:
		player_fights_for_army = bool(_allied.get(player_id, false))
		control_switched = player_id != _p2


static func select(p1_id: StringName, p2_id: StringName, p1_alive: bool, p2_alive: bool,
		p1_allied: bool, p2_allied: bool) -> Setup:
	var s := Setup.new()
	s._p2 = p2_id
	s._allied = {p1_id: p1_allied, p2_id: p2_allied}
	s.double_alliance = p1_allied and p2_allied
	var alive: Array[StringName] = []
	if p1_alive:
		alive.append(p1_id)
	if p2_alive:
		alive.append(p2_id)
	if p1_allied == p2_allied:
		# a) ninguém aliado  /  b) ambos aliados
		s.kind = Kind.KNIGHT_KINGDOM_SKIN if p1_allied else Kind.KNIGHT_ARMY_SKIN
		if alive.size() == 2:
			s.choice = true
			s.choice_options = alive
		elif alive.size() == 1:
			s.player_id = alive[0]
			s._finish()
		return s
	var allied_id := p1_id if p1_allied else p2_id
	var other_id := p2_id if p1_allied else p1_id
	var allied_alive := p1_alive if p1_allied else p2_alive
	var other_alive := p2_alive if p1_allied else p1_alive
	if allied_alive and other_alive:
		# c) o aliado é o boss
		s.kind = Kind.CHARACTER
		s.boss_character_id = allied_id
		s.player_id = other_id
	elif other_alive:
		# d) aliado morto: boss normal
		s.kind = Kind.KNIGHT_ARMY_SKIN
		s.player_id = other_id
	else:
		# d) não aliado morto: variação do bem
		s.kind = Kind.KNIGHT_KINGDOM_SKIN
		s.player_id = allied_id
	s._finish()
	return s
