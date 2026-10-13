extends Node
## Teste de fluxo do esqueleto (headless): P1 sobrevive, P1 morre, P2 morre, aliança.
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
	await _scenario("P1 resgata, enfrenta e sobrevive", _p1_survives)
	await _scenario("P1 morre", _p1_dies)
	await _scenario("aliança e P2 morre", _p2_dies)
	for line: String in _log:
		print(line)
	print("FLUXO: %d falhas" % _failures)
	get_tree().quit(1 if _failures > 0 else 0)


func check(condition: bool, label: String) -> void:
	if not condition:
		_failures += 1
		push_error("FALHOU: " + label)
	_log.append(("  ok " if condition else "  x ") + label)


func _scenario(title: String, body: Callable) -> void:
	_log.append("== " + title)
	GameManager.start_new_game()
	var game := await _wait_game()
	if game == null:
		check(false, "cena do jogo carregou")
		return
	while game.intro.is_playing:
		_press(Actions.CONFIRM)
		await _wait(0.1)
	await _wait(0.5)
	check(game.tutorial.is_open, "tutorial aberto")
	_press(Actions.CONFIRM)
	await _wait(0.2)
	check(game.phase == Game.Phase.PLAYING, "P1 jogando")
	await body.call(game)


func _p1_survives(game: Game) -> void:
	var house: VillagerHouse = game.level.get_houses()[0]
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
	_press(Actions.CONFIRM)
	await _wait(0.1)
	_press(Actions.CONFIRM)
	await _wait(0.2)
	await _army_choice(game, 0)
	await _wait(1.5)
	check(game.encounter.running, "ondas do exército começaram")
	await _time_up(game)
	await _p2_intro(game)
	await _time_up(game)
	await _conclusion(&"")


func _p1_dies(game: Game) -> void:
	game.player.health.take_damage(99999.0)
	await _wait(0.5)
	check(game.tombstone.is_open, "lápide aparece ao morrer")
	_press(Actions.CONFIRM)
	await _p2_intro(game)
	check(game.player.global_position.distance_to(game.level.marker("PlayerStart")) < 5.0, "P2 começa do início do mapa")
	check(game.encounter.health_multiplier > 1.0, "inimigos mais fortes depois da morte do P1")
	await _army_choice(game, 0)
	await _wait(1.5)
	var pool := Pools.get_pool(&"enemies")
	var stronger := false
	for node: Node in pool.get_active():
		var e := node as Enemy
		stronger = stronger or e.health.max_health > e.stats.max_health
	check(stronger, "onda do P2 nasce fortalecida")
	await _time_up(game)
	await _conclusion(Endings.DEATH)


func _p2_dies(game: Game) -> void:
	await _army_choice(game, 1)
	check(ReputationState.is_allied(GameState.p1_id()), "P1 aliado")
	await _time_up(game)
	await _p2_intro(game)
	game.player.health.take_damage(99999.0)
	await _wait(0.5)
	_press(Actions.CONFIRM)
	await _conclusion(Endings.NEGATIVE_VICTORIOUS)


func _wait_game() -> Game:
	for i in 600:
		await get_tree().process_frame
		var scene := get_tree().current_scene as Game
		if scene and scene.intro.is_playing and not GameManager.is_changing_scene():
			return scene
	return null


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
	_press(Actions.CONFIRM)
	await _wait(0.1)
	game.dialog._on_choice_pressed(index)
	await _wait(0.1)


func _time_up(game: Game) -> void:
	game._time_left = 0.05
	await _wait(0.2)
	for i in 400:
		if game.phase != Game.Phase.SWITCHING:
			break
		await _wait(0.05)


func _conclusion(p1_ending: StringName) -> void:
	for i in 600:
		if get_tree().current_scene and get_tree().current_scene.scene_file_path == GameManager.SCENE_CONCLUSION \
				and not GameManager.is_changing_scene():
			break
		await _wait(0.05)
	check(get_tree().current_scene.scene_file_path == GameManager.SCENE_CONCLUSION, "tela de conclusão")
	if p1_ending != &"":
		check(GameState.character_ending(GameState.p1_id()) == p1_ending, "final do P1 = %s" % p1_ending)
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
