class_name GameScale
extends Resource
## Escala central do jogo. Mudar o tamanho de tudo = editar resources/config/game_scale.tres.
## A escala de cada tipo é multiplicada pela escala global do mundo. Tamanhos, velocidades,
## distâncias de dash e alcances dos ataques acompanham a escala (proporcionais).

enum Kind { PLAYER, ENEMY, BOSS, NPC, SCENERY, PROJECTILE, EFFECTS }

const PATH := "res://resources/config/game_scale.tres"

## Multiplica todas as escalas abaixo.
@export var world_scale: float = 1.0
@export_group("Escala por tipo")
@export var player_scale: float = 1.0
@export var enemy_scale: float = 1.0
@export var boss_scale: float = 1.0
@export var npc_scale: float = 1.0
## Casas, muralhas, árvores, barris e outros objetos do cenário.
@export var scenery_scale: float = 1.0
## Tamanho dos projéteis (a velocidade e o alcance seguem quem atirou).
@export var projectile_scale: float = 1.0
## Partículas, números de dano e rastro.
@export var effects_scale: float = 1.0
@export_group("Câmera")
## Maior = mais perto (tudo parece maior na tela).
@export var camera_zoom: float = 1.0
@export_group("Interface")
## Escala do HUD e dos menus, independente do mundo.
@export var ui_scale: float = 1.0

static var _current: GameScale


static func current() -> GameScale:
	if _current == null:
		_current = load(PATH) as GameScale
		if _current == null:
			_current = GameScale.new()
	return _current


## Escala final de um tipo (global x tipo).
static func of(kind: Kind) -> float:
	var c := current()
	var k := 1.0
	match kind:
		Kind.PLAYER:
			k = c.player_scale
		Kind.ENEMY:
			k = c.enemy_scale
		Kind.BOSS:
			k = c.boss_scale
		Kind.NPC:
			k = c.npc_scale
		Kind.SCENERY:
			k = c.scenery_scale
		Kind.PROJECTILE:
			k = c.projectile_scale
		Kind.EFFECTS:
			k = c.effects_scale
	return c.world_scale * k


## Aplica a escala da interface a uma tela inteira (Control que ocupa a tela toda).
static func apply_ui(root: Control) -> void:
	var s := current().ui_scale
	if is_equal_approx(s, 1.0):
		return
	var viewport_size := root.get_viewport_rect().size
	root.set_anchors_preset(Control.PRESET_TOP_LEFT)
	root.position = Vector2.ZERO
	root.scale = Vector2.ONE * s
	root.size = viewport_size / s
