extends Node2D

const GOLDEN_ANGLE := 2.399963

@onready var graph_view: DynamicGraphView = %GraphView
@onready var bloom_material: ShaderMaterial = %BloomOutput.material as ShaderMaterial

var auto_play := false
var auto_play_interval := 1.4
var auto_play_elapsed := 0.0
var last_index := -1


func _ready() -> void:
	%AddNodeButton.pressed.connect(_add_random_node)
	%ClearButton.pressed.connect(_clear_graph)
	%AutoPlay.toggled.connect(func(value: bool) -> void: auto_play = value)
	%ConnectMode.item_selected.connect(func(_index: int) -> void: pass)

	%BloomThreshold.value_changed.connect(
		func(value: float) -> void: bloom_material.set_shader_parameter("bloom_threshold", value)
	)
	%BloomIntensity.value_changed.connect(
		func(value: float) -> void: bloom_material.set_shader_parameter("bloom_intensity", value)
	)
	%BloomRadius.value_changed.connect(
		func(value: float) -> void: bloom_material.set_shader_parameter("bloom_radius", value)
	)
	%BloomRadiusWide.value_changed.connect(
		func(value: float) -> void: bloom_material.set_shader_parameter("bloom_radius_wide", value)
	)
	%BloomIntensityWide.value_changed.connect(
		func(value: float) -> void: bloom_material.set_shader_parameter("bloom_intensity_wide", value)
	)
	%BloomFalloff.value_changed.connect(
		func(value: float) -> void: bloom_material.set_shader_parameter("bloom_falloff", value)
	)
	%Exposure.value_changed.connect(
		func(value: float) -> void: bloom_material.set_shader_parameter("exposure", value)
	)

	%FlickerSpeed.value_changed.connect(
		func(value: float) -> void: graph_view.flicker_speed = value
	)
	%FlickerAmount.value_changed.connect(
		func(value: float) -> void: graph_view.flicker_amount = value
	)
	%LineWidth.value_changed.connect(
		func(value: float) -> void: graph_view.line_width = value
	)
	%NodeSize.value_changed.connect(
		func(value: float) -> void: graph_view.node_size = value
	)
	%SparkleIntensity.value_changed.connect(
		func(value: float) -> void: graph_view.sparkle_intensity = value
	)
	%LineGlow.value_changed.connect(
		func(value: float) -> void: graph_view.line_glow = value
	)
	%ColorVariation.value_changed.connect(
		func(value: float) -> void: graph_view.color_variation = value
	)
	%ColorCycleSpeed.value_changed.connect(
		func(value: float) -> void: graph_view.color_cycle_speed = value
	)
	%DriftAmount.value_changed.connect(
		func(value: float) -> void: graph_view.drift_amount = value
	)
	%DriftSpeed.value_changed.connect(
		func(value: float) -> void: graph_view.drift_speed = value
	)
	%ZoomAmount.value_changed.connect(
		func(value: float) -> void: graph_view.zoom_amount = value
	)
	%ZoomSpeed.value_changed.connect(
		func(value: float) -> void: graph_view.zoom_speed = value
	)

	bloom_material.set_shader_parameter("bloom_threshold", %BloomThreshold.value)
	bloom_material.set_shader_parameter("bloom_intensity", %BloomIntensity.value)
	bloom_material.set_shader_parameter("bloom_radius", %BloomRadius.value)
	bloom_material.set_shader_parameter("bloom_radius_wide", %BloomRadiusWide.value)
	bloom_material.set_shader_parameter("bloom_intensity_wide", %BloomIntensityWide.value)
	bloom_material.set_shader_parameter("bloom_falloff", %BloomFalloff.value)
	bloom_material.set_shader_parameter("exposure", %Exposure.value)

	for _i in 90:
		_add_random_node()


func _process(delta: float) -> void:
	if auto_play:
		auto_play_elapsed += delta
		if auto_play_elapsed >= auto_play_interval:
			auto_play_elapsed = 0.0
			_add_random_node()
	_update_metrics()


func _add_random_node() -> void:
	var index := graph_view.nodes.size()
	var position := _spiral_position(index)
	var intensity := randf_range(0.55, 1.0)
	var mode: int = %ConnectMode.selected

	if mode == 2:
		var neighbors := _nearest_neighbors(position, index, 3)
		var primary := -1 if neighbors.is_empty() else neighbors[0]
		var new_index := graph_view.add_node(position, intensity, primary)
		for neighbor_index in range(1, neighbors.size()):
			graph_view.connect_nodes(new_index, neighbors[neighbor_index])
		last_index = new_index
		return

	var connect_to := last_index
	if mode == 1:
		connect_to = 0 if index > 0 else -1

	last_index = graph_view.add_node(position, intensity, connect_to)


func _nearest_neighbors(position: Vector2, exclude_index: int, count: int) -> Array[int]:
	var distances: Array[Vector2] = []
	for node_index in graph_view.nodes.size():
		if node_index == exclude_index:
			continue
		var distance := graph_view.nodes[node_index].position.distance_to(position)
		distances.append(Vector2(distance, node_index))
	distances.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)

	var result: Array[int] = []
	for i in mini(count, distances.size()):
		result.append(int(distances[i].y))
	return result


func _clear_graph() -> void:
	graph_view.clear_graph()
	last_index = -1


func _spiral_position(index: int) -> Vector2:
	var angle := float(index) * GOLDEN_ANGLE
	var radius := 0.05 + 0.05 * sqrt(float(index))
	radius = minf(radius, 0.46)
	return Vector2(0.5, 0.5) + Vector2(cos(angle), sin(angle)) * radius


func _update_metrics() -> void:
	%LocalMetrics.text = (
		"Nodes: %d\nConnections: %d\nAuto play: %s"
		% [
			graph_view.nodes.size(),
			graph_view.connections.size(),
			"On" if auto_play else "Off",
		]
	)
