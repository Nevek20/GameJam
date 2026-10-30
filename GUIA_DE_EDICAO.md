# Guia de edição do jogo

Este guia é para quem **não programou** o jogo. Ele mostra onde mexer para trocar arte, sons, textos e números. Quase tudo se edita no **Inspector** do Godot, sem abrir código.

> **Como abrir:** Godot **4.7.x** → *Import* → escolha o `project.godot` desta pasta.
> **Rodar o jogo:** F5. **Rodar só a fase:** abra `scenes/game/game.tscn` e aperte F6.

Termos usados aqui:
- **Resource (`.tres`):** arquivo de configuração. Dê dois cliques nele no painel *FileSystem* e edite os campos no *Inspector*.
- **Cena (`.tscn`):** dê dois cliques para abrir. Os nós aparecem no painel *Scene*.
- **Nó:** um item da árvore da cena (por exemplo `Visual`, `Hurtbox`, `AttackOrigin`).

---

## 1. Estrutura de pastas

| Pasta | O que tem |
|---|---|
| `assets/` | Arte e áudio finais. `assets/sprites/mage/` tem os sprites do Mago; `assets/shaders/` tem o fundo provisório |
| `data/` | **Todos os textos** em JSON: diálogos, tutorial, introdução e cutscenes, finais, lápides, nomes, créditos e interface |
| `resources/` | **Todos os números** (`.tres`): personagens, habilidades, inimigos, boss, partida, escala, juice, áudio |
| `resources/characters/` | `princess.tres` e `mage.tres` (vida, velocidade, dash, defesa, sprites, habilidades) |
| `resources/abilities/` | Uma habilidade por arquivo: `princess/`, `mage/`, `enemies/` (inclui os ataques do boss) |
| `resources/enemies/` | `soldier.tres`, `runner.tres` (rápido), `elite.tres`, `kingdom_knight.tres` |
| `resources/bosses/` | `knight_boss.tres` (o cavaleiro: fases, ataques e as duas skins) |
| `resources/ai/` | IA da Princesa e do Mago (ajudante/boss) e `character_boss_profile.tres` |
| `resources/config/` | Partida, escala/câmera, juice, áudio, barris, revive, cutscenes, finais, interface |
| `resources/sprites/` | `mage_frames.tres` (animações do Mago) |
| `scenes/` | Cenas do jogo: `game/` (fase), `world/` (vila, casas, barris, muralhas), `player/`, `enemies/`, `combat/`, `effects/` |
| `ui/` | Telas e interface: menu, opções, créditos, HUD, diálogo, QTE, introdução, tutorial, escolha de personagem, finais, pausa e tema |
| `scripts/` | Código (não precisa mexer para editar conteúdo) |
| `tests/` | Testes automáticos (ver seção 12) |

---

## 2. Trocar sprites

**Regra geral:** cada personagem ou objeto tem um nó `Visual`, separado da colisão e das hitboxes. Trocar a arte **não muda** o tamanho da hitbox nem o tempo dos ataques. Enquanto não houver sprite, aparece um placeholder geométrico (nó `Visual/Placeholder`), que some sozinho quando você coloca a arte.

**Pivô (origem):** personagens, inimigos, boss, moradores e barris têm a origem **nos pés**. O desenho deve ficar acima da origem, com os pés em cima do ponto (0, 0).

### Personagens (Princesa e Mago)
1. Crie um **SpriteFrames**: botão direito em `resources/sprites/` → *New Resource* → *SpriteFrames*. Ou duplique `mage_frames.tres`.
2. Crie as animações com estes nomes exatos: `idle`, `move`, `attack`, `dash`, `parry`, `hurt`, `dead`.
   - Habilidades podem ter animação própria **com o mesmo nome do `id` da habilidade**: `dash_slash`, `spin_slash`, `great_slash`, `fireball`, `chain_lightning`, `arcane_beam`. Se não existir, toca `attack`.
   - Marque *Loop* em `idle` e `move`.
3. Abra `resources/characters/princess.tres` (ou `mage.tres`) → grupo **Visual** → arraste o SpriteFrames para `sprite_frames`. Para um sprite parado, use `texture`.
4. Ajuste o tamanho em `sprite_scale` (exemplo do Mago: `0.3`).
5. **Offset sem mexer na hitbox:** `sprite_offset` move só o desenho, em pixels da imagem. Valores maiores em Y descem o desenho. Ao virar para a esquerda o offset espelha sozinho.
6. Se a hitbox precisar mudar: `body_size` (largura × altura do corpo e área que recebe dano) e `collision_size` (retângulo dos pés que colide com o cenário).

> **Exemplo real:** o Mago usa os frames da branch `art`, já recortados para `assets/sprites/mage/<animação>/00.png...` e ligados em `resources/sprites/mage_frames.tres`. A Princesa ainda não tem PNGs: só apareceram em vídeo. Quando chegarem, siga os passos acima.

### Inimigos e boss
- **Soldado, rápido, elite, cavaleiro:** `resources/enemies/<nome>.tres` → campo `skin` → `texture` / `sprite_frames` / `sprite_offset`. O tamanho fica em `sprite_scale`, `body_size` e `collision_size` do próprio `.tres`.
- **Boss (cavaleiro):** `resources/bosses/knight_boss.tres`. A arte vai em **duas skins**:
  - `army_skin`: skin do exército inimigo (boss normal).
  - `kingdom_skin`: skin do reino (variação do bem).
  
  O moveset é o mesmo nas duas. Só a skin muda.

### Moradores e casas
Abra `scenes/world/level.tscn` → `World/Houses/House1` (até `House5`) → Inspector:
- `house_texture`: arte da casa.
- `villager_texture`: arte do morador.
- `villager_size`: tamanho do morador.

### Barris e poções
Em `resources/config/barrel_config.tres`:
- `texture`: arte do barril.
- `potion_texture`: arte da poção.
- `body_size` e `potion_size`: tamanhos.

### Cenário (muralhas, fogo, bandeiras, árvores)
- **Muralha:** `scenes/world/prop_wall.tscn` → nó `Visual` → campo `texture`. Vale para todas as muralhas, inclusive as do limite do mapa.
- **Fogo:** `scenes/world/prop_fire.tscn` → nó `Visual` → `texture`.
- **Bandeira:** `scenes/world/prop_banner.tscn` → nó `Visual` → `texture`.
- **Árvore:** `scenes/world/prop_tree.tscn` → nó `Sprite2D` (ligue `visible` e esconda o nó `Shape`).
- **Chão:** `scenes/world/level.tscn` → nó `Ground`. É um shader provisório; troque por uma textura se quiser.

### Interface
- **Ícones das habilidades no HUD:** campo `icon` de cada habilidade (`resources/abilities/...`).
- **Imagens da introdução e das cutscenes:** campo `images` em `resources/config/intro_config.tres`, `cutscene_switch.tres` e `cutscene_boss.tres`.
- **Imagens dos finais:** `resources/config/ending_images.tres`.
- **Lápide:** `ui/endings/tombstone_view.tscn` → `tombstone_texture`.

---

## 3. Sons

O jogo **não tem arquivos de áudio**. Todos os pontos de encaixe já estão prontos.

1. Coloque o arquivo (`.ogg` ou `.wav`) em `assets/audio/sfx/` ou `assets/audio/music/`.
2. Abra `resources/config/audio_library.tres`.
3. Em `sfx` (efeitos) ou `music` (músicas), arraste o arquivo para o valor da chave certa.

Chave vazia = silêncio, sem erro. Os volumes (Geral, Música, Efeitos) usam os buses `Master`, `Music` e `SFX`.

| Chave | Quando toca |
|---|---|
| `attack_slash` / `attack_mana` | ataque automático da Princesa / do Mago |
| `skill_dash_slash`, `skill_spin`, `ult_great_slash` | Q, E e R da Princesa |
| `skill_fireball`, `skill_lightning`, `ult_beam` | Q, E e R do Mago |
| `hit` | golpe acerta um inimigo |
| `hurt` | jogador toma dano |
| `block` | golpe defendido (fora da janela de parry) |
| `parry` / `parry_success` | começa a defender / parry perfeito |
| `dash` | dash (jogador e elite) |
| `death` | morte (jogador e inimigos) |
| `downed` / `revive` | personagem caiu / foi revivido (luta final) |
| `enemy_attack` | inimigo começa um ataque |
| `qte_success` / `qte_fail` | resultado do QTE |
| `rescue` / `loot` | morador resgatado / casa saqueada |
| `barrel_hit` / `barrel_break` / `potion_pickup` | barril atingido / quebrado / poção coletada |
| `fight_start` / `fight_end` | escolheu o exército / acabou a luta com o exército |
| `boss_start`, `boss_roar`, `boss_defeated` | começo da luta final, rugido (entrada e troca de fase), vitória |
| `boss_radial`, `boss_shockwave`, `boss_slam` | disparo em círculo, onda de choque, queda do boss |
| `ui_click` / `ui_focus` | clique e foco nos botões |

| Música | Quando toca |
|---|---|
| `menu` | menu principal |
| `intro` | introdução |
| `gameplay` | vila |
| `boss` | luta final |
| `ending` | tela de finais |
| `credits` | créditos finais |

O som de cada habilidade também pode ser trocado direto nela, no campo `sfx_cast` do `.tres`.

---

## 4. Botões e menus

- **Textos:** `data/ui.json`. Exemplos: `menu.play`, `options.title`, `pause.resume`, `choice.title`.
- **Estilo de todos os botões** (cores, borda, hover): `ui/theme/main_theme.tres` → *Button* → *Styles*.
  - `normal`: botão parado.
  - `hover`: mouse em cima, com borda amarela de 3 px nos quatro lados.
  - `pressed`: clicando.
  - `focus`: vazio de propósito; o foco do teclado é mostrado pelo aumento de escala e pela cor do texto.
  - Para mudar a borda do hover: abra `btn_hover` e altere `border_color` / `border_width_*`. Mantenha os quatro lados iguais.
- **Aumento de escala do botão:** cada botão usa `ui/theme/juicy_button.gd`. No Inspector do botão há `hover_scale` e `press_scale`.
- **Posição e tamanho:** abra a cena e mova o nó.
  - Menu: `ui/menu/main_menu.tscn` → `MenuBox` (os 3 botões).
  - Opções: `ui/options/options_panel.tscn`.
  - Pausa: `ui/pause/pause_menu.tscn`.
  - Escolha de personagem: `ui/choice/character_choice.tscn`.
  - Use *Layout → Anchors* no topo do editor para alinhar.
- **Escala de toda a interface:** campo `ui_scale` em `resources/config/game_scale.tres`.

---

## 5. Posição de objetos e tamanho do mapa

Tudo fica em `scenes/world/level.tscn`. Mova os nós arrastando no editor.

| O que | Nó |
|---|---|
| **Tamanho do mapa** | `World/MapBoundary` → `map_size`. O retângulo laranja no editor mostra a área jogável. As muralhas e os limites da câmera se ajustam sozinhos |
| Casas (com morador) | `World/Houses/House1` … `House5` |
| Acampamento do exército | `World/ArmyCamp` (os soldados de enfeite ficam em `ArmyCamp/Soldiers`) |
| Muralhas internas, fogo e bandeiras | `World/Invasion/...` |
| Árvores | `World/Props/Tree1` … |
| **Barris** | `World/BarrelSpawner/Barrel1` … `Barrel12`. Cada Marker2D é um barril: mova, duplique (Ctrl+D) ou apague |
| Início dos jogadores | `Markers/PlayerStart` (os dois personagens começam aqui) |
| Luta final | `Markers/ArenaPlayer`, `Markers/ArenaBoss`, `Markers/ArenaHelper` |
| Spawns do exército | `World/ArmyCamp/Spawns/Spawn1` … `Spawn5` |
| Spawns dos cavaleiros do reino | `Markers/KnightSpawns/Spawn1` … |

> Para colocar uma casa nova: duplique `House1` (Ctrl+D), mova e mude `house_id` (único, ex.: `house_6`) e `dialogue_key` (as falas em `data/dialogues.json`, ver seção 8).

---

## 6. Triggers e áreas

| Gatilho | Onde | Como mexer |
|---|---|---|
| Conversa com o morador | `scenes/world/villager_house.tscn` → `InteractionZone/CollisionShape2D` (círculo amarelo no editor) | Mude o `radius` do círculo ou mova o nó `InteractionZone` |
| Escolha do exército | `scenes/world/army_camp.tscn` → `InteractionZone/CollisionShape2D` (círculo vermelho) | Igual ao de cima |
| Pegar poção | `scenes/world/potion.tscn` → `CollisionShape2D` | Mude o raio |
| Reviver (luta final) | Não é área: distância em `resources/config/revive_config.tres` → `revive_distance` | |
| **Boss** | Não é área. Começa quando o tempo do Personagem 2 acaba, ou quando ele completa os objetivos e escolhe avançar | Tempo em `match_config.tres` → `character_durations` |
| **Objetivos** | Não é área. P1: nenhuma casa com morador esperando E exército derrotado. P2: exército derrotado | A tecla de avançar é a ação `advance_stage` (Tab, remapeável nas Opções) |

---

## 7. Origem dos golpes e hitboxes

- **De onde sai o golpe:** cada personagem e inimigo tem o nó **`AttackOrigin`** (Marker2D, a cruz no editor) em `scenes/player/player.tscn` e `scenes/enemies/enemy.tscn`. Ataques e projéteis saem dele.
  - Para ajustar **por personagem**, use o campo `attack_origin_offset` do `.tres` (por exemplo `resources/characters/mage.tres` → `attack_origin_offset = (10, -20)` para sair do cajado). O valor é somado ao centro do corpo.
- **Forma, tamanho, alcance e duração:** em cada habilidade (`resources/abilities/...`):

| Campo | O que faz |
|---|---|
| `shape` | RECT (retângulo), TRIANGLE ou CIRCLE |
| `size` | RECT: comprimento × largura. TRIANGLE: comprimento × base. CIRCLE: x = raio |
| `forward_offset` | Distância do centro do golpe até o personagem, na direção da mira |
| `windup` / `active_time` / `recovery` | Anticipação (aviso), fase com hitbox e recuperação |
| `cooldown`, `damage`, `knockback` | Tempo de recarga, dano e empurrão |
| `orbit_radius`, `orbit_speed` | Corte giratório: o círculo gira em volta do personagem |
| `rehit_interval` | Dano por tick (feixe). 0 = acerta cada alvo uma vez |
| `ai_range` | Distância em que a IA usa o golpe |

- **Projéteis** (`ProjectileAbility`): `radius`, `speed`, `max_range`, `spawn_offset`, `pierce`, `glow_scale`.
- **Raio encadeado:** `first_range`, `chain_range`, `max_jumps`, `damage_falloff`.

---

## 8. Textos e imagens

| Texto | Arquivo |
|---|---|
| Falas dos moradores | `data/dialogues.json` → `houses.<dialogue_key>` (`speaker`, `ask`, `rescued`, `failed`, `loot_ask`, `loot_allied`). Se a chave não existir, usa `houses.default` |
| Exército | `data/dialogues.json` → `army.*` |
| Pergunta de objetivos completos | `data/dialogues.json` → `objectives.*` e `choices.advance` / `choices.explore` |
| Tutorial | `data/tutorial.json`. `{move}`, `{dash}` etc. viram as teclas atuais |
| Introdução e cutscenes | `data/intro.json` → listas `slides` (introdução), `switch` (troca para o Mago) e `boss` (antes do boss) |
| Finais e lápides | `data/endings.json` |
| Nomes | `data/names.json` |
| Créditos | `data/credits.json` (aceita BBCode) |
| Interface (menu, HUD, avisos) | `data/ui.json` |

**Imagens das cutscenes:**
- `intro_config.tres`, `cutscene_switch.tres` e `cutscene_boss.tres` têm a lista `images`.
- Cada imagem usa a legenda da mesma posição na lista indicada em `captions_key`.
- Avança com Enter ou clique esquerdo.

---

## 9. Parâmetros (Resources)

| Resource | O que ajusta |
|---|---|
| `characters/princess.tres`, `mage.tres` | Vida, velocidade, aceleração, dash (`dash_distance`, `dash_duration`, `dash_cooldown`), defesa e parry (`parry_window`, `parry_cooldown`, `block_damage_multiplier`), `body_size`, `collision_size`, `attack_origin_offset`, sprites, habilidades (`attack`, `skill_q`, `skill_e`, `ultimate`), IA, `input_buffer` |
| `abilities/**` | Ver seção 7 |
| **Dashes de ataque** (`princess/dash_slash.tres`, `enemies/elite_lunge.tres`, `enemies/boss_lunge.tres`) | `windup` = **telegraph**, `active_time` = **duração do dash**, `dash_distance`, `ease_power` (curva: 2 = rápido e desacelera), `recovery` (parado e vulnerável), `cooldown`, `skip_telegraph_for_player` (Princesa do jogador sai na hora) |
| `enemies/soldier.tres` | Vida, velocidade, ataques, `attack_interval`, `aggro_range`, `body_size` |
| `enemies/runner.tres` (rápido) | Pouca vida, muita velocidade e pouco dano. Quantos aparecem e em grupos de quantos: `match_config.tres` → cada onda → `fast_groups`, `fast_group_size`, `fast_group_spread` |
| `enemies/elite.tres` | `dash_chance`, `block_chance`, `block_duration`, `block_damage_multiplier`, ataques e pesos |
| `bosses/knight_boss.tres` | Vida, `preferred_distance`, `max_same_attack_in_row` (não repetir ataque), `phases` (cada fase: `health_threshold`, `speed_multiplier`, `attack_speed`, `attack_interval`, `attacks`, `attack_weights`), skins |
| Ataques do boss (`enemies/boss_*.tres`) | `boss_radial`: `per_wave`, `waves`, `wave_interval`, `angle_step_per_wave`, `speed`, `damage`. `boss_leap`: `follow_time`, `follow_speed`, `warn_time`, `impact_radius`, `recovery`. `boss_shockwave`: `radius`, `ring_thickness`, `expand_time`, `waves`, `wave_interval`. `boss_combo`: `hits`, `hit_interval`, `step_distance`, `slash` (forma e dano de cada golpe). `boss_lunge`: dash. `boss_slash`: corte simples |
| `ai/character_boss_profile.tres` | Personagem como boss: `health_multiplier`, `damage_multiplier`, `speed_multiplier`, `windup_multiplier`, `attack_speed_multiplier`, `cooldown_multiplier` (global) e `attack_cooldown`, `skill_q_cooldown`, `skill_e_cooldown`, `ultimate_cooldown` (0 = usa o da habilidade) |
| `ai/princess_ai.tres`, `mage_ai.tres` | IA (ajudante e boss): distância preferida, chance de usar habilidades, dash e parry |
| `config/match_config.tres` | Ordem dos personagens, `character_durations`, QTE (`qte`: `duration`, `window_size`, `start_delay`, `invulnerable`), ondas (`confront_waves`, `alliance_waves`), `max_active_enemies`, reforço após a morte do P1 (`death_enemy_*`), boss, revive |
| `config/barrel_config.tres` | Vida do barril, `max_barrels`, `respawn_each_phase`, `drop_chance` (0.5 = 50%), cura (`heal_is_percent`, `heal_amount`, `heal_percent`), `potion_lifetime` |
| `config/revive_config.tres` | `downed_time` (tempo caído), `revive_time` (segurar a tecla), `revive_distance`, `revive_health`, `invulnerability_after` |
| `config/reputation_config.tres` | Heroísmo inicial e máximo, ganhos (resgate, enfrentar, por inimigo), perda por saque, `positive_threshold` |
| `config/juice_config.tres` | Shake, hit stop, flash, knockback, squash, partículas, números de dano, rastro, zoom, fade (cada um com liga/desliga) |
| `config/game_scale.tres` | Escala e câmera (seção 10) |
| `config/ui_config.tres` | Máquina de escrever, lápide, banner, créditos, `attack_block_after_screen` (trava do ataque ao voltar de uma tela) |

---

## 10. Escala e câmera

Tudo em `resources/config/game_scale.tres`:

| Campo | O que faz |
|---|---|
| `camera_zoom` | **O jeito mais simples de deixar tudo maior ou menor na tela.** 1.5 = tudo 50% maior |
| `world_scale` | Multiplica o tamanho de todas as entidades e dos golpes (velocidades, dashes e alcances acompanham). As posições do mapa não mudam |
| `player_scale`, `enemy_scale`, `boss_scale`, `npc_scale`, `scenery_scale`, `projectile_scale`, `effects_scale` | Ajuste fino por tipo |
| `ui_scale` | Interface (HUD e menus), independente do mundo |

Dica: se aumentar muito `world_scale`, aumente também `map_size` (seção 5) para o mapa não ficar apertado.

---

## 11. Criar um inimigo ou uma habilidade nova

**Inimigo novo:**
1. Duplique `resources/enemies/soldier.tres` (botão direito → *Duplicate*), por exemplo `goblin.tres`.
2. Mude `id`, `skin` (cores ou arte), vida, velocidade e `attacks`. Duplique também `abilities/enemies/soldier_slash.tres` para ter um golpe próprio.
3. Coloque nas ondas: `match_config.tres` → `confront_waves` → uma onda → `primary_enemy` ou `elite_enemy` (ou `fast_enemy`).

**Habilidade nova:**
1. Duplique uma parecida:
   - corte: `sword_slash.tres`;
   - projétil: `mana_bolt.tres`;
   - dash: `dash_slash.tres`;
   - área no chão: `boss_shockwave.tres`.
2. Mude `id` (também é o nome da animação que vai tocar), números e forma.
3. Arraste para o slot do personagem: `characters/<personagem>.tres` → `attack`, `skill_q`, `skill_e` ou `ultimate`.

---

## 12. Testes e problemas comuns

**Testes automáticos** (pelo terminal, na pasta do projeto):
```bash
godot --headless --path . res://tests/test_runner.tscn   # regras do boss e finais, curva do dash, textos, carrega todas as cenas
godot --headless --path . res://tests/flow_test.tscn     # joga partidas inteiras: alianças, mortes, escolha, revive, barris, objetivos
```

**Atalhos para testar na mão:**
- F6 em `scenes/game/game.tscn` roda a fase direto.
- Para chegar rápido ao boss, diminua `character_durations` em `match_config.tres` (por exemplo `[20, 20]`).

| Problema | Solução |
|---|---|
| O sprite aparece deslocado | Ajuste `sprite_offset` (não mexa em `body_size`) |
| O personagem flutua ou afunda | O pivô deve estar nos pés: ajuste o Y de `sprite_offset` |
| O personagem "pula" ao trocar de animação | Todos os frames precisam ter o mesmo tamanho e o personagem no mesmo lugar dentro da imagem |
| Texto aparece como `[arquivo:chave]` | A chave não existe no JSON; confira a grafia |
| JSON não carrega | Vírgula sobrando ou aspas erradas. Valide em um validador de JSON online |
| Som não toca | A chave está vazia em `audio_library.tres`, ou o volume está zerado nas Opções |
| Tecla não responde | Opções → Controles → *Restaurar padrão* |
| Mudou algo e quer voltar | Use o Git, ou duplique o `.tres` antes de mexer |
