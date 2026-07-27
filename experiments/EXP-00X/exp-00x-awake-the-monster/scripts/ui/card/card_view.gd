extends Control

signal option_selected(index: int)

@export_group("Option indicators")
@export var option_indicator_normal: Texture2D
@export var option_indicator_hover: Texture2D
@export var option_indicator_pressed: Texture2D

@export_group("Preview data")
@export_multiline var preview_description: String
@export var preview_objective: String
@export var preview_damage: String
@export var preview_options: PackedStringArray

@onready var illustration: TextureRect = %Illustration
@onready var illustration_placeholder: ColorRect = %IllustrationPlaceholder
@onready var narrative_text: RichTextLabel = %NarrativeText
@onready var objective_icon: TextureRect = %ObjectiveIcon
@onready var objective_text: Label = %ObjectiveText
@onready var damage_icon: TextureRect = %DamageIcon
@onready var damage_text: Label = %DamageText

@onready var _option_buttons: Array[Button] = [
	%OptionButton01,
	%OptionButton02,
	%OptionButton03,
]

@onready var _option_indicators: Array[TextureRect] = [
	%OptionIndicator01,
	%OptionIndicator02,
	%OptionIndicator03,
]

@onready var _option_labels: Array[Label] = [
	%OptionText01,
	%OptionText02,
	%OptionText03,
]


func _ready() -> void:
	_connect_option_signals()
	_apply_preview_data()


func set_description(value: String) -> void:
	narrative_text.text = value


func set_illustration(value: Texture2D) -> void:
	illustration.texture = value
	illustration.visible = value != null
	illustration_placeholder.visible = value == null


func set_objective(value: String, icon: Texture2D = null) -> void:
	objective_text.text = value
	if icon != null:
		objective_icon.texture = icon


func set_damage(value: String, icon: Texture2D = null) -> void:
	damage_text.text = value
	if icon != null:
		damage_icon.texture = icon


func set_options(values: PackedStringArray) -> void:
	for index in range(_option_buttons.size()):
		var has_option := index < values.size() and not values[index].is_empty()
		_option_buttons[index].visible = has_option
		_option_buttons[index].disabled = not has_option
		_option_labels[index].text = values[index] if has_option else ""
		_set_option_indicator(index, option_indicator_normal)


func set_option_enabled(index: int, enabled: bool) -> void:
	if not _is_valid_option_index(index):
		return

	_option_buttons[index].disabled = not enabled
	_set_option_indicator(index, option_indicator_normal)


func _apply_preview_data() -> void:
	if not preview_description.is_empty():
		set_description(preview_description)
	if not preview_objective.is_empty():
		set_objective(preview_objective)
	if not preview_damage.is_empty():
		set_damage(preview_damage)
	if not preview_options.is_empty():
		set_options(preview_options)


func _connect_option_signals() -> void:
	for index in range(_option_buttons.size()):
		var button := _option_buttons[index]
		button.pressed.connect(_on_option_pressed.bind(index))
		button.button_down.connect(_on_option_button_down.bind(index))
		button.button_up.connect(_on_option_button_up.bind(index))
		button.mouse_entered.connect(_on_option_mouse_entered.bind(index))
		button.mouse_exited.connect(_on_option_mouse_exited.bind(index))
		button.focus_entered.connect(_on_option_focus_entered.bind(index))
		button.focus_exited.connect(_on_option_focus_exited.bind(index))


func _on_option_pressed(index: int) -> void:
	if not _is_valid_option_index(index):
		return
	if _option_buttons[index].disabled:
		return

	option_selected.emit(index)


func _on_option_button_down(index: int) -> void:
	_set_option_indicator(index, option_indicator_pressed)


func _on_option_button_up(index: int) -> void:
	if not _is_valid_option_index(index):
		return

	var button := _option_buttons[index]
	var texture := option_indicator_hover if button.has_focus() or button.is_hovered() else option_indicator_normal
	_set_option_indicator(index, texture)


func _on_option_mouse_entered(index: int) -> void:
	_set_option_indicator(index, option_indicator_hover)


func _on_option_mouse_exited(index: int) -> void:
	if not _is_valid_option_index(index):
		return

	var texture := option_indicator_hover if _option_buttons[index].has_focus() else option_indicator_normal
	_set_option_indicator(index, texture)


func _on_option_focus_entered(index: int) -> void:
	_set_option_indicator(index, option_indicator_hover)


func _on_option_focus_exited(index: int) -> void:
	if not _is_valid_option_index(index):
		return

	var texture := option_indicator_hover if _option_buttons[index].is_hovered() else option_indicator_normal
	_set_option_indicator(index, texture)


func _set_option_indicator(index: int, texture: Texture2D) -> void:
	if not _is_valid_option_index(index):
		return
	if texture == null:
		return

	_option_indicators[index].texture = texture


func _is_valid_option_index(index: int) -> bool:
	return index >= 0 and index < _option_buttons.size()
