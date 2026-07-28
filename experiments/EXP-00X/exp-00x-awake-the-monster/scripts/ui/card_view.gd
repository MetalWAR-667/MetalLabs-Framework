class_name CardView
extends Control

signal option_selected(option_index: int)

@onready var illustration: TextureRect = %Illustration
@onready var narrative_text: RichTextLabel = %NarrativeText
@onready var threat_bar: Control = $CardCenter/CardCanvas/CardThreatBar
@onready var attention_icon: Sprite2D = $CardCenter/CardCanvas/CardThreatBar/HBoxContainer/AttentionIcon
@onready var sanity_icon: Sprite2D = $CardCenter/CardCanvas/CardThreatBar/HBoxContainer/SanityIcon
@onready var strength_icon: Sprite2D = $CardCenter/CardCanvas/CardThreatBar/HBoxContainer/StrengthIcon
@onready var attention_amount: Label = $CardCenter/CardCanvas/CardThreatBar/AttentionAmount
@onready var sanity_amount: Label = $CardCenter/CardCanvas/CardThreatBar/SanityAmount
@onready var strength_amount: Label = $CardCenter/CardCanvas/CardThreatBar/StrengthAmount
@onready var damage_indicator: Control = $CardCenter/CardCanvas/CardThreatBar/DamageIndicator
@onready var damage_text: Label = $CardCenter/CardCanvas/CardThreatBar/DamageIndicator/DamageText

@onready var option_buttons: Array[Button] = [
	%OptionButton01,
	%OptionButton02,
	%OptionButton03,
]

@onready var option_labels: Array[Label] = [
	%OptionText01,
	%OptionText02,
	%OptionText03,
]


func _ready() -> void:
	for index in range(option_buttons.size()):
		option_buttons[index].pressed.connect(_on_option_pressed.bind(index))


func set_card(card_data: CardData) -> void:
	if card_data == null:
		push_warning("CardView cannot present a null CardData resource.")
		return

	illustration.texture = card_data.illustration
	narrative_text.text = card_data.description
	_set_options(card_data.options)
	if card_data.options.size() == 1 and _option_has_threat(card_data.options[0]):
		var option := card_data.options[0]
		show_threat(option.required_stat, option.required_successes, option.damage)
	else:
		hide_threat()


func set_options_enabled(enabled: bool) -> void:
	for button in option_buttons:
		if button.visible:
			button.disabled = not enabled


func set_option_enabled(option_index: int, enabled: bool) -> void:
	if option_index < 0 or option_index >= option_buttons.size():
		return
	if not option_buttons[option_index].visible:
		return

	option_buttons[option_index].disabled = not enabled


func show_threat(required_stat: CardOptionData.StatType, amount: int, damage: int) -> void:
	threat_bar.show()
	attention_icon.visible = required_stat == CardOptionData.StatType.ATTENTION
	attention_amount.visible = attention_icon.visible
	sanity_icon.visible = required_stat == CardOptionData.StatType.SANITY
	sanity_amount.visible = sanity_icon.visible
	strength_icon.visible = required_stat == CardOptionData.StatType.STRENGTH
	strength_amount.visible = strength_icon.visible

	var amount_text := "×%d" % amount
	attention_amount.text = amount_text
	sanity_amount.text = amount_text
	strength_amount.text = amount_text
	damage_indicator.visible = damage > 0
	damage_text.text = str(damage)


func hide_threat() -> void:
	threat_bar.hide()
	attention_icon.hide()
	attention_amount.hide()
	sanity_icon.hide()
	sanity_amount.hide()
	strength_icon.hide()
	strength_amount.hide()
	damage_indicator.hide()
	damage_text.text = "0"


func _set_options(options: Array[CardOptionData]) -> void:
	for index in range(option_buttons.size()):
		var has_option := index < options.size() and options[index] != null and not options[index].text.is_empty()
		option_buttons[index].visible = has_option
		option_buttons[index].disabled = not has_option
		option_labels[index].text = options[index].text if has_option else ""


func _option_has_threat(option: CardOptionData) -> bool:
	return option != null and option.required_stat != CardOptionData.StatType.NONE


func _on_option_pressed(option_index: int) -> void:
	if option_index < 0 or option_index >= option_buttons.size():
		return

	var selected_button := option_buttons[option_index]
	if not selected_button.visible or selected_button.disabled:
		return

	set_options_enabled(false)
	option_selected.emit(option_index)
