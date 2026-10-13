class_name Layers
extends RefCounted
## Camadas de física (valores de bit). Manter em sincronia com [layer_names] do project.godot.
##  1 world          cenário: paredes, casas, props
##  2 player         corpos do lado dos heróis (jogador e ajudante)
##  3 enemy          corpos do lado inimigo (exército, cavaleiros, boss)
##  4 player_hitbox  ataques do lado dos heróis
##  5 enemy_hitbox   ataques do lado inimigo
##  6 npc            zonas de interação (casas, acampamento)
##  7 projectile     projéteis (somam-se à camada de hitbox do time)
##  8 player_hurtbox áreas que recebem dano dos heróis
##  9 enemy_hurtbox  áreas que recebem dano dos inimigos

const WORLD := 1 << 0
const PLAYER := 1 << 1
const ENEMY := 1 << 2
const PLAYER_HITBOX := 1 << 3
const ENEMY_HITBOX := 1 << 4
const NPC := 1 << 5
const PROJECTILE := 1 << 6
const PLAYER_HURTBOX := 1 << 7
const ENEMY_HURTBOX := 1 << 8
