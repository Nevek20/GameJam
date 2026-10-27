extends Control
## Tela 3: final do Personagem 1, do Personagem 2 e do reino (Enter avança), depois créditos.
## A escolha dos finais vem de funções puras (Endings), via GameState.

@export var ending_images: EndingImages

var _steps: Array[Dictionary] = []
var _index: int = -1
var _waiting: bool = false

@onready var _card: EndingCard = %EndingCard
@onready var _tombstone: TombstoneView = %Tombstone
@onready var _hint: Label = %Hint


func _ready() -> void:
	GameScale.apply_ui(self)
	AudioManager.play_music(&"ending")
	_card.hide()
	for id: StringName in [GameState.p1_id(), GameState.p2_id()]:
		_steps.append({"kind": &"character", "id": id, "ending": GameState.character_ending(id)})
	_steps.append({"kind": &"kingdom", "ending": GameState.kingdom_ending()})
	_tombstone.closed.connect(_next)
	_next.call_deferred()


func _next() -> void:
	_index += 1
	if _index >= _steps.size():
		_waiting = false
		GameManager.go_to_credits()
		return
	var step := _steps[_index]
	var ending: StringName = step["ending"]
	_hint.text = Texts.ui("ending.next", {"key": Settings.get_binding_text(Actions.CONFIRM)})
	if step["kind"] == &"character":
		var id: StringName = step["id"]
		if ending == Endings.DEATH:
			# A lápide tem o próprio Enter; espera o sinal closed.
			_waiting = false
			_card.hide()
			_hint.hide()
			_tombstone.show_for(id)
			return
		var params := {"name": Texts.character_name(id)}
		var tag := Texts.ui("ending.tag_p1" if _index == 0 else "ending.tag_p2", params)
		var title := Texts.text("endings", "characters.%s.%s.title" % [id, ending], params)
		var text := Texts.text("endings", "characters.%s.%s.text" % [id, ending], params)
		var image := ending_images.get_character_image(id, ending) if ending_images else null
		_card.show_ending(tag, title, text, image, _tint_for(ending))
	else:
		var image: Texture2D = ending_images.kingdom.get(ending) if ending_images else null
		_card.show_ending(Texts.ui("ending.tag_kingdom"), Texts.text("endings", "kingdom.%s.title" % ending),
			Texts.text("endings", "kingdom.%s.text" % ending), image, _tint_for(ending))
	_hint.show()
	_waiting = true


func _unhandled_input(event: InputEvent) -> void:
	if _waiting and event.is_action_pressed(Actions.CONFIRM):
		get_viewport().set_input_as_handled()
		AudioManager.play_sfx(&"ui_click")
		_waiting = false
		_next()


static func _tint_for(ending: StringName) -> Color:
	match ending:
		Endings.POSITIVE:
			return Color(0.3, 0.55, 0.45)
		Endings.QUESTIONABLE:
			return Color(0.45, 0.4, 0.3)
		Endings.NEGATIVE_VICTORIOUS, Endings.KINGDOM_DOUBLE_ALLIANCE:
			return Color(0.5, 0.15, 0.25)
		Endings.NEGATIVE_IMPRISONED:
			return Color(0.25, 0.25, 0.35)
		Endings.KINGDOM_NEGATIVE:
			return Color(0.35, 0.1, 0.15)
	return Color(0.25, 0.2, 0.4)
