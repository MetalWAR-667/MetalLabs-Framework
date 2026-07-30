extends Node2D

const PRESETS: Array[Dictionary] = [
	{"name": "Original", "node_speed": 1.0, "node_amplitude": 0.4, "depth_speed": 0.05, "line_width": 0.014, "connection_distance": 0.8, "connection_intensity": 1.0, "node_intensity": 1.0, "flicker_speed": 2.0, "overall_scale": 1.5, "background_intensity": 0.01, "global_intensity": 1.0, "main_color": Color.WHITE, "color_variation": 1.0, "color_cycle_speed": 2.0},
	{"name": "Constellation", "node_speed": 0.35, "node_amplitude": 0.25, "depth_speed": 0.018, "line_width": 0.008, "connection_distance": 0.65, "connection_intensity": 0.45, "node_intensity": 1.25, "flicker_speed": 0.5, "overall_scale": 1.1, "background_intensity": 0.004, "global_intensity": 0.75, "main_color": Color(0.68, 0.78, 0.92), "color_variation": 0.15, "color_cycle_speed": 0.2},
	{"name": "Neural", "node_speed": 0.8, "node_amplitude": 0.32, "depth_speed": 0.035, "line_width": 0.012, "connection_distance": 0.95, "connection_intensity": 1.2, "node_intensity": 1.0, "flicker_speed": 0.9, "overall_scale": 1.35, "background_intensity": 0.008, "global_intensity": 0.9, "main_color": Color(0.56, 0.86, 0.82), "color_variation": 0.35, "color_cycle_speed": 0.7},
	{"name": "Dream Lattice", "node_speed": 0.25, "node_amplitude": 0.30, "depth_speed": 0.028, "line_width": 0.010, "connection_distance": 0.82, "connection_intensity": 0.68, "node_intensity": 0.72, "flicker_speed": 0.35, "overall_scale": 1.8, "background_intensity": 0.006, "global_intensity": 0.72, "main_color": Color(0.62, 0.68, 0.82), "color_variation": 0.10, "color_cycle_speed": 0.15},
	{"name": "Unstable", "node_speed": 1.5, "node_amplitude": 0.45, "depth_speed": 0.08, "line_width": 0.012, "connection_distance": 0.85, "connection_intensity": 0.95, "node_intensity": 1.1, "flicker_speed": 3.5, "overall_scale": 1.6, "background_intensity": 0.012, "global_intensity": 1.0, "main_color": Color(0.82, 0.62, 0.75), "color_variation": 0.90, "color_cycle_speed": 3.0},
]

const CONTROL_PARAMETERS := {
	"NodeSpeed": "node_speed", "NodeAmplitude": "node_amplitude",
	"DepthSpeed": "depth_speed", "LineWidth": "line_width",
	"ConnectionDistance": "connection_distance",
	"ConnectionIntensity": "connection_intensity",
	"NodeIntensity": "node_intensity", "FlickerSpeed": "flicker_speed",
	"OverallScale": "overall_scale", "BackgroundIntensity": "background_intensity",
	"GlobalIntensity": "global_intensity", "ColorVariation": "color_variation",
	"ColorCycleSpeed": "color_cycle_speed",
}

@onready var material_instance: ShaderMaterial = %NetworkEffect.material as ShaderMaterial

var elapsed_time := 0.0
var local_paused := false


func _ready() -> void:
	for preset in PRESETS:
		%PresetSelector.add_item(preset.name)
	%PresetSelector.item_selected.connect(_apply_preset)
	for control_name in CONTROL_PARAMETERS:
		var control: Range = get_node("%%%s" % control_name)
		var parameter: String = CONTROL_PARAMETERS[control_name]
		control.value_changed.connect(
			func(value: float) -> void:
				material_instance.set_shader_parameter(parameter, value)
		)
	%MainColor.color_changed.connect(
		func(value: Color) -> void:
			material_instance.set_shader_parameter("main_color", value)
	)
	%AnimationEnabled.toggled.connect(func(_value: bool) -> void: _update_metrics())
	%PauseButton.pressed.connect(_toggle_pause)
	%ResetTimeButton.pressed.connect(_reset_time)
	%RestorePresetButton.pressed.connect(
		func() -> void: _apply_preset(%PresetSelector.selected)
	)
	%NodesOnly.toggled.connect(func(value: bool) -> void: _set_nodes_only(value))
	%ConnectionsOnly.toggled.connect(
		func(value: bool) -> void: _set_connections_only(value)
	)
	%SingleLayer.toggled.connect(
		func(value: bool) -> void:
			material_instance.set_shader_parameter("single_layer", value)
			_update_metrics()
	)
	_apply_preset(0)


func _process(delta: float) -> void:
	if %AnimationEnabled.button_pressed and not local_paused:
		elapsed_time += delta
		material_instance.set_shader_parameter("network_time", elapsed_time)
	_update_metrics()


func _apply_preset(index: int) -> void:
	var preset: Dictionary = PRESETS[index]
	for control_name in CONTROL_PARAMETERS:
		var parameter: String = CONTROL_PARAMETERS[control_name]
		var control: Range = get_node("%%%s" % control_name)
		control.value = preset[parameter]
		material_instance.set_shader_parameter(parameter, preset[parameter])
	%MainColor.color = preset.main_color
	material_instance.set_shader_parameter("main_color", preset.main_color)
	%NodesOnly.set_pressed_no_signal(false)
	%ConnectionsOnly.set_pressed_no_signal(false)
	%SingleLayer.set_pressed_no_signal(false)
	material_instance.set_shader_parameter("show_nodes", true)
	material_instance.set_shader_parameter("show_connections", true)
	material_instance.set_shader_parameter("single_layer", false)
	_reset_time()


func _toggle_pause() -> void:
	local_paused = not local_paused
	%PauseButton.text = "Resume" if local_paused else "Pause"
	_update_metrics()


func _reset_time() -> void:
	elapsed_time = 0.0
	material_instance.set_shader_parameter("network_time", 0.0)


func _set_nodes_only(enabled: bool) -> void:
	if enabled:
		%ConnectionsOnly.set_pressed_no_signal(false)
	material_instance.set_shader_parameter("show_nodes", true)
	material_instance.set_shader_parameter("show_connections", not enabled)


func _set_connections_only(enabled: bool) -> void:
	if enabled:
		%NodesOnly.set_pressed_no_signal(false)
	material_instance.set_shader_parameter("show_nodes", not enabled)
	material_instance.set_shader_parameter("show_connections", true)


func _update_metrics() -> void:
	var animation_state := "Disabled"
	if %AnimationEnabled.button_pressed:
		animation_state = "Paused" if local_paused else "Running"
	%LocalMetrics.text = (
		"Preset: %s\nLayers: %d\nAnimation: %s\nScale: %.2f"
		% [
			%PresetSelector.get_item_text(%PresetSelector.selected),
			1 if %SingleLayer.button_pressed else 5,
			animation_state,
			%OverallScale.value,
		]
	)
