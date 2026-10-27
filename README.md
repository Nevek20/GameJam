# Vila Psicodélica (Game Jam)

2D top-down de ação em Godot **4.7** (GDScript tipado). Uma vila de fantasia psicodélica é invadida;
o jogador controla dois personagens, um de cada vez, e as escolhas do primeiro mudam a gameplay do segundo.
Duração: ~5 minutos. Todo texto, imagem e sprite é provisório e foi feito para ser trocado sem mexer em código.

> Abra a pasta no Godot 4.7.x (`project.godot`) e aperte F5. Renderer: Compatibility (funciona em web).

## Estrutura de pastas

```
assets/      arte e áudio finais (vazio por enquanto) + shaders/psychedelic.gdshader
data/        TODOS os textos (JSON): diálogos, tutorial, introdução, finais, lápides, nomes, créditos, UI
resources/   TODOS os números (.tres): personagens, habilidades, inimigos, boss, partida, juice, reputação, áudio
  abilities/   princess/, mage/, enemies/   (uma habilidade = um .tres)
  characters/  princess.tres, mage.tres
  enemies/     soldier.tres, elite.tres, kingdom_knight.tres
  bosses/      knight_boss.tres (fases + skin do exército e do reino)
  ai/          perfis de IA (ajudante/boss) e ajustes do personagem-boss
  config/      match, juice, reputation, ui, audio_library, intro, ending_images, default_settings
scenes/      cenas de gameplay (game, world, player, enemies, combat, effects)
scripts/     lógica: autoload/, core/, components/, resources/ (classes dos .tres), abilities/,
             combat/, effects/, player/, enemies/, world/, game/
ui/          cenas + scripts de interface (menu, options, credits, hud, dialog, qte, intro,
             tutorial, endings, pause, transition, theme)
tests/       testes headless (regras puras + fluxo completo)
```

## Fluxo

`Menu → Introdução (imagens) → Tutorial → Personagem 1 → Personagem 2 → Boss → Conclusão → Créditos`

O autoload **GameManager** guarda a etapa (`Flow`) e troca de tela com fade. A cena `scenes/game/game.tscn`
(script `scripts/game/game.gd`) orquestra a fase única: cronômetro, troca de personagem, morte, boss.

Autoloads (só o essencial, sem gameplay):

| Autoload | Função |
|---|---|
| `GameManager` | fluxo de telas e fade |
| `GameState` | estado do mundo entre personagens (vivo/morto, casas, escolhas, resultado do boss) |
| `ReputationState` | heroísmo e aliança por personagem; só emite sinais |
| `AudioManager` | `play_sfx(nome)` / `play_music(nome)` |
| `Settings` | volumes e teclas, salvos em `user://settings.cfg` |

## Como editar (sem programar)

| Quero mudar... | Onde |
|---|---|
| Qualquer texto | `data/*.json` (aceita BBCode). Casas usam `houses.<dialogue_key>` do `dialogues.json` |
| Imagens da introdução | `resources/config/intro_config.tres` → `images` (uma ou mais). Legendas em `data/intro.json` |
| Imagens dos finais | `resources/config/ending_images.tres` (chaves já criadas, vazias = placeholder) |
| Sprite de personagem | `resources/characters/*.tres` → `texture` ou `sprite_frames` (animações `idle, move, attack, dash, parry, hurt, dead`) |
| Sprite de inimigo/boss | `skin` em `resources/enemies/*.tres`; boss: `army_skin` / `kingdom_skin` |
| Sprite das casas | Inspector da casa na cena `scenes/world/level.tscn` (`house_texture`, `villager_texture`) |
| Lápide | `ui/endings/tombstone_view.tscn` → `tombstone_texture` |
| Sons e músicas | `resources/config/audio_library.tres`: arraste o arquivo para a chave. Vazio = silêncio, sem erro |
| Balanceamento | `resources/**.tres` (vida, velocidade, dash, parry, dano, cooldown, tamanho/alcance/tempo de cada hitbox) |
| Tempo de cada personagem, ondas, QTE | `resources/config/match_config.tres` |
| Ganhos/perdas/limiar de heroísmo | `resources/config/reputation_config.tres` |
| Game feel (shake, hit stop, flash, knockback, squash, partículas, números, rastro, zoom, fade) | `resources/config/juice_config.tres` (cada efeito tem liga/desliga) |
| Tempos de UI (máquina de escrever, lápide, créditos) | `resources/config/ui_config.tres` |
| Ordem dos personagens (quem é P1) | `match_config.tres` → `characters` |

Sprites são independentes das hitboxes: cada entidade tem um nó `Visual` (Sprite2D/AnimatedSprite2D)
separado da colisão, então trocar arte não muda o timing.

## Etapas implementadas (ordem do briefing)

1. **Estrutura, autoloads, InputMap, Resources** – `project.godot` (ações `move_*`, `dash`, `attack`, `parry`,
   `skill_q`, `skill_e`, `ultimate`, `confirm`, `pause`; buses Master/Music/SFX), `scripts/resources/*` (classes
   de parâmetros), `scripts/core/layers.gd` (camadas de colisão documentadas).
2. **Jogador base** – `scripts/player/player.gd` + estados `Idle, Move, Attack, Dash, Parry, Hurt, Dead`.
   Movimento com `Input.get_vector()` (diagonal normalizada), aceleração/atrito (`MovementComponent`),
   dash com i-frames na direção do input (ou da mira), defesa com janela de parry, buffer de input
   (`HumanController`) e cancelamento na recuperação.
3. **Hitbox/hurtbox, pooling e habilidades** – `HitboxComponent`/`HurtboxComponent` (dano 1x por alvo ou por
   tick), `AbilityCaster` (fases anticipação → ativo → recuperação; ganchos `begin_active_phase()` /
   `end_active_phase()` para AnimationPlayer), habilidades como Resources (Strategy):
   `ShapeAbility` (retângulo/triângulo/círculo, lunge, órbita, feixe), `ProjectileAbility`, `ChainAbility`.
   - Princesa: corte (quadrado), corte com dash (triângulo que avança), giratório (círculo em órbita), grande corte.
   - Mago: disparo de mana, bola de fogo (maior, com área), raio encadeado (alcance e saltos parametrizáveis), feixe por tick.
   - `ObjectPool` para hitboxes, projéteis, partículas, números de dano, rastro, raios e inimigos.
4. **Inimigos e HUD** – `Enemy` (soldado, elite com dash/defesa/variação de ataque, cavaleiro do reino) com
   telegraph antes de cada ataque; HUD com vida, heroísmo, tempo, cooldowns, parry e guia de mapa (setas na borda).
5. **Diálogo, escolhas, QTE e moradores** – `DialogBox` e `QTEPanel` genéricos; `InteractionDirector` decide
   resgatar → QTE → saquear. Morte/troca cancela tudo com segurança (token).
6. **Reputação e GameState** – `Reputation.compute_standing()` (puro) + `ReputationState` (sinais).
7. **Exército, cavaleiros e morte** – `ArmyEncounter` (ondas ao enfrentar; cavaleiros ao se aliar),
   lápide e troca imediata; P2 sempre começa no início do mapa; morto não ajuda.
8. **Boss** – `BossSelector.select()` (regra fixa, pura), `BossDirector` (cavaleiro com skin do exército/reino
   e fases, ou personagem aliado como boss com o próprio moveset via IA, troca de controle e ajudante IA).
9. **Menu, opções, créditos, introdução e tutorial** – `ui/menu`, `ui/options` (sliders, remapeamento,
   restaurar padrão), `ui/credits`, `ui/intro`, `ui/tutorial` (painel lateral; cronômetro só começa depois).
10. **Finais e créditos** – `Endings.character_ending()` / `Endings.kingdom_ending()` (puros), `ui/endings/conclusion`.
11. **Juice, áudio, transições** – `scripts/core/juice.gd` (+ `JuiceConfig`), `AudioManager`, `ScreenFade`.

### Correções e melhorias (segunda rodada)

Guia completo, com nomes reais de arquivos e parâmetros: **[GUIA_DE_EDICAO.md](GUIA_DE_EDICAO.md)**.

- Muralhas (`MapBoundary`) definem o limite do mapa e da câmera; escala global em `resources/config/game_scale.tres`.
- Menu com título fixo, borda de hover corrigida; telas de imagem avançam com Enter ou clique esquerdo.
- Inimigo rápido em grupos (`resources/enemies/runner.tres`), barris com poção (`barrel_config.tres`).
- `DashAttackAbility`: ataque com dash compartilhado por elite, boss e Princesa (Q).
- Boss: disparo radial, salto com sombra, dash, onda de choque em 2 anéis, combo; seletor sem repetição.
- `BossSelector.select()` com tela de escolha quando os dois estão vivos e aliados (ou nenhum).
- Cair/reviver na luta final (`revive_config.tres`, tecla F); os dois caídos = morte.
- Objetivos completos → pergunta avançar/explorar (Tab avança depois); invulnerabilidade por fonte.
- Cutscenes na troca Princesa → Mago e depois da escolha do boss (`cutscene_switch.tres`, `cutscene_boss.tres`).

### Regras de final (resumo)

- Personagem: morto → lápide; aliado → vitorioso, ou preso se derrotado pelo outro; senão Positivo/Questionável
  pela faixa de heroísmo (`positive_threshold`).
- Reino: positivo se o lado do reino venceu a luta final; senão negativo (ou **aliança dupla** se os dois se aliaram).

## Camadas de colisão

| # | Nome | Uso |
|---|---|---|
| 1 | world | cenário (paredes, casas, árvores) |
| 2 | player | corpos dos heróis |
| 3 | enemy | corpos inimigos |
| 4 | player_hitbox | ataques dos heróis |
| 5 | enemy_hitbox | ataques inimigos |
| 6 | npc | zonas de interação (casas, acampamento) |
| 7 | projectile | projéteis |
| 8 | player_hurtbox | onde os heróis tomam dano |
| 9 | enemy_hurtbox | onde os inimigos tomam dano |

## Testes

```bash
# Regras puras (boss, finais, reputação), textos e carga de todas as cenas/resources
godot --headless --path . res://tests/test_runner.tscn
# Fluxo completo: nenhum/um/ambos aliados, P1 morre, P2 morre (na fase e no boss)
godot --headless --path . res://tests/flow_test.tscn
```

Atalho útil: abrir `scenes/game/game.tscn` e apertar F6 roda a fase direto, sem passar pelo menu.
