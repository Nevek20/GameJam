# O que falta (para cobrar o pessoal)

No jogo não aparece nada de "sprite faltando": o que não tem arte foi escondido, cortado ou ganhou uma solução provisória.
Onde colocar cada coisa está no `GUIA_DE_EDICAO.md`.

## Arte

### Personagens e inimigos
- [ ] **Boss**: hoje é uma **Sombra gigante** provisória (contorno avermelhado na versão da horda, dourado na do reino). Se vier arte própria, entra no lugar.
- [ ] **Cavaleiro do reino** (ataca quem se aliou à horda): hoje é um **Coguolho azulado** provisório.
- [x] ~~Elite~~: cortada do jogo.
- [x] ~~Moradores~~: ficam dentro de casa (não aparecem). Se um dia tiver arte, vai em `villager_texture`.
- [ ] **Animações que faltam na Princesa e no Mago**: `hurt` (tomando dano) e `dead` (morrendo).
- [ ] **Animações dos monstros** (opcional): hoje cada um tem um loop só. Faltam ataque e morte.

### Cenário
- [ ] **Fogo** da invasão (opcional): hoje é uma chama de partículas feita por código.
- [ ] **Lápide** (opcional): hoje usa a pedra grande do cenário.

### Telas e interface
- [ ] **Ícone do jogo**.
- [ ] **Ícones das 8 habilidades** no HUD: Princesa (ataque, Q, E, R) e Mago (ataque, Q, E, R).
- [ ] **Imagens dos finais** (11 no total):
  - Princesa: positivo, questionável, vitoriosa (aliada), presa (aliada e derrotada).
  - Mago: as mesmas 4.
  - Reino: positivo, negativo, aliança dupla.
- [ ] **Imagens da introdução da Elara** (6 telas): hoje todas usam o "Cenário guerreira".
- [ ] **Imagens da introdução do Kael** (6 telas, troca de personagem): hoje todas usam o "cenário kael".
- [ ] **Cutscene antes do boss** (2 telas): hoje usa o "cenário kael".
- [ ] **Efeitos** (opcional): projéteis do Mago, raio e nuvem do Coguolho. Hoje são desenhados por código.

### Já recebido
- [x] Casas, igreja, fonte, árvores, pedras, barril, poção e muro em PNG com fundo transparente.

## Sons

### Gerais
- [ ] `hit`: golpe acertando.
- [ ] `hurt`: jogador tomando dano.
- [ ] `block`: golpe defendido.
- [ ] `death`: morte.
- [ ] `downed` / `revive`: cair e ser revivido na luta final.

### Mago
- [ ] `attack_mana`: ataque automático do Mago.

### Inimigos e boss
- [ ] `enemy_attack`: ataque dos inimigos sem som próprio (elite, cavaleiro, Coguolho).
- [ ] `dash`: dash da elite.
- [ ] `boss_start`, `boss_roar`, `boss_defeated`.
- [ ] `boss_radial`, `boss_shockwave`, `boss_slam`.

### Vila e QTE
- [ ] `rescue` / `loot`: resgatar / saquear.
- [ ] `qte_success` / `qte_fail`.
- [ ] `barrel_hit` / `barrel_break` / `potion_pickup`.
- [ ] `fight_start` / `fight_end`.

### Interface
- [ ] `ui_click` / `ui_focus`.

### Músicas
- [ ] `intro`.
- [ ] `gameplay` (vila).
- [ ] `boss`.
- [ ] `ending` (finais).
- [ ] O menu e os créditos já têm música ("Play it again Sam").

## Textos (escrita)

A história do jogo agora é a do pessoal (Elara Veyne e Kael Draven):
- introdução da Elara, "Ajudar?" e o que acontece depois (Y/N);
- introdução do Kael (troca de personagem), "Tudo ou nada?" e o que acontece depois (Y/N);
- finais da Guerreira e do Mercenário (Y = finais de herói, N = finais de quem deu as costas / fugiu).

Ainda são **provisórios, escritos por mim** (a história não cobre):

- [ ] `data/endings.json`
  - [ ] Finais do reino (positivo, negativo, aliança dupla).
  - [ ] Texto da lápide (morte de cada personagem).
- [ ] `data/intro.json` → `boss`: legenda da cutscene antes do boss.
- [ ] `data/dialogues.json`: falas dos moradores (`weaver` e `twins` nunca foram revisadas).
- [ ] `data/tutorial.json`: tutorial.
- [ ] `data/ui.json`: subtítulo do menu ("Uma noite. Dois heróis. Uma escolha.") e textos da interface.
