extends Node2D

const PRESETS: Array[Dictionary] = [
	{
		"center": Vector2(0.43, 0.54), "radius": 0.72, "strength": 0.18,
		"falloff": 0.46, "rotation": -0.35, "drift": 0.18,
		"influences": Vector3(0.22, 0.82, 0.38),
	},
	{
		"center": Vector2(0.52, 0.49), "radius": 0.48, "strength": -0.16,
		"falloff": 0.28, "rotation": 0.0, "drift": 0.12,
		"influences": Vector3(0.18, 0.78, 0.32),
	},
	{
		"center": Vector2(0.55, 0.56), "radius": 0.58, "strength": 0.20,
		"falloff": 0.34, "rotation": -0.70, "drift": 0.14,
		"influences": Vector3(0.16, 0.86, 0.42),
	},
]

@onready var base_experiment: Node = $BaseDepthLayers
@onready var effect: ColorRect = $BaseDepthLayers/EffectRoot/DepthEffect

var material_instance: ShaderMaterial


func _ready() -> void:
	_install_field_shader()
	_populate_selectors()
	_connect_controls()
	_apply_preset(0)


func _install_field_shader() -> void:
	var previous_material := effect.material as ShaderMaterial
	material_instance = previous_material.duplicate() as ShaderMaterial
	material_instance.shader = load(
		"res://experiments/vfx/exp_vfx_004_geometric_flow_fields/geometric_flow_fields.gdshader"
	) as Shader
	effect.material = material_instance
	base_experiment.material_instance = material_instance
	base_experiment._reset_defaults()


func _populate_selectors() -> void:
	for label in ["No Field", "Vortex", "Ring", "Arc", "Field Debug"]:
		%ComparisonMode.add_item(label)
	for label in ["Vortex", "Ring", "Arc"]:
		%FieldType.add_item(label)


func _connect_controls() -> void:
	%ComparisonMode.item_selected.connect(_on_comparison_selected)
	%FieldType.item_selected.connect(_on_field_type_selected)
	%EnableField.toggled.connect(func(value: bool) -> void: _set_shader("field_enabled", value))
	%CenterX.value_changed.connect(func(_value: float) -> void: _apply_center())
	%CenterY.value_changed.connect(func(_value: float) -> void: _apply_center())
	for connection in [
		[%Radius, "field_radius"],
		[%Strength, "field_strength"],
		[%Falloff, "field_falloff"],
		[%Rotation, "field_rotation"],
		[%TemporalDrift, "temporal_drift"],
		[%BackgroundInfluence, "background_field_influence"],
		[%MidInfluence, "mid_field_influence"],
		[%ForegroundInfluence, "foreground_field_influence"],
	]:
		var control: Range = connection[0]
		var parameter: String = connection[1]
		control.value_changed.connect(
			func(value: float) -> void: _set_shader(parameter, value)
		)
	%FieldDebug.toggled.connect(func(value: bool) -> void: _set_shader("field_debug", value))
	%ResetDefaults.pressed.connect(func() -> void: _apply_preset(0))


func _on_comparison_selected(index: int) -> void:
	if index == 0:
		%EnableField.button_pressed = false
		%FieldDebug.button_pressed = false
		_set_shader("field_enabled", false)
		_set_shader("field_debug", false)
		return
	if index == 4:
		%EnableField.button_pressed = true
		%FieldDebug.button_pressed = true
		_set_shader("field_enabled", true)
		_set_shader("field_debug", true)
		return
	%FieldDebug.button_pressed = false
	_apply_preset(index - 1)


func _on_field_type_selected(index: int) -> void:
	_apply_preset(index)


func _apply_preset(index: int) -> void:
	var preset: Dictionary = PRESETS[index]
	%EnableField.button_pressed = true
	%FieldDebug.button_pressed = false
	%FieldType.select(index)
	%ComparisonMode.select(index + 1)
	%CenterX.value = preset.center.x
	%CenterY.value = preset.center.y
	%Radius.value = preset.radius
	%Strength.value = preset.strength
	%Falloff.value = preset.falloff
	%Rotation.value = preset.rotation
	%TemporalDrift.value = preset.drift
	%BackgroundInfluence.value = preset.influences.x
	%MidInfluence.value = preset.influences.y
	%ForegroundInfluence.value = preset.influences.z
	_set_shader("field_enabled", true)
	_set_shader("field_debug", false)
	_set_shader("field_type", index)
	_apply_center()
	_set_shader("field_radius", preset.radius)
	_set_shader("field_strength", preset.strength)
	_set_shader("field_falloff", preset.falloff)
	_set_shader("field_rotation", preset.rotation)
	_set_shader("temporal_drift", preset.drift)
	_set_shader("background_field_influence", preset.influences.x)
	_set_shader("mid_field_influence", preset.influences.y)
	_set_shader("foreground_field_influence", preset.influences.z)


func _apply_center() -> void:
	_set_shader("field_center", Vector2(%CenterX.value, %CenterY.value))


func _set_shader(parameter: StringName, value: Variant) -> void:
	material_instance.set_shader_parameter(parameter, value)
