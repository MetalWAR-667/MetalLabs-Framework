class_name CardData
extends Resource

@export var illustration: Texture2D
@export_multiline var description: String

@export_group("Resolution")
@export var objective_text: String
@export var damage: int

@export_group("Options")
@export var option_labels: Array[String]
