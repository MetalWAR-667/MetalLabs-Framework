extends Node2D

const DEFAULT_TWIST_STRENGTH := 1.15
const DEFAULT_TWIST_RADIUS := 0.82
const DEFAULT_TWIST_CENTER := Vector2(0.43, 0.56)
const DEFAULT_TWIST_SPEED := 0.025

@onready var structural_experiment: Node = $BaseStructuralInk
@onready var ink_experiment: Node = $BaseStructuralInk/BaseInkExploration
@onready var effect: ColorRect = $BaseStructuralInk/BaseInkExploration/InkEffect

var material_instance: ShaderMaterial


func _ready() -> void:
	_install_flow_shader()
	_add_deformed_source_mode()
	_connect_flow_controls()
	_reset_flow_defaults()
	$BaseStructuralInk/BaseInkExploration/Controls/Margin/VBox/Title.text = \
		"EXP-VFX-005C — Flow Deformation"


func _install_flow_shader() -> void:
	var previous_material := effect.material as ShaderMaterial
	var structural_source := (
		previous_material.get_shader_parameter("ink_source") as Texture2D
	)
	material_instance = previous_material.duplicate() as ShaderMaterial
	material_instance.shader = load(
		"res://experiments/vfx/exp_vfx_005c_flow_deformation/flow_deformation.gdshader"
	) as Shader
	material_instance.set_shader_parameter("ink_source", structural_source)
	effect.material = material_instance
	structural_experiment.material_instance = material_instance
	ink_experiment.material_instance = material_instance
	ink_experiment._reset_defaults()


func _add_deformed_source_mode() -> void:
	var selector: OptionButton = ink_experiment.get_node("%ObservationMode")
	selector.add_item("Deformed Source")


func _connect_flow_controls() -> void:
	%TwistStrength.value_changed.connect(
		func(value: float) -> void: _set_shader("twist_strength", value)
	)
	%TwistRadius.value_changed.connect(
		func(value: float) -> void: _set_shader("twist_radius", value)
	)
	%TwistCenterX.value_changed.connect(func(_value: float) -> void: _apply_center())
	%TwistCenterY.value_changed.connect(func(_value: float) -> void: _apply_center())
	%TwistSpeed.value_changed.connect(
		func(value: float) -> void: _set_shader("twist_speed", value)
	)
	%ResetFlowDefaults.pressed.connect(_reset_flow_defaults)


func _reset_flow_defaults() -> void:
	%TwistStrength.value = DEFAULT_TWIST_STRENGTH
	%TwistRadius.value = DEFAULT_TWIST_RADIUS
	%TwistCenterX.value = DEFAULT_TWIST_CENTER.x
	%TwistCenterY.value = DEFAULT_TWIST_CENTER.y
	%TwistSpeed.value = DEFAULT_TWIST_SPEED
	_set_shader("twist_strength", DEFAULT_TWIST_STRENGTH)
	_set_shader("twist_radius", DEFAULT_TWIST_RADIUS)
	_set_shader("twist_center", DEFAULT_TWIST_CENTER)
	_set_shader("twist_speed", DEFAULT_TWIST_SPEED)


func _apply_center() -> void:
	_set_shader("twist_center", Vector2(%TwistCenterX.value, %TwistCenterY.value))


func _set_shader(parameter: StringName, value: Variant) -> void:
	material_instance.set_shader_parameter(parameter, value)
