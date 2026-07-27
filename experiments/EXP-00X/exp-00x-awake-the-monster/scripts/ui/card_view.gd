class_name CardView
extends Control

@onready var illustration: TextureRect = %Illustration
@onready var narrative_text: RichTextLabel = %NarrativeText
@onready var threat_bar: Control = $CardCenter/CardCanvas/CardThreatBar
@onready var attention_icon: Sprite2D = $CardCenter/CardCanvas/CardThreatBar/HBoxContainer/AttentionIcon
@onready var sanity_icon: Sprite2D = $CardCenter/CardCanvas/CardThreatBar/HBoxContainer/SanityIcon
@onready var strength_icon: Sprite2D = $CardCenter/CardCanvas/CardThreatBar/HBoxContainer/StrengthIcon
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


func set_card(card_data: CardData) -> void:
	if card_data == null:
		push_warning("CardView cannot present a null CardData resource.")
		return

	illustration.texture = card_data.illustration
	narrative_text.text = card_data.description
	_set_objective(card_data.objective_text)
	damage_text.text = str(card_data.damage)
	damage_indicator.visible = card_data.damage > 0
	threat_bar.visible = not card_data.objective_text.is_empty() or card_data.damage > 0
	_set_options(card_data.option_labels)


func _set_objective(objective_text: String) -> void:
	var normalized_objective := objective_text.strip_edges().to_upper()

	attention_icon.visible = normalized_objective == "ATENCIÓN"
	sanity_icon.visible = normalized_objective == "CORDURA"
	strength_icon.visible = normalized_objective == "FUERZA"


func _set_options(labels: Array[String]) -> void:
	for index in range(option_buttons.size()):
		var has_option := index < labels.size() and not labels[index].is_empty()
		option_buttons[index].visible = has_option
		option_buttons[index].disabled = not has_option
		option_labels[index].text = labels[index] if has_option else ""
