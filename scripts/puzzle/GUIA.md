# Guia: pistas + quadro + puzzle das três faces

## 1. Arquivos
Coloque tudo em `res://scripts/puzzle/`:
`notebook_manager.gd`, `clue_toast.gd`, `drag_card.gd`, `clue_slot.gd`, `puzzle_board_ui.gd`,
`puzzle_interactable.gd`, `head_slot.gd`, `keyhole.gd`, `three_faces_ui.gd`.

**Autoloads** (Project Settings > Globals):
- `NotebookManager` → notebook_manager.gd
- `ClueToast` → clue_toast.gd (opcional, aviso "Nova pista")

Salve, feche e reabra o projeto para o Godot registrar os `class_name`.

---

## 2. Pegando a pista no diálogo

### 2.1 No arquivo `.dialogue`
```
~ ligacao_contato
Contato: Escuta, eu vi tudo naquela noite.
Contato: [color=gold][url=mordomo_porta]O mordomo saiu pela porta dos fundos às 22h[/url][/color], com pressa.
Contato: E tinha [color=gold][url=carro_preto]um carro preto parado na rua[/url][/color] a noite toda.
=> END
```
O valor de `url=` é o **id** da pista (precisa existir em `NotebookManager.CLUES`).
`carro_preto` é uma pista "isca": o jogador pega, mas não serve no quadro.

### 2.2 No seu balão (a cópia do example_balloon.gd)
```gdscript
var _prev_mouse_mode: Input.MouseMode = Input.mouse_mode

func _ready() -> void:
	# ... (resto do seu _ready)
	dialogue_label.meta_clicked.connect(_on_clue_clicked)

func start(with_dialogue_resource = null, cue := "", extra_game_states := []) -> void:
	_prev_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE      # mouse visível p/ clicar na pista
	# ... (resto do start)

func _exit_tree() -> void:
	Input.mouse_mode = _prev_mouse_mode

func _on_clue_clicked(meta: Variant) -> void:
	get_viewport().set_input_as_handled()            # o clique não avança o diálogo
	NotebookManager.collect_clue(str(meta))
```
Dica: no `DialogueLabel` marque `meta_underlined = true` se quiser sublinhado.
Se mesmo assim o clique avançar o diálogo, crie `var _clicked_clue := false`, ponha `true` no
`_on_clue_clicked` e, no começo do `_on_balloon_gui_input`, faça `if _clicked_clue: _clicked_clue = false; return`.

Para o **telefone**: qualquer `RichTextLabel` com BBCode serve. Use o mesmo
`label.meta_clicked.connect(...)` chamando `NotebookManager.collect_clue(str(meta))`.

---

## 3. Cena do quadro: `puzzle_board.tscn`

```
PuzzleBoardUI (CanvasLayer)        script: puzzle_board_ui.gd | Layer = 20 | Process Mode = Always
└─ Root (Control)                  Layout: Full Rect
   ├─ Dim (ColorRect)              Full Rect | Color #000000B0 | Mouse Filter = Stop
   ├─ Margin (MarginContainer)     Full Rect | theme_override margins = 32 nos 4 lados
   │  └─ HBox (HBoxContainer)      separation = 24
   │     ├─ Board (Panel)          Size Flags Horizontal = Fill + Expand | Stretch Ratio = 2
   │     │  ├─ Title (Label)       Position (16, 12) | "Caso 01 - A noite do crime"
   │     │  ├─ Pin1 (Label)        Position (40, 90)  | "FOTO\nPorta dos fundos entreaberta"
   │     │  ├─ Pin2 (Label)        Position (300, 70) | "BILHETE\n\"Saí às 22h\""
   │     │  ├─ Strings (Line2D)    (opcional) linhas ligando Pin1, Pin2 e os encaixes
   │     │  └─ Slots (Control)     Full Rect | Mouse Filter = Ignore | Access as Unique Name (%Slots)
   │     │     ├─ SlotQuem  (PanelContainer)  script: clue_slot.gd
   │     │     └─ SlotProva (PanelContainer)  script: clue_slot.gd
   │     └─ Side (PanelContainer)  Stretch Ratio = 1
   │        └─ Tabs (TabContainer)
   │           ├─ Notas (ScrollContainer)   Horizontal Scroll Mode = Disabled
   │           │  └─ NotesList (VBoxContainer)  Size Flags H = Fill+Expand | %NotesList
   │           └─ Itens (ScrollContainer)   Horizontal Scroll Mode = Disabled
   │              └─ ItemsList (VBoxContainer)  Size Flags H = Fill+Expand | %ItemsList
   ├─ Message (Label)              Layout: Bottom Wide | Horizontal Alignment = Center | %Message
   └─ CloseButton (Button)         Layout: Top Right | text "Fechar" | %CloseButton
```
- "Access as Unique Name" = botão direito no nó > *Access as Unique Name* (aparece um `%`).
  Os scripts usam `%Slots`, `%NotesList`, `%ItemsList`, `%Message`, `%CloseButton`.
- Os nomes das abas vêm dos nomes dos nós (`Notas`, `Itens`).
- Ordem importa: `Dim` primeiro (fundo); `Message` e `CloseButton` por último (por cima).
- `Pin1/Pin2` são só visuais (pistas já "fixadas"). Troque por `TextureRect` com fotos depois.
- Posições dos slots em pixels, relativas ao `Board`. Para ficar responsivo, use âncoras.

### Configurando os encaixes (Inspector de cada ClueSlot)
| Nó | slot_name | expected_kind | expected_id | empty_text |
|---|---|---|---|---|
| SlotQuem | `quem` | `clue` | `mordomo_porta` | `Quem saiu?` |
| SlotProva | `prova` | `item` | `Foto Rasgada` | `Prova?` |

- `expected_id` de **clue** = id em `NotebookManager.CLUES`.
- `expected_id` de **item** = `name` do `ItemResource` (crie `foto_rasgada.tres` com name "Foto Rasgada").
- No nó raiz `PuzzleBoardUI`: `puzzle_id = "caso_01"` e `reward_item` = o item que o quadro entrega (ex.: `chave_porao.tres`).
- Quer só um encaixe? Apague o outro. O puzzle resolve quando **todos** os `ClueSlot` estiverem preenchidos.

### Colocando o quadro no mundo
1. Cena nova: `Area3D` (com `CollisionShape3D`) + `MeshInstance3D` do quadro.
2. Anexe `puzzle_interactable.gd` ao `Area3D` (ele estende `Interactable`).
3. Inspector: `prompt_text = "Examinar quadro"` e `ui_scene = puzzle_board.tscn`.
4. Camada/máscara de colisão iguais às dos seus outros `Interactable`
   (o `InteractionManager` detecta por `area_entered`).

---

## 4. Exemplo completo, passo a passo
1. **Ligação:** no telefone/diálogo, o jogador clica na frase dourada
   "O mordomo saiu pela porta dos fundos às 22h".
2. `meta_clicked` → `NotebookManager.collect_clue("mordomo_porta")` → emite `clue_added`
   → o `ClueToast` mostra "Nova pista: Mordomo na porta dos fundos".
3. O jogador vai ao quadro e aperta o botão de interação → menu "Examinar".
4. `PuzzleInteractable` instancia a `PuzzleBoardUI`: pausa o jogo, libera o mouse e
   preenche a aba **Notas** com cartas (`DragCard`) das pistas coletadas, e **Itens** com o inventário.
5. O jogador **arrasta** a carta "Mordomo na porta dos fundos" até o `SlotQuem`.
   - Carta errada (ex.: "Carro preto") → o encaixe pisca vermelho e aparece "Isso não parece se encaixar aqui."
   - Carta certa → pisca verde, o encaixe mostra a pista e o estado é salvo no `NotebookManager`.
6. O jogador arrasta o item "Foto Rasgada" (aba Itens) até o `SlotProva`.
7. Todos os encaixes preenchidos → `mark_solved("caso_01")`, o `reward_item` entra no inventário
   e a mensagem de vitória aparece. O jogador fecha no botão **Fechar** → despausa → volta ao jogo.
8. Se reabrir o quadro, os encaixes continuam preenchidos (estado vem do `NotebookManager`).

---

## 5. Puzzle das três faces (independente do quadro): `three_faces.tscn`

```
ThreeFacesUI (CanvasLayer)         script: three_faces_ui.gd | Layer = 20 | Process Mode = Always
│                                  Inspector: reward_item = item chave final
└─ Root (Control)                  Full Rect
   ├─ Dim (ColorRect)              Full Rect | #000000B0 | Mouse Filter = Stop
   ├─ Tablet (Panel)               Layout: Center | Custom Min Size (760, 260)  (ou TextureRect da tabuleta)
   │  ├─ Slots (Control)           Full Rect | Mouse Filter = Ignore | %Slots
   │  │  ├─ OuterLeft  (PanelContainer)  script head_slot.gd | slot_name=outer_left  | head_id=sadica | Position (30, 60)
   │  │  ├─ OuterRight (PanelContainer)  script head_slot.gd | slot_name=outer_right | head_id=triste | Position (590, 60)
   │  │  ├─ MidLeft    (PanelContainer)  script head_slot.gd | slot_name=mid_left    | head_id=""     | Position (230, 60) | Visible = OFF
   │  │  └─ MidRight   (PanelContainer)  script head_slot.gd | slot_name=mid_right   | head_id=""     | Position (390, 60) | Visible = OFF
   │  └─ Keyhole (PanelContainer)  script keyhole.gd | Position (280, 30) | %Keyhole
   │                               required_item = "Chave Dedo"   (fica DEPOIS de Slots = desenha por cima)
   ├─ ItemsPanel (PanelContainer)  Layout: Bottom Wide
   │  └─ Scroll (ScrollContainer)  Vertical Scroll Mode = Disabled
   │     └─ ItemsList (HBoxContainer)  %ItemsList
   ├─ Message (Label)              Layout: Top Wide | Alignment Center | %Message
   └─ CloseButton (Button)         Layout: Top Right | "Fechar" | %CloseButton
```
- Nos 4 `HeadSlot` / no `Keyhole`, o campo `head_textures` (Dictionary) recebe
  `"sadica" -> textura` e `"triste" -> textura`; `face_texture` no Keyhole. Sem textura, ele mostra texto placeholder.
- Os sprites **não são espelhados**: a sádica precisa já olhar para a esquerda e a triste para baixo, com o colar de cobra.
- **Item da chave:** `ItemResource` com `name = "Chave Dedo"`, `type = KEY`, e na `description`
  a nota colada: `Uma nota presa nela diz: "envergonhe o pecador".` (aparece no cartão arrastável).
  Se quiser a nota também no bloco de notas, adicione uma pista em `CLUES` e chame
  `NotebookManager.collect_clue("envergonhe")` ao pegar a chave.
- **Colocar no mundo:** `Area3D` com `puzzle_interactable.gd`, `ui_scene = three_faces.tscn`,
  `prompt_text = "Examinar tabuleta"`.

### Fluxo
1. Abre a tabuleta: cabeças presas (`locked`).
2. Arrasta o cartão "Chave Dedo" até a cabeça central → `Keyhole.unlocked` → ela some e aparecem
   os encaixes `MidLeft`/`MidRight`; as cabeças liberam para arrastar.
3. Arrastar cabeça para encaixe vazio = mover; para encaixe ocupado = trocar.
4. Resolve quando `mid_left = triste` e `mid_right = sadica` (a sádica à direita olha para a triste).
   → `reward_item` vai para o inventário e as cabeças travam.
5. Chave errada → "Não serve nessa fechadura."

---

## 6. Armadilhas
- **ESC fecha o jogo**: o `PlayerStats._input` chama `get_tree().quit()` no ESC. Por isso as UIs fecham só pelo botão.
  (Se mudar isso, dá para fechar com `ui_cancel` num `_unhandled_input`.)
- Tecla do **inventário** com a UI aberta: o `inventory_screen` também alterna `paused`. Ignore a tecla
  enquanto uma UI de puzzle estiver aberta (ex.: flag `NotebookManager.ui_open`).
- **Pausa**: as UIs usam `process_mode = Always`, senão o arrastar não funciona com o jogo pausado.
- Arrastar e soltar nativo do Godot só funciona com **mouse/toque**. Para gamepad, faça uma seleção por botões.
- Nomes precisam bater: `expected_id`/`required_item` = `ItemResource.name` (maiúsculas e acentos incluídos).
- Para pista nova: adicione em `CLUES`, escreva `[url=novo_id]` no diálogo, e use `novo_id` em um `ClueSlot`.

---

## 7. Diagnóstico rápido (se algo não funcionar)

**Pista não é coletada / toast não aparece**
1. Abra o Output ao clicar na frase dourada. Deve aparecer `[Notebook] pista coletada: <id>`.
   - Nada aparece: o clique não chega. Confira:
     - o projeto usa **a sua cópia** do balão (Project Settings > Dialogue Manager > Runtime > Balloon Path),
       e não `addons/dialogue_manager/example_balloon`;
     - a linha `dialogue_label.meta_clicked.connect(_on_clue_clicked)` está no `_ready` dessa cópia;
     - o mouse está visível enquanto o balão aparece (`start()` seta `MOUSE_MODE_VISIBLE`);
     - coloque `print("clique: ", meta)` no `_on_clue_clicked` para ver se o sinal dispara.
   - Aparece "Pista desconhecida": o id do `[url=...]` não existe em `NotebookManager.CLUES`.
2. Print aparece mas sem aviso na tela: o autoload `ClueToast` não está registrado
   (Project Settings > Globals) ou não se chama exatamente `ClueToast`.

**Quadro não funciona**
1. Abra o quadro e olhe **Debugger > Erros**. Mensagens `PuzzleBoardUI: faltam nós...` indicam nó sem
   *Access as Unique Name* (`%`). A UI agora se fecha sozinha e **não pausa o jogo** nesse caso.
2. `PuzzleInteractable sem ui_scene` → arraste `puzzle_board.tscn` para o campo `ui_scene`.
3. Nenhum prompt `[E]` aparece ao chegar perto → colisão: layer/mask do `Area3D` do quadro
   precisam casar com a máscara da `Area3D` do `InteractionManager` (igual aos seus outros Interactables),
   e o player precisa estar olhando para ele (`facing_threshold`).
4. Com o quadro aberto, **E** fecha (atalho de segurança) além do botão Fechar.

---

## 8. Testes isolados (descubra qual peça falha)

**A) O toast funciona?** Rode o jogo e aperte **F1**. Esperado: no Output `[Notebook] pista coletada: mordomo_porta`
e o aviso no topo da tela. Se o print aparece mas o aviso não: o autoload `ClueToast` não está registrado
(ou não se chama exatamente `ClueToast`). Se nem o print aparece: o `notebook_manager.gd` novo não está em uso
ou o autoload `NotebookManager` não está registrado.

**B) O link do diálogo é detectado?** No `_ready` da sua cópia do balão adicione:
```gdscript
dialogue_label.meta_hover_started.connect(func(meta): print("hover na pista: ", meta))
dialogue_label.meta_clicked.connect(func(meta): print("clique na pista: ", meta))
```
- Passa o mouse na frase dourada e **não** aparece `hover na pista`: o `[url=...]` não chegou ao texto
  (confira a sintaxe no `.dialogue`) ou o mouse está capturado/invisível.
- Aparece `hover` mas não `clique`: algo está consumindo o clique; me avise.
- Aparecem os dois mas não `[Notebook] pista coletada`: falta a conexão para `_on_clue_clicked`
  ou o id não existe em `CLUES` (aparece um warning `Pista desconhecida`).

**C) O quadro abre?** Interaja e olhe o Output:
- Não aparece `[Puzzle] get_actions em ...`: o nó do quadro **não está com o `puzzle_interactable.gd`**.
- Aparece `ui_scene = <null>`: arraste a cena do quadro para o campo `ui_scene`.
- Aparece `perform_action: Sair`: o menu selecionou "Sair". O menu tem 2 opções (Examinar/Sair);
  navegue até "Examinar" antes de confirmar.

---

## 9. Clique "bugado" nas pistas (linha avança ao errar o clique)

**Causa:** o `_on_balloon_gui_input` do balão avança o diálogo em qualquer clique do mouse. Errar o link por
poucos pixels (ou o clique chegar ao balão antes do label) passa a linha e você perde a pista.

**Correção** na sua cópia do balão: linhas com pista **ignoram o mouse** para avançar/pular a digitação
(o teclado continua avançando). O mouse só serve para clicar na pista.

1. No **início** de `_on_balloon_gui_input`, antes de qualquer outra coisa:
```gdscript
func _on_balloon_gui_input(event: InputEvent) -> void:
	# Linha com pista: o mouse não avança nem pula a digitação, só clica na pista.
	if event is InputEventMouseButton and is_instance_valid(dialogue_line) \
			and "[url=" in dialogue_line.text:
		return

	# ... (resto original da função)
```
2. No `_ready` (deixa a pista mais visível; opcional):
```gdscript
dialogue_label.meta_underlined = true
```
3. No `.dialogue`, destaque mais a pista (opcional):
```
Contato: [b][color=gold][url=mordomo_porta]O mordomo saiu pela porta dos fundos às 22h[/url][/color][/b]
```
4. Avise o jogador que a linha avança com a tecla (ex.: um ícone/texto "[Enter] continuar"), já que o clique
   do mouse não avança mais nas linhas com pista.

Obs.: com isso, na linha da pista o jogador pode clicar na frase quantas vezes quiser, e a linha só passa
quando ele apertar a tecla de avançar. `collect_clue` ignora cliques repetidos (pista já coletada).
