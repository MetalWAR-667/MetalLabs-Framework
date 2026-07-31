class_name ActorPanel
extends Control

@onready var name_label: Label = $ActorIllustration/PortraitTexture/NameLabel
@onready var portrait_texture: TextureRect = $ActorIllustration/PortraitTexture
@onready var health_value: Label = %HealthValue
@onready var attention_value: Label = $StatsColumn/HBox_Attention/AttentionStat/AttentionStat
@onready var sanity_value: Label = $StatsColumn/HBox_Sanity/SanityStat/SanityStat
@onready var strength_value: Label = $StatsColumn/HBox_Strength/StrengthStat/StrengthStat
@onready var card_border: TextureRect = $CardBorder

var border_shader_time := 0.0


func _process(delta: float) -> void:
	border_shader_time += delta
	if card_border.material is ShaderMaterial:
		card_border.material.set_shader_parameter(
			"custom_time",
			border_shader_time
		)


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


func set_health(health: int) -> void:
	health_value.text = str(health)


func set_sanity(sanity: int) -> void:
	sanity_value.text = str(sanity)
