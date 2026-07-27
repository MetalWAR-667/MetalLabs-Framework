class_name ActorPanel
extends Control

@onready var name_label: Label = $ActorIllustration/PortraitTexture/NameLabel
@onready var portrait_texture: TextureRect = $ActorIllustration/PortraitTexture
@onready var health_value: Label = %HealthValue
@onready var attention_value: Label = $StatsColumn/HBox_Attention/AttentionStat/AttentionStat
@onready var sanity_value: Label = $StatsColumn/HBox_Sanity/SanityStat/SanityStat
@onready var strength_value: Label = $StatsColumn/HBox_Strength/StrengthStat/StrengthStat


func set_actor(actor_data: ActorData) -> void:
	if actor_data == null:
		push_warning("ActorPanel cannot present a null ActorData resource.")
		return

	name_label.text = actor_data.display_name
	portrait_texture.texture = actor_data.portrait
	health_value.text = str(actor_data.health)
	attention_value.text = str(actor_data.attention)
	sanity_value.text = str(actor_data.sanity)
	strength_value.text = str(actor_data.strength)
