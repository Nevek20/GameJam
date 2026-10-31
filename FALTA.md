# O que falta (para cobrar o pessoal)

No jogo, tudo o que ainda não tem arte aparece como uma **caixa cinza escrita "SEM ARTE"**.
Onde colocar cada coisa está no `GUIA_DE_EDICAO.md`.

## Arte

### Personagens e inimigos
- [ ] **Boss**: hoje é uma **Sombra gigante** provisória (contorno avermelhado na versão da horda, dourado na do reino). Se vier arte própria, entra no lugar.
- [ ] **Cavaleiro do reino** (ataca quem se aliou à horda): hoje é um **Coguolho azulado** provisório.
- [x] ~~Elite~~: cortada do jogo.
- [ ] **Moradores**: as 5 casas têm um morador cada (pode ser o mesmo desenho).
- [ ] **Animações que faltam na Princesa e no Mago**: `hurt` (tomando dano) e `dead` (morrendo).
- [ ] **Animações dos monstros** (opcional): hoje cada um tem um loop só. Faltam ataque e morte.

### Cenário
- [ ] **Fogueiras / fogo** da invasão.
- [ ] **Lápide**: aparece quando um personagem morre.

### Telas e interface
- [ ] **Ícone do jogo**.
- [ ] **Ícones das 8 habilidades** no HUD: Princesa (ataque, Q, E, R) e Mago (ataque, Q, E, R).
- [ ] **Imagens dos finais** (11 no total):
  - Princesa: positivo, questionável, vitoriosa (aliada), presa (aliada e derrotada).
  - Mago: as mesmas 4.
  - Reino: positivo, negativo, aliança dupla.
- [ ] **Imagens da introdução**: hoje as 3 legendas usam o mesmo "Cenário guerreira".
- [ ] **Cutscene da troca Princesa → Mago**: hoje usa o "cenário kael" duas vezes.
- [ ] **Cutscene antes do boss**: sem imagem nenhuma.
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

Já entraram os textos da lore do Cleson (branch `jogo-completo`): Valedouro, Elara, Kael Draven, a Horda,
introdução, troca de personagem, cutscene do boss, falas do capitão e pergunta de objetivos.

Ainda são **provisórios, escritos por mim**:

- [ ] `data/endings.json`
  - [ ] Textos dos 11 finais.
  - [ ] Texto da lápide.
- [ ] `data/dialogues.json`: falas dos moradores que o Cleson não mexeu (só `default`, `baker` e `elder` foram revisadas).
- [ ] `data/tutorial.json`: tutorial (só uma linha foi revisada).
- [ ] `data/ui.json`: subtítulo do menu ("Uma noite. Dois heróis. Uma escolha.") e textos da interface.
