extends Node
## Teste de fluxo completo (headless): simula partidas inteiras com as combinações
## pedidas: P1 morre, P1 sobrevive, aliança de nenhum / de um / de ambos e P2 morre.
## Rodar: godot --headless --path . res://tests/flow_test.tscn

var _failures: int = 0
var _log: PackedStringArray = []


func _ready() -> void:
	# O driver vive na raiz para sobreviver às trocas de cena.
	if has_meta(&"driver"):
		_run_all.call_deferred()
		return
	var driver := Node.new()
	driver.name = "FlowDriver"
	driver.set_meta(&"driver", true)
	driver.set_script(get_script())
	get_tree().root.add_child.call_deferred(driver)


func _run_all() -> void:
	await _scenario("nenhum aliado, P1 vivo ajuda", _none_allied)
	await _scenario("P1 morre", _p1_dies)
	await _scenario("só P1 aliado", _p1_allied)
	await _scenario("só P2 aliado (controle troca)", _p2_allied)
	await _scenario("ambos aliados", _both_allied)
	await _scenario("P2 morre na fase", _p2_dies)
	await _scenario("P2 morre no boss", _p2_dies_boss)
	for line: String in _log:
		print(line)
	print("FLUXO: %d falhas" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


func check(condition: bool, label: String) -> void:
	if not condition:
		_failures += 1
		push_error("FALHOU: " + label)
		_log.append("  x " + label)
	else:
		_log.append("  ok " + label)


func _scenario(title: String, body: Callable) -> void:
	_log.append("== " + title)
	GameManager.start_new_game()
	var game := await _wait_game()
	if game == null:
		check(false, "cena do jogo carregou")
		return
	await _skip_intro(game)
	await body.call(game)


# --- Cenários ---

func _none_allied(game: Game) -> void:
	await _rescue_first_house(game)
	await _army_choice(game, 0)
	await _bot_fight(game, 6.0)
	await _time_up(game)
	await _p2_intro(game)
	await _army_choice(game, 0)
	await _time_up(game)
	await _wait_boss(game)
	var data := game.boss_director.setup_data
	check(data.kind == BossSelector.Kind.KNIGHT_ARMY_SKIN, "boss = cavaleiro com skin do exército")
	check(data.helper_id == GameState.p1_id(), "P1 vivo ajuda na luta")
	await _bot_fight(game, 4.0)
	await _win_boss(game)
	await _check_conclusion(Endings.KINGDOM_POSITIVE, [&"", &""])


func _p1_dies(game: Game) -> void:
	game.player.health.take_damage(99999.0)
	await _wait(0.5)
	check(game.tombstone.is_open, "lápide aparece ao morrer")
	_press(Actions.CONFIRM)
	await _p2_intro(game)
	check(game.player.stats.id == GameState.p2_id(), "P2 assume")
	check(game.player.global_position.distance_to(game.level.marker("PlayerStart")) < 5.0, "P2 começa do início do mapa")
	await _army_choice(game, 0)
	await _time_up(game)
	await _wait_boss(game)
	check(game.boss_director.setup_data.helper_id == &"", "P1 morto não ajuda")
	await _win_boss(game)
	await _check_conclusion(Endings.KINGDOM_POSITIVE, [Endings.DEATH, &""])


func _p1_allied(game: Game) -> void:
	await _army_choice(game, 1)
	check(ReputationState.is_allied(GameState.p1_id()), "P1 aliado")
	await _loot_any_house(game)
	await _bot_fight(game, 5.0)
	await _time_up(game)
	await _p2_intro(game)
	await _army_choice(game, 0)
	await _time_up(game)
	await _wait_boss(game)
	var data := game.boss_director.setup_data
	check(data.kind == BossSelector.Kind.CHARACTER and data.boss_character_id == GameState.p1_id(), "P1 vira o boss")
	await _bot_fight(game, 4.0)
	await _win_boss(game)
	await _check_conclusion(Endings.KINGDOM_POSITIVE, [Endings.NEGATIVE_IMPRISONED, &""])


func _p2_allied(game: Game) -> void:
	await _army_choice(game, 0)
	await _time_up(game)
	await _p2_intro(game)
	await _army_choice(game, 1)
	await _bot_fight(game, 4.0)
	await _time_up(game)
	await _wait_boss(game)
	var data := game.boss_director.setup_data
	check(data.control_switched and game.player.stats.id == GameState.p1_id(), "controle troca para P1")
	check(data.boss_character_id == GameState.p2_id(), "P2 vira o boss")
	await _bot_fight(game, 4.0)
	await _win_boss(game)
	await _check_conclusion(Endings.KINGDOM_POSITIVE, [&"", Endings.NEGATIVE_IMPRISONED])


func _both_allied(game: Game) -> void:
	await _army_choice(game, 1)
	await _time_up(game)
	await _p2_intro(game)
	await _army_choice(game, 1)
	await _time_up(game)
	await _wait_boss(game)
	var data := game.boss_director.setup_data
	check(data.kind == BossSelector.Kind.KNIGHT_KINGDOM_SKIN and data.double_alliance, "aliança dupla x cavaleiro do reino")
	await _win_boss(game)
	await _check_conclusion(Endings.KINGDOM_DOUBLE_ALLIANCE, [Endings.NEGATIVE_VICTORIOUS, Endings.NEGATIVE_VICTORIOUS])


func _p2_dies(game: Game) -> void:
	await _time_up(game)
	await _p2_intro(game)
	game.player.health.take_damage(99999.0)
	await _wait(0.5)
	check(game.tombstone.is_open, "lápide do P2")
	_press(Actions.CONFIRM)
	await _check_conclusion(Endings.KINGDOM_NEGATIVE, [&"", Endings.DEATH])


func _p2_dies_boss(game: Game) -> void:
	await _time_up(game)
	await _p2_intro(game)
	await _time_up(game)
	await _wait_boss(game)
	game.player.health.take_damage(99999.0)
	await _wait(0.5)
	_press(Actions.CONFIRM)
	await _check_conclusion(Endings.KINGDOM_NEGATIVE, [&"", Endings.DEATH])


# --- Passos ---

func _wait_game() -> Game:
	for i in 600:
		await get_tree().process_frame
		var scene := get_tree().current_scene as Game
		if scene and scene.intro.is_playing and not GameManager.is_changing_scene():
			return scene
	return null


func _skip_intro(game: Game) -> void:
	while game.intro.is_playing:
		_press(Actions.CONFIRM)
		await _wait(0.1)
	await _wait(0.5)
	check(game.tutorial.is_open, "tutorial aberto (cronômetro parado)")
	_press(Actions.CONFIRM)
	await _wait(0.2)
	check(game.phase == Game.Phase.PLAYING, "P1 jogando")


func _p2_intro(game: Game) -> void:
	for i in 300:
		if game.tutorial.is_open:
			break
		await _wait(0.05)
	check(game.tutorial.is_open, "tutorial do P2")
	_press(Actions.CONFIRM)
	await _wait(0.2)
	check(game.phase == Game.Phase.PLAYING and GameState.current_index == 1, "P2 jogando")


func _army_choice(game: Game, index: int) -> void:
	game.player.global_position = game.level.camp.global_position + Vector2(0, 160)
	await _choose(game, index)
	await _wait(0.3)


func _choose(game: Game, index: int) -> void:
	for i in 200:
		if game.dialog.is_open:
			break
		await _wait(0.02)
	check(game.dialog.is_open, "diálogo abriu")
	_press(Actions.CONFIRM) # completa o texto
	await _wait(0.1)
	game.dialog._on_choice_pressed(index)
	await _wait(0.1)


func _rescue_first_house(game: Game) -> void:
	var house: VillagerHouse = game.level.get_houses()[0]
	var before := ReputationState.get_heroism(GameState.current_id())
	game.player.global_position = house.global_position + Vector2(0, 90)
	await _choose(game, 0)
	for i in 100:
		if game.qte._running and game.qte._delay_left <= 0.0:
			break
		await _wait(0.02)
	game.qte._bar.value = game.qte._bar.window_start + game.qte._bar.window_size * 0.5
	_press(Actions.ATTACK)
	await _wait(0.8)
	check(house.state == GameState.HouseState.RESCUED, "morador resgatado pelo QTE")
	await _choose(game, 1) # saquear
	check(house.looted, "casa saqueada")
	var after := ReputationState.get_heroism(GameState.current_id())
	check(after == before + ReputationState.config.rescue_gain - ReputationState.config.loot_loss, "heroísmo: resgate e saque")
	game.player.global_position = game.level.marker("PlayerStart")
	await _wait(0.2)


func _loot_any_house(game: Game) -> void:
	var house: VillagerHouse = game.level.get_houses()[1]
	game.player.global_position = house.global_position + Vector2(0, 90)
	await _choose(game, 0)
	check(house.looted, "aliado saqueia livremente")


## Troca o controle por IA por alguns segundos para exercitar o combate de verdade.
func _bot_fight(game: Game, seconds: float) -> void:
	var human := game.player.controller
	var bot := AIController.new()
	bot.profile = game.player.stats.ai_profile
	var p := game.player
	p.controller = bot
	p.add_child(bot)
	p.move_child(bot, p.state_machine.get_index())
	bot.setup(p)
	var start_hp := p.health.current
	var t := 0.0
	while t < seconds and is_instance_valid(p) and not p.dead:
		# Mantém o bot vivo: o teste é de estabilidade, não de balanceamento.
		if p.health.current < start_hp * 0.5:
			p.health.heal(start_hp)
		p.invulnerable_left = 1.0
		await _wait(0.1)
		t += 0.1
	if is_instance_valid(p):
		p.controller = human
		bot.queue_free()


func _time_up(game: Game) -> void:
	game._time_left = 0.05
	await _wait(0.2)
	for i in 400:
		if game.phase != Game.Phase.SWITCHING:
			break
		await _wait(0.05)


func _wait_boss(game: Game) -> void:
	for i in 400:
		if game.phase == Game.Phase.BOSS and game.player.controller.enabled:
			break
		await _wait(0.05)
	check(game.phase == Game.Phase.BOSS, "luta do boss começou")


func _win_boss(game: Game) -> void:
	game.boss_director.boss_health().take_damage(999999.0)
	await _wait(0.2)


func _check_conclusion(kingdom: StringName, endings: Array) -> void:
	for i in 600:
		if get_tree().current_scene and get_tree().current_scene.scene_file_path == GameManager.SCENE_CONCLUSION \
				and not GameManager.is_changing_scene():
			break
		await _wait(0.05)
	check(get_tree().current_scene.scene_file_path == GameManager.SCENE_CONCLUSION, "tela de conclusão")
	check(GameState.kingdom_ending() == kingdom, "final do reino = %s (veio %s)" % [kingdom, GameState.kingdom_ending()])
	var ids := [GameState.p1_id(), GameState.p2_id()]
	for i in 2:
		var got := GameState.character_ending(ids[i])
		_log.append("  final %s: %s" % [ids[i], got])
		if endings[i] != &"":
			check(got == endings[i], "final %s = %s (veio %s)" % [ids[i], endings[i], got])
	for i in 4:
		_press(Actions.CONFIRM)
		await _wait(0.6)
	for i in 200:
		if get_tree().current_scene and get_tree().current_scene.scene_file_path == GameManager.SCENE_CREDITS:
			break
		await _wait(0.05)
	check(get_tree().current_scene.scene_file_path == GameManager.SCENE_CREDITS, "créditos")


func _press(action: StringName) -> void:
	var down := InputEventAction.new()
	down.action = action
	down.pressed = true
	Input.parse_input_event(down)
	var up := InputEventAction.new()
	up.action = action
	up.pressed = false
	Input.parse_input_event.call_deferred(up)


func _wait(seconds: float) -> void:
	await get_tree().create_timer(seconds, true, false, true).timeout
