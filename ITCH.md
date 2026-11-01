# Publicar no itch.io

Os pacotes prontos saem da pasta `build/` (ela não vai para o Git):

| Arquivo | O que é |
|---|---|
| `OsContosDeCarcosa_web.zip` | Versão para jogar no navegador (é o principal) |
| `OsContosDeCarcosa_windows.zip` | Versão para baixar (Windows, um `.exe` só) |

## Passo a passo

1. Em itch.io → **Upload new project**.
2. **Title:** Os Contos de Carcosa.
3. **Kind of project:** **HTML**.
4. **Uploads:**
   - Envie `OsContosDeCarcosa_web.zip` e marque **"This file will be played in the browser"**.
   - Envie `OsContosDeCarcosa_windows.zip` e marque **Windows** (opcional, para quem quer baixar).
5. **Embed options:**
   - **Viewport dimensions:** `1280` × `720`.
   - Marque **Fullscreen button**.
   - **SharedArrayBuffer support:** pode deixar desmarcado (o jogo foi exportado sem threads; funciona sem isso).
   - Mobile friendly: desmarcado (precisa de mouse e teclado).
6. **Classification:** Games → **Genre:** Action. Tags sugeridas: `top-down`, `action`, `story-rich`, `game-jam`, `godot`.
7. Salve como **Draft**, abra a página e teste uma partida. Depois mude para **Public**.

## Texto de controles (para colar na página)

- **WASD** — andar
- **Mouse** — mirar
- **Clique esquerdo** — atacar
- **Clique direito** — defender (aperte na hora certa para dar parry)
- **Espaço** — dash
- **Q / E / R** — habilidades
- **F** — chamar o morador / saquear / reviver o parceiro
- **Tab** — avançar de etapa (depois dos objetivos)
- **Esc** — pausa (dá para trocar as teclas em Opções)

## Gerar os pacotes de novo (depois de mudar algo no jogo)

No Godot (precisa dos *export templates* da versão 4.7.2: *Editor → Manage Export Templates → Download and Install*):

1. *Project → Export…*: os presets **Web** e **Windows** já estão configurados (`export_presets.cfg`).
2. Escolha **Web** → *Export Project…* → `build/web/index.html` (desmarque *Export With Debug*).
3. Escolha **Windows** → *Export Project…* → `build/windows/OsContosDeCarcosa.exe`.
4. Compacte o **conteúdo** de `build/web` (o `index.html` precisa ficar na raiz do zip) e o de `build/windows`.

Pelo terminal:
```bash
godot --headless --path . --export-release "Web" build/web/index.html
godot --headless --path . --export-release "Windows" build/windows/OsContosDeCarcosa.exe
cd build/web && zip -r ../OsContosDeCarcosa_web.zip . && cd ../windows && zip -r ../OsContosDeCarcosa_windows.zip .
```

> A pasta `build/` tem um arquivo `.gdignore`: assim o Godot não importa os arquivos exportados de volta para o projeto.
