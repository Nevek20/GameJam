# [TODO] Nome do Jogo — esqueleto da Game Jam

Esqueleto em Godot **4.7** (GDScript tipado) de um 2D top-down de ação numa vila de fantasia psicodélica.
A **base já funciona**: dá para jogar do menu aos créditos. O **conteúdo** (história, arte, som,
habilidades especiais, boss) fica para a equipe. Procure por `TODO` no código e `[TODO]` nos textos.

> Abra a pasta no Godot 4.7.x (`project.godot`) e aperte F5. Para testar só a fase: abra
> `scenes/game/game.tscn` e aperte F6.

## O que já funciona

- **Fluxo**: Menu → Introdução (imagens) → Tutorial → Personagem 1 (2 min) → Personagem 2 (2 min) → Conclusão → Créditos, com fade.
- **Menu**: Jogar, Opções (volume Master/Música/Efeitos + remapeamento de teclas + restaurar padrão, salvo em arquivo) e Créditos (texto do JSON).
- **Personagens** (classe `Player`): movimento com diagonal normalizada, aceleração/atrito, dash com invencibilidade,
  defesa/parry, cooldowns, buffer de input. Ataque automático pronto: corte da Princesa e disparo de mana do Mago.
- **Inimigo simples** (soldado): persegue, avisa antes de atacar (telegraph) e ataca.
- **Moradores**: chegar perto abre o diálogo → QTE (barra que esvazia, clique na faixa) → resgatado ou perdido.
- **Exército**: escolha enfrentar (ondas de soldados) ou se aliar (só marca a aliança por enquanto).
- **Morte**: lápide e troca imediata para o Personagem 2, que começa do início do mapa. Inimigos ficam mais fortes para ele (GDD 4.2; multiplicadores em `match_config.tres`, grupo "Morte do Personagem 1").
- **Reputação**: heroísmo por personagem (sobe ao salvar e enfrentar), barra no HUD, aliança.
- **Finais**: tela de conclusão com final do P1, do P2 e do reino (escolhidos por funções puras em `scripts/core/endings.gd`).
- **Juice**: shake, hit stop, flash branco, knockback, squash, partículas, números de dano, rastro do dash, zoom e fade,
  tudo ajustável/desligável em `resources/config/juice_config.tres`.
- **Áudio**: `AudioManager.play_sfx("nome")` já é chamado nos eventos. Sem arquivos de som ainda.
- **Pausa** (Esc).

## O que falta (TODO) — sugestão de divisão

**Narrativa**
- [ ] Todos os textos em `data/*.json` (marcados com `[TODO]`): introdução, tutorial, diálogos dos moradores e do exército, finais, lápides, créditos, nome do jogo.
- [ ] Cada casa pode ter falas próprias: crie `houses.<chave>` em `data/dialogues.json` e coloque a chave no campo `dialogue_key` da casa (cena `scenes/world/level.tscn`).

**Arte** (nada de código: só arrastar arquivos nos campos)
- [ ] Personagens: `resources/characters/*.tres` → `texture` ou `sprite_frames` (animações `idle, move, attack, dash, parry, hurt, dead`).
- [ ] Inimigo: `resources/enemies/soldier.tres` → `skin`.
- [ ] Casas e moradores: campos `house_texture` / `villager_texture` em cada casa da vila.
- [ ] Imagens da introdução: `resources/config/intro_config.tres`. Finais: `resources/config/ending_images.tres`. Lápide: `ui/endings/tombstone_view.tscn`.
- [ ] Cenário (GDD 7): casas, muralhas, fogo, vegetação e bandeiras já têm placeholders na vila (`scenes/world/level.tscn`, nó `World/Invasion`). Muralha, fogo e bandeira: campo `texture` do nó `Visual` em `scenes/world/prop_wall.tscn`, `prop_fire.tscn` e `prop_banner.tscn`.
- [ ] Estética dreamcore / Alice no país das maravilhas: hoje o fundo é um shader roxo provisório (`assets/shaders/psychedelic.gdshader`).

**Áudio**
- [ ] Arrastar os sons para as chaves de `resources/config/audio_library.tres` (já criadas, vazias = silêncio).

**Programação** (cada item tem um `TODO` no arquivo indicado)
- [ ] Habilidades Q, E e R da Princesa (`scripts/abilities/shape_ability.gd`) e do Mago (`scripts/abilities/projectile_ability.gd`). Depois, ligar os `.tres` em `resources/characters/`.
- [ ] Saquear casa depois do resgate e aliado saqueando livremente (`scripts/game/interaction_director.gd`).
- [ ] Aliança: cavaleiros do reino atacando (`scripts/world/army_encounter.gd`, `scripts/game/game.gd`).
- [ ] Inimigo elite: dash, defesa e variação de ataque (`scripts/enemies/enemy.gd`, `enemy_chase.gd`).
- [ ] Guia de mapa: setas na borda da tela (`ui/hud/hud.gd`).
- [ ] Boss e suas regras (`_start_boss()` em `scripts/game/game.gd` explica as 3 situações). Ajudante e personagem-boss controlados por IA.
- [ ] Estado do mundo do P2 dependendo das escolhas do P1.

## Estrutura de pastas

```
assets/      arte e áudio (vazio) + shaders/psychedelic.gdshader
data/        TODOS os textos em JSON
resources/   TODOS os números (.tres): personagens, habilidades, inimigos, partida, juice, reputação, áudio
scenes/      game, world (vila, casas, acampamento), player, enemies, combat, effects
scripts/     autoload/, core/, components/, resources/ (classes dos .tres), abilities/, combat/,
             effects/, player/, enemies/, world/, game/
ui/          menu, options, credits, hud, dialog, qte, intro, tutorial, endings, pause, transition, theme
tests/       testes headless
```

## Como o código está organizado

| Peça | Arquivo | Para que serve |
|---|---|---|
| `GameManager` (autoload) | `scripts/autoload/game_manager.gd` | troca de telas com fade |
| `GameState` (autoload) | `scripts/autoload/game_state.gd` | quem está vivo, casas, escolhas |
| `ReputationState` (autoload) | `scripts/autoload/reputation_state.gd` | heroísmo/aliança; emite sinais |
| `AudioManager` (autoload) | `scripts/autoload/audio_manager.gd` | `play_sfx` / `play_music` |
| `Settings` (autoload) | `scripts/autoload/settings.gd` | volumes e teclas salvos |
| Fase | `scripts/game/game.gd` | cronômetro, troca de personagem, morte |
| Interações | `scripts/game/interaction_director.gd` | diálogos, QTE, escolha do exército |
| Jogador | `scripts/player/player.gd` + `states/` | máquina de estados Idle/Move/Attack/Dash/Parry/Hurt/Dead |
| Inimigo | `scripts/enemies/enemy.gd` + `states/` | Idle/Chase/Attack/Hurt/Dead |
| Habilidades | `scripts/abilities/` | cada habilidade é um Resource (padrão Strategy) |
| Componentes | `scripts/components/` | vida, hitbox, hurtbox, movimento, máquina de estados, visual |
| Pools | `scripts/core/object_pool.gd` | hitboxes, projéteis, partículas, números e inimigos reaproveitados |

### Camadas de colisão

1 world · 2 player · 3 enemy · 4 player_hitbox · 5 enemy_hitbox · 6 npc · 7 projectile · 8 player_hurtbox · 9 enemy_hurtbox
(detalhes em `scripts/core/layers.gd`).

## Testes

```bash
godot --headless --path . res://tests/test_runner.tscn   # regras puras, textos, carga de todas as cenas
godot --headless --path . res://tests/flow_test.tscn     # partidas completas: P1 sobrevive, P1 morre, aliança e P2 morre
```
