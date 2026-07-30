extends Node2D

const SOURCES: Array[Dictionary] = [
	{"name": "Clouds 256", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds256.png"},
	{"name": "Clouds 512", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds512.png"},
	{"name": "Clouds 1024", "path": "res://Assets/VisualResearch/azureyoshi_seamless_fogs/Clouds1024.png"},
	{"name": "Noise 1", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 1.png"},
	{"name": "Noise 2", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 2.png"},
	{"name": "Noise 3", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 3.png"},
	{"name": "Noise 4", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 4.png"},
	{"name": "Noise 5", "path": "res://Assets/VisualResearch/starshinescribbles_fog_&_noise/Noise 5.png"},
]

const LAYERS := {
	"background": {
		"source": 2, "scale": 0.45, "speed": 0.0015,
		"direction": Vector2(0.7, 0.2), "opacity": 0.40, "contrast": 0.75,
		"tint": Color(0.18, 0.25, 0.32, 1.0),
	},
	"mid": {
		"source": 1, "scale": 1.2, "speed": 0.006,
		"direction": Vector2(-0.35, 0.8), "opacity": 0.45, "contrast": 1.25,
		"tint": Color(0.25, 0.33, 0.40, 1.0),
	},
	"foreground": {
		"source": 4, "scale": 2.4, "speed": 0.012,
		"direction": Vector2(0.85, -0.25), "opacity": 0.18, "contrast": 1.60,
		"tint": Color(0.34, 0.40, 0.45, 1.0),
	},
}

@onready var material_instance: ShaderMaterial = %DepthEffect.material as ShaderMaterial


func _ready() -> void:
	%ComparisonMode.add_item("Single Layer")
	%ComparisonMode.add_item("Dual Layer")
	%ComparisonMode.add_item("Triple Layer")
	%ComparisonMode.item_selected.connect(_on_comparison_selected)
	_populate_sources()
	_connect_layer_controls()
	%ResetDefaults.pressed.connect(_reset_defaults)
	_reset_defaults()


func _populate_sources() -> void:
	for layer_id in LAYERS:
		var selector: OptionButton = _control(layer_id, "Source")
		for source in SOURCES:
			selector.add_item(str(source.name))
			selector.set_item_metadata(selector.item_count - 1, source.path)


func _connect_layer_controls() -> void:
	for layer_id in LAYERS:
		var captured_id: String = layer_id
		_control(captured_id, "Enabled").toggled.connect(
			func(value: bool) -> void: _set_shader(captured_id, "enabled", value)
		)
		_control(captured_id, "Source").item_selected.connect(
			func(_index: int) -> void: _apply_source(captured_id)
		)
		for suffix in ["Scale", "Speed", "Opacity", "Contrast"]:
			var captured_suffix: String = suffix
			_control(captured_id, captured_suffix).value_changed.connect(
				func(value: float) -> void:
					_set_shader(captured_id, captured_suffix.to_snake_case(), value)
			)
		for suffix in ["DirectionX", "DirectionY"]:
			var captured_suffix: String = suffix
			_control(captured_id, captured_suffix).value_changed.connect(
				func(_value: float) -> void: _apply_direction(captured_id)
			)
		_control(captured_id, "Tint").color_changed.connect(
			func(value: Color) -> void: _set_shader(captured_id, "tint", value)
		)


func _reset_defaults() -> void:
	for layer_id in LAYERS:
		var defaults: Dictionary = LAYERS[layer_id]
		_control(layer_id, "Source").select(defaults.source)
		_control(layer_id, "Scale").value = defaults.scale
		_control(layer_id, "Speed").value = defaults.speed
		_control(layer_id, "DirectionX").value = defaults.direction.x
		_control(layer_id, "DirectionY").value = defaults.direction.y
		_control(layer_id, "Opacity").value = defaults.opacity
		_control(layer_id, "Contrast").value = defaults.contrast
		_control(layer_id, "Tint").color = defaults.tint
		_apply_source(layer_id)
		_apply_direction(layer_id)
		_set_shader(layer_id, "scale", defaults.scale)
		_set_shader(layer_id, "speed", defaults.speed)
		_set_shader(layer_id, "opacity", defaults.opacity)
		_set_shader(layer_id, "contrast", defaults.contrast)
		_set_shader(layer_id, "tint", defaults.tint)
	%ComparisonMode.select(2)
	_on_comparison_selected(2)


func _on_comparison_selected(index: int) -> void:
	_control("background", "Enabled").button_pressed = index >= 1
	_control("mid", "Enabled").button_pressed = true
	_control("foreground", "Enabled").button_pressed = index >= 2
	_set_shader("background", "enabled", index >= 1)
	_set_shader("mid", "enabled", true)
	_set_shader("foreground", "enabled", index >= 2)


func _apply_source(layer_id: String) -> void:
	var selector: OptionButton = _control(layer_id, "Source")
	var texture := load(str(selector.get_item_metadata(selector.selected))) as Texture2D
	_set_shader(layer_id, "source", texture)


func _apply_direction(layer_id: String) -> void:
	_set_shader(
		layer_id,
		"direction",
		Vector2(
			_control(layer_id, "DirectionX").value,
			_control(layer_id, "DirectionY").value
		)
	)


func _set_shader(layer_id: String, property: String, value: Variant) -> void:
	material_instance.set_shader_parameter("%s_%s" % [layer_id, property], value)


func _control(layer_id: String, suffix: String) -> Variant:
	return get_node("%%%s%s" % [layer_id.to_pascal_case(), suffix])
