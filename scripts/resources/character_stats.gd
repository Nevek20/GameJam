class_name CharacterStats
extends Resource
## Todos os números de um personagem jogável. Editar no Inspector (resources/characters).

@export var id: StringName = &""
## Cor do placeholder (enquanto não há sprite).
@export var body_color: Color = Color(1, 0.6, 0.85)
@export var accent_color: Color = Color(1, 0.85, 0.3)
@export var placeholder_accent: PlaceholderShape.Accent = PlaceholderShape.Accent.CROWN

@export_group("Visual (troque aqui os sprites)")
## Sprite estático. Se definido, substitui o placeholder.
@export var texture: Texture2D
## Animações (idle, move, attack, dash, hurt, dead). Tem prioridade sobre texture.
@export var sprite_frames: SpriteFrames
@export var sprite_scale: Vector2 = Vector2.ONE
## Posição do desenho em relação ao corpo (pixels da textura). Ajuste se o sprite
## ficar deslocado; a hitbox não muda.
@export var sprite_offset: Vector2 = Vector2.ZERO
## Tamanho do corpo (largura x altura): desenho placeholder e área que recebe dano.
@export var body_size: Vector2 = Vector2(40, 72)
## Colisão com o cenário: retângulo nos pés (largura x altura).
@export var collision_size: Vector2 = Vector2(34, 20)
## Ponto de onde saem golpes e projéteis, relativo ao centro do corpo (nó AttackOrigin).
@export var attack_origin_offset: Vector2 = Vector2.ZERO

@export_group("Vida")
@export var max_health: float = 100.0
## Invencibilidade após tomar dano.
@export var hurt_invulnerability: float = 0.5
## Tempo travado após tomar dano.
@export var hurt_stun: float = 0.18

@export_group("Movimento")
@export var move_speed: float = 260.0
@export var acceleration: float = 2200.0
@export var friction: float = 2600.0

@export_group("Dash")
@export var dash_distance: float = 190.0
@export var dash_duration: float = 0.16
@export var dash_cooldown: float = 0.6
## i-frames durante o dash (true = invencível durante toda a duração).
@export var dash_invulnerable: bool = true

@export_group("Defesa e parry")
## Janela de parry no início da defesa.
@export var parry_window: float = 0.18
@export var parry_cooldown: float = 0.7
## Multiplicador de dano ao defender fora da janela de parry.
@export var block_damage_multiplier: float = 0.35
@export var block_move_multiplier: float = 0.35
## Atordoamento aplicado no atacante ao aparar.
@export var parry_stun: float = 1.0
@export var parry_knockback: float = 380.0

@export_group("Habilidades (Strategy: troque o Resource)")
@export var attack: Ability
@export var skill_q: Ability
@export var skill_e: Ability
@export var ultimate: Ability

@export_group("IA (ajudante e boss)")
## Como este personagem luta quando controlado pela IA.
@export var ai_profile: AIProfile

@export_group("Input")
## Por quanto tempo um input fica guardado (buffer), em segundos.
@export var input_buffer: float = 0.15
