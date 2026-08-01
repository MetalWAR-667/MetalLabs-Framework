class_name DynamicGraphView
extends Control

@export_range(0.5, 4.0, 0.1) var line_width := 1.6
@export_range(1.0, 14.0, 0.5) var node_size := 5.0
@export_range(0.0, 3.0, 0.05) var flicker_speed := 1.4
@export_range(0.0, 1.0, 0.05) var flicker_amount := 0.4
@export var graph_color := Color(0.62, 0.72, 0.92, 1.0)
@export_range(0.2, 3.0, 0.05) var reveal_duration := 0.9
@export_range(0.0, 3.0, 0.05) var sparkle_intensity := 1.2
@export_range(0.0, 3.0, 0.05) var line_glow := 1.0
@export_range(0.0, 1.0, 0.01) var color_variation := 0.6
@export_range(0.0, 2.0, 0.02) var color_cycle_speed := 0.25
@export_range(0.4, 1.0, 0.02) var color_saturation := 0.75
@export_range(0.0, 40.0, 1.0) var drift_amount := 14.0
@export_range(0.0, 1.0, 0.01) var drift_speed := 0.12
@export_range(0.0, 0.6, 0.01) var zoom_amount := 0.18
@export_range(0.0, 1.0, 0.01) var zoom_speed := 0.09

const SEGMENTS := 12

class DreamGraphNode:
	var position: Vector2
	var birth_time: float
	var intensity: float
	var reveal: float = 0.0
	var hue_phase: float

	func _init(p: Vector2, t: float, i: float) -> void:
		position = p
		birth_time = t
		intensity = i
		hue_phase = randf()

var nodes: Array[DreamGraphNode] = []
var connections: Array[Vector2i] = []
var elapsed_time := 0.0


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)


func _process(delta: float) -> void:
	elapsed_time += delta
	for node in nodes:
		if node.reveal < 1.0:
			node.reveal = clampf(node.reveal + delta / reveal_duration, 0.0, 1.0)
	queue_redraw()


func add_node(normalized_position: Vector2, intensity: float, connect_to: int = -1) -> int:
	var node := DreamGraphNode.new(normalized_position, elapsed_time, intensity)
	nodes.append(node)
	var new_index := nodes.size() - 1
	if connect_to >= 0 and connect_to < new_index:
		connections.append(Vector2i(connect_to, new_index))
	queue_redraw()
	return new_index


func connect_nodes(a: int, b: int) -> void:
	if a == b or a < 0 or b < 0 or a >= nodes.size() or b >= nodes.size():
		return
	connections.append(Vector2i(a, b))
	queue_redraw()


func clear_graph() -> void:
	nodes.clear()
	connections.clear()
	elapsed_time = 0.0
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0 or nodes.is_empty():
		return

	var screen_positions: Array[Vector2] = []
	screen_positions.resize(nodes.size())
	for index in nodes.size():
		screen_positions[index] = _screen_position(nodes[index], index)

	for connection in connections:
		_draw_connection(connection, screen_positions)
	for index in nodes.size():
		_draw_node(nodes[index], screen_positions[index])


func _screen_position(node: DreamGraphNode, index: int) -> Vector2:
	var base := node.position * size
	var phase := float(index) * 1.731 + node.hue_phase * TAU
	var drift := Vector2(
		sin(elapsed_time * drift_speed + phase),
		cos(elapsed_time * drift_speed * 0.83 + phase * 1.19)
	) * drift_amount

	var center := size * 0.5
	var zoom := 1.0 + sin(elapsed_time * zoom_speed) * zoom_amount
	return center + (base + drift - center) * zoom


func _cycled_color(hue_phase: float, position: Vector2) -> Color:
	var hue := fposmod(
		hue_phase
		+ elapsed_time * color_cycle_speed * 0.1
		+ position.x * color_variation * 0.3,
		1.0
	)
	return Color.from_hsv(hue, color_saturation * color_variation, 1.0)


func _draw_connection(connection: Vector2i, screen_positions: Array[Vector2]) -> void:
	var a := nodes[connection.x]
	var b := nodes[connection.y]
	var reveal := minf(a.reveal, b.reveal)
	if reveal <= 0.001:
		return

	var start := screen_positions[connection.x]
	var finish := screen_positions[connection.y]
	var midpoint := (start + finish) * 0.5
	var direction := finish - start
	var normal := Vector2(-direction.y, direction.x).normalized()
	var bend := minf(size.x, size.y) * 0.015
	var control := midpoint + normal * bend

	var points := PackedVector2Array()
	for segment in SEGMENTS + 1:
		var t := reveal * float(segment) / float(SEGMENTS)
		points.append(_quadratic_bezier(start, control, finish, t))

	var avg_intensity := (a.intensity + b.intensity) * 0.5
	var mid_normalized := (a.position + b.position) * 0.5
	var mid_hue_phase := (a.hue_phase + b.hue_phase) * 0.5
	var base_color := graph_color.lerp(
		_cycled_color(mid_hue_phase, mid_normalized), color_variation
	)
	var color := base_color * (1.0 + line_glow * 0.8)
	color.a = base_color.a * avg_intensity * reveal * 0.55
	draw_polyline(points, color, line_width, true)


func _draw_node(node: DreamGraphNode, position: Vector2) -> void:
	if node.reveal <= 0.001:
		return

	var age := elapsed_time - node.birth_time
	var flicker := sin(age * flicker_speed + node.birth_time * 12.9) * 0.5 + 0.5
	var pulse := (1.0 - flicker_amount) + flicker_amount * flicker
	var alpha := node.intensity * node.reveal

	var node_color := graph_color.lerp(
		_cycled_color(node.hue_phase, node.position), color_variation
	)

	var halo_color := node_color
	halo_color.a *= alpha * 0.30 * pulse
	draw_circle(position, node_size * 3.2 * pulse, halo_color)

	var core_color := Color.WHITE.lerp(node_color, 0.3)
	core_color.a = alpha * (0.65 + 0.35 * pulse)
	draw_circle(position, node_size * (0.8 + 0.3 * pulse), core_color)

	# Sparkle: núcleo pequeño y sobre-brillante (RGB > 1, requiere
	# SubViewport con use_hdr_2d) que alimenta al bloom con un punto
	# realmente caliente, al estilo de EXP-VFX-009.
	var sparkle_strength := sparkle_intensity * alpha * (0.6 + 0.4 * pulse)
	var sparkle_tint := Color.WHITE.lerp(node_color, color_variation * 0.5)
	var sparkle_color := Color(
		sparkle_tint.r + sparkle_strength * 2.2,
		sparkle_tint.g + sparkle_strength * 2.0,
		sparkle_tint.b + sparkle_strength * 2.6,
		1.0
	)
	draw_circle(position, node_size * 0.35, sparkle_color)


func _quadratic_bezier(start: Vector2, control: Vector2, finish: Vector2, t: float) -> Vector2:
	var inverse := 1.0 - t
	return inverse * inverse * start + 2.0 * inverse * t * control + t * t * finish
