extends Node
## Testes headless: regras puras (boss, finais, reputação) e carga de todas as cenas/resources.
## Rodar: godot --headless --path . res://tests/test_runner.tscn

var _failures: int = 0
var _checks: int = 0


func _ready() -> void:
	_test_boss_selector()
	_test_endings()
	_test_reputation()
	_test_texts()
	_load_everything("res://")
	print("TESTES: %d verificações, %d falhas" % [_checks, _failures])
	get_tree().quit(1 if _failures > 0 else 0)


func check(condition: bool, label: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("FALHOU: " + label)


func _test_boss_selector() -> void:
	var K := BossSelector.Kind
	# a) ninguém se aliou
	var s := BossSelector.select(&"p1", &"p2", true, false, false)
	check(s.kind == K.KNIGHT_ARMY_SKIN and s.player_id == &"p2" and s.helper_id == &"p1", "a) P1 vivo ajuda")
	s = BossSelector.select(&"p1", &"p2", false, false, false)
	check(s.kind == K.KNIGHT_ARMY_SKIN and s.helper_id == &"", "a) P1 morto: P2 sozinho")
	# b) só P1 se aliou
	s = BossSelector.select(&"p1", &"p2", true, true, false)
	check(s.kind == K.CHARACTER and s.boss_character_id == &"p1" and s.player_id == &"p2", "b) P2 x P1 aliado")
	s = BossSelector.select(&"p1", &"p2", false, true, false)
	check(s.kind == K.KNIGHT_ARMY_SKIN and s.helper_id == &"", "b) P1 aliado e morto não aparece")
	# b) só P2 se aliou
	s = BossSelector.select(&"p1", &"p2", true, false, true)
	check(s.kind == K.CHARACTER and s.boss_character_id == &"p2" and s.player_id == &"p1" and s.control_switched, "b) controle troca para P1")
	s = BossSelector.select(&"p1", &"p2", false, false, true)
	check(s.kind == K.KNIGHT_KINGDOM_SKIN and s.player_id == &"p2" and s.player_fights_for_army, "b) P1 morto: P2 aliado x cavaleiro do reino")
	# c) ambos aliados
	s = BossSelector.select(&"p1", &"p2", true, true, true)
	check(s.kind == K.KNIGHT_KINGDOM_SKIN and s.double_alliance and s.player_id == &"p2", "c) aliança dupla")


func _test_endings() -> void:
	var St := Reputation.Standing
	check(Endings.character_ending(false, St.POSITIVE, false) == Endings.DEATH, "morte tem prioridade")
	check(Endings.character_ending(true, St.POSITIVE, false) == Endings.POSITIVE, "positivo")
	check(Endings.character_ending(true, St.QUESTIONABLE, false) == Endings.QUESTIONABLE, "questionável")
	check(Endings.character_ending(true, St.NEGATIVE, false) == Endings.NEGATIVE_VICTORIOUS, "aliado vitorioso")
	check(Endings.character_ending(true, St.NEGATIVE, true) == Endings.NEGATIVE_IMPRISONED, "aliado preso")
	check(Endings.kingdom_ending(false, false, true, true, false) == Endings.KINGDOM_POSITIVE, "reino positivo")
	check(Endings.kingdom_ending(false, false, false, false, false) == Endings.KINGDOM_NEGATIVE, "P2 morreu antes do boss")
	check(Endings.kingdom_ending(false, false, true, false, false) == Endings.KINGDOM_NEGATIVE, "herói perdeu o boss")
	check(Endings.kingdom_ending(true, false, true, true, false) == Endings.KINGDOM_POSITIVE, "P2 venceu P1 aliado")
	check(Endings.kingdom_ending(false, true, true, true, true) == Endings.KINGDOM_NEGATIVE, "aliado venceu o reino")
	check(Endings.kingdom_ending(true, true, true, true, true) == Endings.KINGDOM_DOUBLE_ALLIANCE, "aliança dupla")
	check(Endings.kingdom_ending(true, true, true, false, true) == Endings.KINGDOM_POSITIVE, "aliado duplo derrotado")


func _test_reputation() -> void:
	var cfg := ReputationConfig.new()
	cfg.positive_threshold = 60.0
	check(Reputation.compute_standing(80, false, cfg) == Reputation.Standing.POSITIVE, "faixa positiva")
	check(Reputation.compute_standing(40, false, cfg) == Reputation.Standing.QUESTIONABLE, "faixa questionável")
	check(Reputation.compute_standing(100, true, cfg) == Reputation.Standing.NEGATIVE, "aliado = negativo")
	var ids: Array[StringName] = [&"princess", &"mage"]
	ReputationState.reset(ids)
	var start := ReputationState.get_heroism(&"princess")
	ReputationState.register_rescue(&"princess")
	check(ReputationState.get_heroism(&"princess") > start, "resgate aumenta heroísmo")
	ReputationState.register_loot(&"princess")
	ReputationState.register_loot(&"princess")
	check(ReputationState.get_heroism(&"princess") < start + ReputationState.config.rescue_gain, "saque diminui heroísmo")
	ReputationState.set_allied(&"mage")
	check(ReputationState.get_standing(&"mage") == Reputation.Standing.NEGATIVE, "aliança muda o estado")


func _test_texts() -> void:
	for id: StringName in [&"princess", &"mage"]:
		for ending: StringName in [Endings.POSITIVE, Endings.QUESTIONABLE, Endings.NEGATIVE_VICTORIOUS, Endings.NEGATIVE_IMPRISONED]:
			check(Texts.get_value("endings", "characters.%s.%s.title" % [id, ending]) != null, "texto final %s %s" % [id, ending])
		check(Texts.get_value("endings", "tombstone.%s.text" % id) != null, "lápide %s" % id)
		check(Texts.get_value("names", String(id)) != null, "nome %s" % id)
	for ending: StringName in [Endings.KINGDOM_POSITIVE, Endings.KINGDOM_NEGATIVE, Endings.KINGDOM_DOUBLE_ALLIANCE]:
		check(Texts.get_value("endings", "kingdom.%s.title" % ending) != null, "final do reino %s" % ending)
	for action: StringName in Actions.REMAPPABLE:
		check(InputMap.has_action(action), "ação %s no InputMap" % action)
		check(Texts.get_value("ui", "actions.%s" % action) != null, "nome da ação %s" % action)


func _load_everything(path: String) -> void:
	var dir := DirAccess.open(path)
	if dir == null:
		return
	for sub: String in dir.get_directories():
		if sub.begins_with("."):
			continue
		_load_everything(path.path_join(sub))
	for file: String in dir.get_files():
		var full := path.path_join(file)
		if file.ends_with(".gd") or file.ends_with(".tres"):
			check(load(full) != null, "carregar " + full)
		elif file.ends_with(".tscn"):
			var packed := load(full) as PackedScene
			check(packed != null, "carregar " + full)
			if packed and not full.begins_with("res://tests"):
				var node := packed.instantiate()
				check(node != null, "instanciar " + full)
				if node:
					node.free()
