class_name ItemData
extends Resource

@export var display_name: String
@export var illustration: Texture2D
@export var hud_icon: Texture2D
@export_multiline var description: String

@export_group("Automatic successes")
@export var bonus_symbol: CardOptionData.StatType = CardOptionData.StatType.NONE
@export_range(0, 10) var automatic_successes := 0
@export_range(1, 10) var uses := 1


func get_success_bonus(required_stat: CardOptionData.StatType) -> int:
	if bonus_symbol != required_stat:
		return 0
	return automatic_successes
