extends Node2D

@onready var base_experiment: Node = $BaseInkExploration
@onready var effect: ColorRect = $BaseInkExploration/InkEffect

var material_instance: ShaderMaterial


func _ready() -> void:
	var previous_material := effect.material as ShaderMaterial
	material_instance = previous_material.duplicate() as ShaderMaterial
	material_instance.shader = load(
		"res://experiments/vfx/exp_vfx_005b_structural_ink/structural_ink.gdshader"
	) as Shader
	material_instance.set_shader_parameter(
		"ink_source",
		load(
			"res://experiments/vfx/exp_vfx_005b_structural_ink/cellular_structure.tres"
		) as Texture2D
	)
	effect.material = material_instance
	base_experiment.material_instance = material_instance
	base_experiment._reset_defaults()
	$BaseInkExploration/Controls/Margin/VBox/Title.text = \
		"EXP-VFX-005B — Structural Ink"
