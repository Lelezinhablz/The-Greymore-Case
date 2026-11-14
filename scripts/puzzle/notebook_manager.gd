# NotebookManager.gd  (AUTOLOAD)
# Guarda pistas coletadas e o estado dos puzzles.
extends Node

signal clue_added(id: String)
signal puzzle_solved(puzzle_id: String)

# Banco de pistas: id -> título/texto. Para criar pista nova, adicione aqui.
const CLUES := {
	"mordomo_porta": {
		"title": "Mordomo na porta dos fundos",
		"text": "O mordomo saiu pela porta dos fundos às 22h.",
	},
	"carro_preto": {
		"title": "Carro preto",
		"text": "Um carro preto ficou parado na rua a noite toda.",
	},
}

var ui_open := false                # true enquanto quadro/tabuleta estiver aberto (bloqueia o inventário)
var collected: Array[String] = []   # ids, na ordem em que foram coletados
var _state: Dictionary = {}         # puzzle_id -> { chave: valor }
var _solved: Dictionary = {}        # puzzle_id -> true

func collect_clue(id: String) -> bool:
	if not CLUES.has(id):
		push_warning("Pista desconhecida: " + id)
		return false
	if collected.has(id):
		return false
	collected.append(id)
	print("[Notebook] pista coletada: ", id)
	clue_added.emit(id)
	return true

func has_clue(id: String) -> bool:
	return collected.has(id)

func get_clue(id: String) -> Dictionary:
	return CLUES.get(id, {})

# --- estado genérico dos puzzles (para reabrir a UI e continuar de onde parou)
func get_state(puzzle_id: String, key: String, default: Variant = null) -> Variant:
	return _state.get(puzzle_id, {}).get(key, default)

func set_state(puzzle_id: String, key: String, value: Variant) -> void:
	if not _state.has(puzzle_id):
		_state[puzzle_id] = {}
	_state[puzzle_id][key] = value

func mark_solved(puzzle_id: String) -> void:
	_solved[puzzle_id] = true
	puzzle_solved.emit(puzzle_id)

func is_solved(puzzle_id: String) -> bool:
	return _solved.get(puzzle_id, false)

# ---------- ATALHOS DE TESTE (só em debug) - remova depois ----------
# F1 = coleta "mordomo_porta" | F2 = coleta "carro_preto"
func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F1:
			collect_clue("mordomo_porta")
		elif event.keycode == KEY_F2:
			collect_clue("carro_preto")
