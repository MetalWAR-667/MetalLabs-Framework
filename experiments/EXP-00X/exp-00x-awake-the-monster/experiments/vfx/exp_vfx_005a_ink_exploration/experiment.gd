extends Node2D

const DEFAULTS := {
	"ink_amount": 0.55,
	"ink_threshold": 0.52,
	"ink_contrast": 1.8,
	"edge_width": 0.06,
	"spread": 0.08,
	"spread_speed": 0.12,
	"flow_distortion": 0.08,
	"flow_scale": 1.7,
	"dark_core": 0.78,
	"diffusion_halo": 0.34,
	"temporal_drift": 0.015,
	"ink_color": Color(0.018, 0.022, 0.028, 1.0),
}

const CONTROL_PARAMETERS := {
	"InkAmount": "ink_amount",
	"InkThreshold": "ink_threshold",
	"InkContrast": "ink_contrast",
	"EdgeWidth": "edge_width",
	"Spread": "spread",
	"SpreadSpeed": "spread_speed",
	"FlowDistortion": "flow_distortion",
	"FlowScale": "flow_scale",
	"DarkCore": "dark_core",
	"DiffusionHalo": "diffusion_halo",
	"TemporalDrift": "temporal_drift",
}

@onready var material_instance: ShaderMaterial = %InkEffect.material as ShaderMaterial


func _ready() -> void:
	for label in ["Base Source", "Ink Mask", "Composite"]:
		%ObservationMode.add_item(label)
	%ObservationMode.item_selected.connect(
		func(index: int) -> void:
			material_instance.set_shader_parameter("observation_mode", index)
	)
	for control_name in CONTROL_PARAMETERS:
		var control: Range = get_node("%%%s" % control_name)
		var parameter: String = CONTROL_PARAMETERS[control_name]
		control.value_changed.connect(
			func(value: float) -> void:
				material_instance.set_shader_parameter(parameter, value)
		)
	%InkColor.color_changed.connect(
		func(value: Color) -> void:
			material_instance.set_shader_parameter("ink_color", value)
	)
	%ResetDefaults.pressed.connect(_reset_defaults)
	_reset_defaults()


func _reset_defaults() -> void:
	%ObservationMode.select(2)
	material_instance.set_shader_parameter("observation_mode", 2)
	for control_name in CONTROL_PARAMETERS:
		var parameter: String = CONTROL_PARAMETERS[control_name]
		var control: Range = get_node("%%%s" % control_name)
		control.value = DEFAULTS[parameter]
		material_instance.set_shader_parameter(parameter, DEFAULTS[parameter])
	%InkColor.color = DEFAULTS.ink_color
	material_instance.set_shader_parameter("ink_color", DEFAULTS.ink_color)
