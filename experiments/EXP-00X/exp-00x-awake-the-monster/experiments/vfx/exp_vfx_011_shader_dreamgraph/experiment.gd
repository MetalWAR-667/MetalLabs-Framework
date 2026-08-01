extends Node2D

const GOLDEN_ANGLE := 2.399963
const MAX_NODES := 64
const MAX_CONNECTIONS := 128
const NEIGHBORS_PER_NODE := 2

const CONTROL_PARAMETERS := {
	"SparkleRadius": "sparkle_radius",
	"SparkleIntensity": "sparkle_intensity",
	"LineWidth": "line_width",
	"LineIntensity": "line_intensity",
	"Saturation": "saturation",
	"ColorCycleSpeed": "color_cycle_speed",
	"DriftAmount": "drift_amount",
	"DriftSpeed": "drift_speed",
	"ZoomAmount": "zoom_amount",
	"ZoomSpeed": "zoom_speed",
	"Exposure": "exposure",
}

@onready var glow_rect: ColorRect = %GlowRect
@onready var glow_material: ShaderMaterial = glow_rect.material as ShaderMaterial

class DreamGraphNode:
	var position: Vector2
	var intensity: float
	var reveal: float = 0.0
	var hue_phase: float

	func _init(p: Vector2, i: float) -> void:
		position = p
		intensity = i
		hue_phase = randf()

var nodes: Array[DreamGraphNode] = []
var connections: Array[Vector2i] = []

var elapsed_time := 0.0
var reveal_duration := 0.9
var auto_play := false
var auto_play_interval := 1.4
var auto_play_elapsed := 0.0


func _ready() -> void:
	%AddNodeButton.pressed.connect(_add_random_node)
	%ClearButton.pressed.connect(_clear_graph)
	%AutoPlay.toggled.connect(func(value: bool) -> void: auto_play = value)

	for control_name in CONTROL_PARAMETERS:
		var control: Range = get_node("%%%s" % control_name)
		var parameter: String = CONTROL_PARAMETERS[control_name]
		control.value_changed.connect(
			func(value: float) -> void: glow_material.set_shader_parameter(parameter, value)
		)
		glow_material.set_shader_parameter(parameter, control.value)

	for _i in 30:
		_add_random_node()


func _process(delta: float) -> void:
	elapsed_time += delta
	glow_material.set_shader_parameter("time", elapsed_time)

	if auto_play and nodes.size() < MAX_NODES:
		auto_play_elapsed += delta
		if auto_play_elapsed >= auto_play_interval:
			auto_play_elapsed = 0.0
			_add_random_node()

	for node in nodes:
		if node.reveal < 1.0:
			node.reveal = clampf(node.reveal + delta / reveal_duration, 0.0, 1.0)

	_push_graph_data()
	_update_metrics()


func _add_random_node() -> void:
	if nodes.size() >= MAX_NODES:
		return

	var index := nodes.size()
	var position := _spiral_position(index)
	var intensity := randf_range(0.55, 1.0)
	nodes.append(DreamGraphNode.new(position, intensity))

	for neighbor_index in _nearest_neighbors(position, index, NEIGHBORS_PER_NODE):
		if connections.size() < MAX_CONNECTIONS:
			connections.append(Vector2i(neighbor_index, index))


func _nearest_neighbors(position: Vector2, exclude_index: int, count: int) -> Array[int]:
	var distances: Array[Vector2] = []
	for node_index in nodes.size():
		if node_index == exclude_index:
			continue
		var distance := nodes[node_index].position.distance_to(position)
		distances.append(Vector2(distance, node_index))
	distances.sort_custom(func(a: Vector2, b: Vector2) -> bool: return a.x < b.x)

	var result: Array[int] = []
	for i in mini(count, distances.size()):
		result.append(int(distances[i].y))
	return result


func _clear_graph() -> void:
	nodes.clear()
	connections.clear()


func _spiral_position(index: int) -> Vector2:
	var angle := float(index) * GOLDEN_ANGLE
	var radius := 0.05 + 0.05 * sqrt(float(index))
	radius = minf(radius, 0.46)
	return Vector2(0.5, 0.5) + Vector2(cos(angle), sin(angle)) * radius


func _push_graph_data() -> void:
	var node_count := mini(nodes.size(), MAX_NODES)
	var packed_nodes: Array = []
	packed_nodes.resize(MAX_NODES)
	for i in node_count:
		var node := nodes[i]
		packed_nodes[i] = Vector4(node.position.x, node.position.y, node.intensity * node.reveal, node.hue_phase)
	for i in range(node_count, MAX_NODES):
		packed_nodes[i] = Vector4(0.0, 0.0, 0.0, 0.0)
	glow_material.set_shader_parameter("node_count", node_count)
	glow_material.set_shader_parameter("node_data", packed_nodes)

	var connection_count := mini(connections.size(), MAX_CONNECTIONS)
	var packed_connections: Array = []
	packed_connections.resize(MAX_CONNECTIONS)
	for i in connection_count:
		var connection := connections[i]
		var reveal := minf(nodes[connection.x].reveal, nodes[connection.y].reveal)
		packed_connections[i] = Vector4(float(connection.x), float(connection.y), reveal, 0.0)
	for i in range(connection_count, MAX_CONNECTIONS):
		packed_connections[i] = Vector4(0.0, 0.0, 0.0, 0.0)
	glow_material.set_shader_parameter("connection_count", connection_count)
	glow_material.set_shader_parameter("connection_data", packed_connections)


func _update_metrics() -> void:
	%LocalMetrics.text = (
		"Nodes: %d / %d\nConnections: %d / %d\nAuto play: %s"
		% [
			nodes.size(), MAX_NODES,
			connections.size(), MAX_CONNECTIONS,
			"On" if auto_play else "Off",
		]
	)
