extends Node2D

enum SourceMode {
	NATIVE_NATIVE,
	TEXTURE_TEXTURE,
	NATIVE_TEXTURE,
}

const DEFAULTS := {
	"speed_a": 0.008,
	"speed_b": 0.005,
	"direction_a": Vector2(1.0, 0.18),
	"direction_b": Vector2(-0.35, 1.0),
	"scale_a": 1.15,
	"scale_b": 1.65,
	"opacity": 0.62,
	"contrast": 1.35,
	"threshold": 0.42,
	"fog_tint": Color(0.28, 0.36, 0.44, 1.0),
	"combination_mode": 2,
}

const NATIVE_SOURCES: Array[Dictionary] = [
	{"name": "Native Broad", "path": "res://experiments/vfx/exp_vfx_001_dual_drift/native_broad.tres"},
	{"name": "Native Detail", "path": "res://experiments/vfx/exp_vfx_001_dual_drift/native_detail.tres"},
]

const TEXTURE_SOURCES: Array[Dictionary] = [
	{"name": "Clouds 256", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds256.png"},
	{"name": "Clouds 512", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds512.png"},
	{"name": "Clouds 1024", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds1024.png"},
	{"name": "Noise 1", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 1.png"},
	{"name": "Noise 2", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 2.png"},
	{"name": "Noise 3", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 3.png"},
	{"name": "Noise 4", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 4.png"},
	{"name": "Noise 5", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 5.png"},
]

@onready var effect: ColorRect = %DualDriftEffect
@onready var source_mode: OptionButton = %SourceMode
@onready var source_a: OptionButton = %SourceA
@onready var source_b: OptionButton = %SourceB

var material_instance: ShaderMaterial


func _ready() -> void:
	material_instance = effect.material as ShaderMaterial
	_populate_static_controls()
	_connect_controls()
	_reset_defaults()


func _populate_static_controls() -> void:
	for label in ["Native / Native", "Texture / Texture", "Native / Texture"]:
		source_mode.add_item(label)
	for label in ["Multiply", "Minimum", "Average", "Maximum"]:
		%CombinationMode.add_item(label)


func _connect_controls() -> void:
	source_mode.item_selected.connect(_on_source_mode_changed)
	source_a.item_selected.connect(func(_index: int) -> void: _apply_sources())
	source_b.item_selected.connect(func(_index: int) -> void: _apply_sources())
	%SpeedA.value_changed.connect(func(value: float) -> void: _set_shader("speed_a", value))
	%SpeedB.value_changed.connect(func(value: float) -> void: _set_shader("speed_b", value))
	%DirectionAX.value_changed.connect(func(_value: float) -> void: _apply_directions())
	%DirectionAY.value_changed.connect(func(_value: float) -> void: _apply_directions())
	%DirectionBX.value_changed.connect(func(_value: float) -> void: _apply_directions())
	%DirectionBY.value_changed.connect(func(_value: float) -> void: _apply_directions())
	%ScaleA.value_changed.connect(func(value: float) -> void: _set_shader("scale_a", value))
	%ScaleB.value_changed.connect(func(value: float) -> void: _set_shader("scale_b", value))
	%Opacity.value_changed.connect(func(value: float) -> void: _set_shader("opacity", value))
	%Contrast.value_changed.connect(func(value: float) -> void: _set_shader("contrast", value))
	%Threshold.value_changed.connect(func(value: float) -> void: _set_shader("threshold", value))
	%Tint.color_changed.connect(func(value: Color) -> void: _set_shader("fog_tint", value))
	%CombinationMode.item_selected.connect(
		func(value: int) -> void: _set_shader("combination_mode", value)
	)
	%ResetDefaults.pressed.connect(_reset_defaults)


func _reset_defaults() -> void:
	source_mode.select(SourceMode.NATIVE_TEXTURE)
	_rebuild_source_selectors()
	source_a.select(0)
	source_b.select(1)
	%SpeedA.value = DEFAULTS.speed_a
	%SpeedB.value = DEFAULTS.speed_b
	%DirectionAX.value = DEFAULTS.direction_a.x
	%DirectionAY.value = DEFAULTS.direction_a.y
	%DirectionBX.value = DEFAULTS.direction_b.x
	%DirectionBY.value = DEFAULTS.direction_b.y
	%ScaleA.value = DEFAULTS.scale_a
	%ScaleB.value = DEFAULTS.scale_b
	%Opacity.value = DEFAULTS.opacity
	%Contrast.value = DEFAULTS.contrast
	%Threshold.value = DEFAULTS.threshold
	%Tint.color = DEFAULTS.fog_tint
	%CombinationMode.select(DEFAULTS.combination_mode)
	_apply_all_parameters()


func _on_source_mode_changed(_index: int) -> void:
	_rebuild_source_selectors()
	_apply_sources()


func _rebuild_source_selectors() -> void:
	var sources_a := _sources_for_layer(true)
	var sources_b := _sources_for_layer(false)
	_fill_source_selector(source_a, sources_a)
	_fill_source_selector(source_b, sources_b)


func _fill_source_selector(selector: OptionButton, sources: Array[Dictionary]) -> void:
	selector.clear()
	for source in sources:
		selector.add_item(str(source.name))
		selector.set_item_metadata(selector.item_count - 1, source.path)
	selector.select(0)


func _sources_for_layer(is_layer_a: bool) -> Array[Dictionary]:
	match source_mode.selected:
		SourceMode.NATIVE_NATIVE:
			return NATIVE_SOURCES
		SourceMode.TEXTURE_TEXTURE:
			return TEXTURE_SOURCES
		SourceMode.NATIVE_TEXTURE:
			return NATIVE_SOURCES if is_layer_a else TEXTURE_SOURCES
	return NATIVE_SOURCES


func _apply_all_parameters() -> void:
	_apply_sources()
	_apply_directions()
	_set_shader("speed_a", %SpeedA.value)
	_set_shader("speed_b", %SpeedB.value)
	_set_shader("scale_a", %ScaleA.value)
	_set_shader("scale_b", %ScaleB.value)
	_set_shader("opacity", %Opacity.value)
	_set_shader("contrast", %Contrast.value)
	_set_shader("threshold", %Threshold.value)
	_set_shader("fog_tint", %Tint.color)
	_set_shader("combination_mode", %CombinationMode.selected)


func _apply_sources() -> void:
	if source_a.item_count == 0 or source_b.item_count == 0:
		return
	var texture_a := load(str(source_a.get_item_metadata(source_a.selected))) as Texture2D
	var texture_b := load(str(source_b.get_item_metadata(source_b.selected))) as Texture2D
	_set_shader("source_a", texture_a)
	_set_shader("source_b", texture_b)


func _apply_directions() -> void:
	_set_shader("direction_a", Vector2(%DirectionAX.value, %DirectionAY.value))
	_set_shader("direction_b", Vector2(%DirectionBX.value, %DirectionBY.value))


func _set_shader(parameter: StringName, value: Variant) -> void:
	material_instance.set_shader_parameter(parameter, value)
