extends Control
## Créditos finais: rolam sozinhos e voltam ao menu.

@onready var _view: CreditsView = %CreditsView


func _ready() -> void:
	GameScale.apply_ui(self)
	AudioManager.play_music(&"credits")
	_view.finished.connect(GameManager.go_to_menu)
