class_name EndingImages
extends Resource
## Imagens dos finais. Chave = id do final (positive, questionable, negative_victorious,
## negative_imprisoned). A morte usa a cena da lápide. Imagem vazia = placeholder.

@export var princess: Dictionary[StringName, Texture2D] = {}
@export var mage: Dictionary[StringName, Texture2D] = {}
## Chaves: positive, negative, double_alliance.
@export var kingdom: Dictionary[StringName, Texture2D] = {}


func get_character_image(character_id: StringName, ending_id: StringName) -> Texture2D:
	var table: Variant = get(character_id)
	if table is Dictionary:
		return (table as Dictionary).get(ending_id) as Texture2D
	return null
