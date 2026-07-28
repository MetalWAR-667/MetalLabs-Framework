class_name CardData
extends Resource

@export var illustration: Texture2D
@export_multiline var description: String

@export_group("Options")
@export var options: Array[CardOptionData]
