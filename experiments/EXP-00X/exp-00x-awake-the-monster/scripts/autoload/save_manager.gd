extends Node

const SAVE_PATH := "user://exp_00x_save.json"
const REQUIRED_FIELDS: Dictionary = {
	"card_path": TYPE_STRING,
	"player_health": TYPE_INT,
	"player_sanity": TYPE_INT,
	"selected_item_path": TYPE_STRING,
	"item_remaining_uses": TYPE_INT,
	"sacrificed_initial_item": TYPE_BOOL,
	"ally_present": TYPE_BOOL,
	"ally_health": TYPE_INT,
	"threat_active": TYPE_BOOL,
	"remaining_threat": TYPE_INT,
	"selected_option_index": TYPE_INT,
	"ally_participates": TYPE_BOOL,
	"bonus_applied": TYPE_BOOL,
}
const INTEGER_FIELDS: Array[String] = [
	"player_health",
	"player_sanity",
	"item_remaining_uses",
	"ally_health",
	"remaining_threat",
	"selected_option_index",
]


func save_game(state: Dictionary) -> bool:
	if not _is_valid_state(state):
		push_warning("SaveManager refused to save an incomplete game state.")
		return false

	var save_file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_warning("SaveManager could not open the local save file for writing.")
		return false

	save_file.store_string(JSON.stringify(state))
	return true


func load_game() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}

	var save_file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_warning("SaveManager could not open the local save file. Starting a clean game.")
		return {}

	var parsed: Variant = JSON.parse_string(save_file.get_as_text())
	if parsed is not Dictionary or not _is_valid_state(parsed):
		push_warning("SaveManager found a corrupt or incomplete save. Starting a clean game.")
		return {}

	var normalized_state := parsed as Dictionary
	for field: String in INTEGER_FIELDS:
		normalized_state[field] = int(normalized_state[field])
	return normalized_state


func has_valid_save() -> bool:
	return not load_game().is_empty()


func clear_save() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return

	var error := DirAccess.remove_absolute(ProjectSettings.globalize_path(SAVE_PATH))
	if error != OK:
		push_warning("SaveManager could not remove the previous local save.")


func _is_valid_state(state: Dictionary) -> bool:
	for field: String in REQUIRED_FIELDS:
		if not state.has(field):
			return false
		var value_type := typeof(state[field])
		var expected_type: int = REQUIRED_FIELDS[field]
		if value_type != expected_type:
			if expected_type != TYPE_INT or value_type != TYPE_FLOAT:
				return false

	if state.card_path.is_empty() or not ResourceLoader.exists(state.card_path):
		return false
	if state.item_remaining_uses < 0 or state.remaining_threat < 0:
		return false
	if not state.selected_item_path.is_empty() and not ResourceLoader.exists(
		state.selected_item_path
	):
		return false
	if state.selected_item_path.is_empty() != (state.item_remaining_uses == 0):
		return false
	if state.threat_active:
		if state.remaining_threat <= 0 or state.selected_option_index < 0:
			return false

	return true
