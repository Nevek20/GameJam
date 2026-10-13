class_name QTEPanel
extends Control
## Quick Time Event genérico: a barra esvazia e o jogador clica (ação "attack")
## quando ela passa pela janela. Uso: var ok: bool = await qte.run(config, titulo)

signal finished(success: bool)

var _config: QTEConfig
var _running: bool = false
var _delay_left: float = 0.0
var _token: int = 0
var _tween: Tween

@onready var _bar: QTEBar = %Bar
@onready var _title: Label = %Title
@onready var _hint: Label = %Hint
@onready var _box: Control = %Box


func _ready() -> void:
	hide()
	set_process(false)


func run(config: QTEConfig, title: String) -> bool:
	start(config, title)
	return await finished


func start(config: QTEConfig, title: String) -> void:
	_config = config
	_token += 1
	var start_min := minf(config.window_start_min, 1.0 - config.window_size)
	var start_max := minf(config.window_start_max, 1.0 - config.window_size)
	_bar.set_window(randf_range(start_min, maxf(start_min, start_max)), config.window_size)
	_bar.value = 1.0
	_delay_left = config.start_delay
	_title.text = title
	_hint.text = Texts.ui("qte.hint", {"key": Settings.get_binding_text(Actions.ATTACK)})
	_running = true
	show()
	set_process(true)
	_box.pivot_offset = _box.size * 0.5
	_box.scale = Vector2(0.6, 0.6)
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_box, "scale", Vector2.ONE, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Interrompe (morte, troca de personagem): conta como falha para quem espera.
func cancel() -> void:
	if not visible:
		return
	_token += 1
	_running = false
	set_process(false)
	hide()
	finished.emit(false)


func _process(delta: float) -> void:
	if not _running:
		return
	if _delay_left > 0.0:
		_delay_left -= delta
		return
	_bar.value = maxf(_bar.value - delta / maxf(_config.duration, 0.05), 0.0)
	if _bar.value <= 0.0:
		_resolve(false)


func _unhandled_input(event: InputEvent) -> void:
	if not _running or not event.is_action_pressed(Actions.ATTACK):
		return
	get_viewport().set_input_as_handled()
	if _delay_left > 0.0:
		return
	_resolve(_bar.is_in_window())


func _resolve(success: bool) -> void:
	_running = false
	set_process(false)
	var token := _token
	AudioManager.play_sfx(&"qte_success" if success else &"qte_fail")
	_bar.result_color = Color(0.4, 1.0, 0.5) if success else Color(1.0, 0.25, 0.3)
	_bar.queue_redraw()
	_hint.text = Texts.ui("qte.success" if success else "qte.fail")
	if _tween:
		_tween.kill()
	_tween = create_tween()
	if success:
		_box.scale = Vector2(1.15, 1.15)
		_tween.tween_property(_box, "scale", Vector2.ONE, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		for i in 4:
			_tween.tween_property(_box, "position:x", _box.position.x + (8.0 if i % 2 == 0 else -8.0), 0.04)
		_tween.tween_property(_box, "position:x", _box.position.x, 0.04)
	get_tree().create_timer(0.55, false).timeout.connect(_finish.bind(token, success), CONNECT_ONE_SHOT)


func _finish(token: int, success: bool) -> void:
	if token != _token:
		return
	hide()
	finished.emit(success)
