class_name CardOptionData
extends Resource

enum StatType {
	NONE,
	ATTENTION,
	SANITY,
	STRENGTH,
}

@export_multiline var text: String

@export_group("Test")
@export var required_stat: StatType = StatType.NONE
@export_range(1, 10) var required_successes := 1
@export var damage := 0

@export_group("Condition")
@export var requires_sacrificed_item := false
