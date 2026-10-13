class_name Texts
extends RefCounted
## Acesso aos textos em data/*.json. Nada de texto fica dentro dos scripts:
## o código só conhece as chaves. Cache estático para ler cada arquivo uma única vez.

const DATA_DIR := "res://data/"

static var _cache: Dictionary = {}


## Lê um valor por caminho com pontos, ex.: Texts.get_value("dialogues", "house.ask").
static func get_value(file: String, path: String, fallback: Variant = null) -> Variant:
	var node: Variant = _load(file)
	if path.is_empty():
		return node
	for part: String in path.split("."):
		if node is Dictionary and (node as Dictionary).has(part):
			node = (node as Dictionary)[part]
		elif node is Array and part.is_valid_int() and int(part) < (node as Array).size():
			node = (node as Array)[int(part)]
		else:
			return fallback
	return node


## Texto simples com substituição opcional de {chaves}.
static func text(file: String, path: String, params: Dictionary = {}) -> String:
	var value: Variant = get_value(file, path, null)
	if value == null:
		return "[%s:%s]" % [file, path]
	var result: String
	if value is Array:
		result = "\n".join(PackedStringArray(value as Array))
	else:
		result = str(value)
	if not params.is_empty():
		result = result.format(params)
	return result


static func array(file: String, path: String) -> Array:
	var value: Variant = get_value(file, path, [])
	return value as Array if value is Array else []


static func character_name(id: StringName) -> String:
	return text("names", String(id))


static func ui(path: String, params: Dictionary = {}) -> String:
	return text("ui", path, params)


## Limpa o cache (útil se a equipe editar JSON com o jogo aberto no editor).
static func reload() -> void:
	_cache.clear()


static func _load(file: String) -> Variant:
	if _cache.has(file):
		return _cache[file]
	var path := DATA_DIR + file + ".json"
	var data: Variant = {}
	if FileAccess.file_exists(path):
		var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
		if parsed != null:
			data = parsed
		else:
			push_error("Texts: JSON inválido em %s" % path)
	else:
		push_error("Texts: arquivo não encontrado %s" % path)
	_cache[file] = data
	return data
