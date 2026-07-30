extends Node2D

const MACRO_SOURCES: Array[Dictionary] = [
	{"name": "Clouds 256", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds256.png"},
	{"name": "Clouds 512", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds512.png"},
	{"name": "Clouds 1024", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds1024.png"},
	{"name": "Noise 1", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 1.png"},
	{"name": "Noise 2", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 2.png"},
	{"name": "Noise 3", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 3.png"},
	{"name": "Noise 4", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 4.png"},
	{"name": "Noise 5", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 5.png"},
]

@onready var base_experiment: Node = $BaseDualDrift
@onready var effect: ColorRect = $BaseDualDrift/EffectRoot/DualDriftEffect
@onready var macro_source: OptionButton = %MacroSource

var material_instance: ShaderMaterial


func _ready() -> void:
	_install_macro_shader()
	_configure_texture_texture_baseline()
	_populate_macro_sources()
	_connect_macro_controls()
	_reset_macro_defaults()


func _install_macro_shader() -> void:
	var previous_material := effect.material as ShaderMaterial
	material_instance = previous_material.duplicate() as ShaderMaterial
	material_instance.shader = load(
		"res://experiments/vfx/exp_vfx_001b_macro_density/macro_density.gdshader"
	) as Shader
	effect.material = material_instance
	base_experiment.material_instance = material_instance


func _configure_texture_texture_baseline() -> void:
	var mode: OptionButton = base_experiment.get_node("%SourceMode")
	mode.select(1)
	base_experiment._on_source_mode_changed(1)
	var source_a: OptionButton = base_experiment.get_node("%SourceA")
	var source_b: OptionButton = base_experiment.get_node("%SourceB")
	source_a.select(1)
	source_b.select(4)
	base_experiment._apply_sources()


func _populate_macro_sources() -> void:
	for source in MACRO_SOURCES:
		macro_source.add_item(str(source.name))
		macro_source.set_item_metadata(macro_source.item_count - 1, source.path)


func _connect_macro_controls() -> void:
	%EnableMacroDensity.toggled.connect(
		func(value: bool) -> void: _set_shader("macro_enabled", value)
	)
	macro_source.item_selected.connect(func(_index: int) -> void: _apply_macro_source())
	%MacroScale.value_changed.connect(
		func(value: float) -> void: _set_shader("macro_scale", value)
	)
	%MacroSpeed.value_changed.connect(
		func(value: float) -> void: _set_shader("macro_speed", value)
	)
	%MacroInfluence.value_changed.connect(
		func(value: float) -> void: _set_shader("macro_influence", value)
	)
	%MacroContrast.value_changed.connect(
		func(value: float) -> void: _set_shader("macro_contrast", value)
	)
	%ResetMacroDefaults.pressed.connect(_reset_macro_defaults)


func _reset_macro_defaults() -> void:
	%EnableMacroDensity.button_pressed = true
	macro_source.select(2)
	%MacroScale.value = 0.32
	%MacroSpeed.value = 0.001
	%MacroInfluence.value = 0.55
	%MacroContrast.value = 1.0
	_apply_macro_source()
	_set_shader("macro_enabled", true)
	_set_shader("macro_scale", 0.32)
	_set_shader("macro_speed", 0.001)
	_set_shader("macro_influence", 0.55)
	_set_shader("macro_contrast", 1.0)


func _apply_macro_source() -> void:
	if macro_source.item_count == 0:
		return
	var texture := load(str(macro_source.get_item_metadata(macro_source.selected))) as Texture2D
	_set_shader("macro_source", texture)


func _set_shader(parameter: StringName, value: Variant) -> void:
	material_instance.set_shader_parameter(parameter, value)
