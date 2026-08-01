extends Node2D

const GOLDEN_ANGLE := 2.399963
const MAX_NODES := 32
const MAX_CONNECTIONS := 64
const DEFAULT_NODE_COUNT := 18
const REVEAL_DURATION := 0.8

const PARAMETER_CONTROLS := {
	"NodeSize": "node_size",
	"NodeGlow": "node_glow",
	"LineWidth": "line_width",
	"LineGlow": "line_glow",
	"BreathAmount": "breath_amount",
	"BreathSpeed": "breath_speed",
	"Exposure": "exposure",
	"LensRadius": "lens_radius",
	"LensStrength": "lens_strength",
	"LensEdge": "lens_edge",
	"LensRefraction": "lens_refraction",
}

@onready var graph_material := %GraphRect.material as ShaderMaterial

var node_data: Array[Vector4] = []
var connection_data: Array[Vector4] = []
var node_reveals: Array[float] = []
var elapsed_time := 0.0


func _ready() -> void:
	%AddNodeButton.pressed.connect(_add_node)
	%ResetGraphButton.pressed.connect(_reset_graph)
	%EnableCosmicLens.toggled.connect(_set_lens_enabled)

	for control_name in PARAMETER_CONTROLS:
		var slider := get_node("%%%s" % control_name) as Range
		var shader_parameter := PARAMETER_CONTROLS[control_name] as String
		slider.value_changed.connect(
			func(value: float) -> void:
				graph_material.set_shader_parameter(shader_parameter, value)
		)
		graph_material.set_shader_parameter(shader_parameter, slider.value)

	_set_lens_enabled(%EnableCosmicLens.button_pressed)
	_reset_graph()


func _process(delta: float) -> void:
	elapsed_time += delta
	graph_material.set_shader_parameter("graph_time", elapsed_time)
	for index in node_reveals.size():
		node_reveals[index] = minf(node_reveals[index] + delta / REVEAL_DURATION, 1.0)
	_push_graph_data()


func _reset_graph() -> void:
	node_data.clear()
	connection_data.clear()
	node_reveals.clear()
	for _index in DEFAULT_NODE_COUNT:
		_add_node()
	for index in node_reveals.size():
		node_reveals[index] = 1.0


func _add_node() -> void:
	if node_data.size() >= MAX_NODES:
		return

	var index := node_data.size()
	var angle := float(index) * GOLDEN_ANGLE
	var radius := minf(0.055 + sqrt(float(index)) * 0.043, 0.39)
	var position := Vector2(0.5, 0.5) + Vector2(cos(angle), sin(angle)) * radius
	var phase := fposmod(sin(float(index + 1) * 91.345) * 47453.5453, 1.0)
	node_data.append(Vector4(position.x, position.y, 1.0, phase))
	node_reveals.append(0.0)

	if index > 0:
		var nearest := _nearest_node(position, index)
		var connection_phase := fposmod(phase + float(index) * 0.173, 1.0)
		connection_data.append(Vector4(float(nearest), float(index), 1.0, connection_phase))
	if index > 2 and connection_data.size() < MAX_CONNECTIONS:
		var secondary := maxi(0, index - 3)
		connection_data.append(Vector4(float(secondary), float(index), 1.0, fposmod(phase + 0.37, 1.0)))


func _nearest_node(position: Vector2, excluded_index: int) -> int:
	var nearest := 0
	var nearest_distance := INF
	for index in excluded_index:
		var other := Vector2(node_data[index].x, node_data[index].y)
		var distance := position.distance_squared_to(other)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = index
	return nearest


func _set_lens_enabled(enabled: bool) -> void:
	graph_material.set_shader_parameter("enable_cosmic_lens", enabled)
	for control_name in ["LensRadius", "LensStrength", "LensEdge", "LensRefraction"]:
		(get_node("%%%s" % control_name) as Range).editable = enabled


func _push_graph_data() -> void:
	var packed_nodes: Array = []
	packed_nodes.resize(MAX_NODES)
	for index in MAX_NODES:
		if index < node_data.size():
			var node := node_data[index]
			packed_nodes[index] = Vector4(node.x, node.y, node.z * node_reveals[index], node.w)
		else:
			packed_nodes[index] = Vector4.ZERO

	var packed_connections: Array = []
	packed_connections.resize(MAX_CONNECTIONS)
	for index in MAX_CONNECTIONS:
		if index < connection_data.size():
			var connection := connection_data[index]
			var reveal := minf(node_reveals[int(connection.x)], node_reveals[int(connection.y)])
			packed_connections[index] = Vector4(connection.x, connection.y, reveal, connection.w)
		else:
			packed_connections[index] = Vector4.ZERO

	graph_material.set_shader_parameter("node_count", node_data.size())
	graph_material.set_shader_parameter("node_data", packed_nodes)
	graph_material.set_shader_parameter("connection_count", connection_data.size())
	graph_material.set_shader_parameter("connection_data", packed_connections)
	%LocalMetrics.text = "Nodes: %d / %d\nConnections: %d / %d\nLens: %s" % [
		node_data.size(), MAX_NODES,
		connection_data.size(), MAX_CONNECTIONS,
		"On" if %EnableCosmicLens.button_pressed else "Off",
	]
