class_name DreamGraph
extends Control

@export_range(0.0, 1.0, 0.01) var progress := 0.0
@export_range(0.0, 1.0, 0.01) var graph_opacity := 0.18
@export_range(0.5, 4.0, 0.1) var line_width := 1.35
@export_range(1.0, 12.0, 0.5) var node_size := 3.5
@export var graph_color := Color(0.42, 0.50, 0.62, 1.0)
@export_range(0.0, 2.0, 0.05) var glow_intensity := 0.75
@export_range(0.0, 5.0, 0.1) var drift_amount := 2.0
@export_range(0.0, 1.0, 0.01) var drift_speed := 0.08
@export_range(0.8, 1.8, 0.05) var reveal_duration := 1.3
@export_range(0.0, 1.0, 0.05) var center_suppression := 0.72

const NODE_POSITIONS: Array[Vector2] = [
	Vector2(0.07, 0.17), Vector2(0.22, 0.09), Vector2(0.38, 0.19),
	Vector2(0.61, 0.11), Vector2(0.79, 0.18), Vector2(0.93, 0.08),
	Vector2(0.09, 0.43), Vector2(0.26, 0.34), Vector2(0.42, 0.44),
	Vector2(0.63, 0.35), Vector2(0.82, 0.43), Vector2(0.95, 0.33),
	Vector2(0.06, 0.74), Vector2(0.24, 0.63), Vector2(0.40, 0.80),
	Vector2(0.62, 0.69), Vector2(0.81, 0.78), Vector2(0.94, 0.63),
]
const NODE_ACTIVATION: Array[float] = [
	0.05, 0.12, 0.23, 0.38, 0.58, 0.78,
	0.10, 0.18, 0.30, 0.48, 0.68, 0.88,
	0.15, 0.27, 0.42, 0.60, 0.80, 0.96,
]
const CONNECTIONS: Array[Vector2i] = [
	Vector2i(0, 1), Vector2i(1, 2), Vector2i(2, 3),
	Vector2i(3, 4), Vector2i(4, 5),
	Vector2i(6, 7), Vector2i(7, 8), Vector2i(8, 9),
	Vector2i(9, 10), Vector2i(10, 11),
	Vector2i(12, 13), Vector2i(13, 14), Vector2i(14, 15),
	Vector2i(15, 16), Vector2i(16, 17),
	Vector2i(0, 6), Vector2i(1, 7), Vector2i(2, 8),
	Vector2i(9, 15), Vector2i(10, 16), Vector2i(11, 17),
]

var elapsed_time := 0.0
var state_tween: Tween


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	resized.connect(queue_redraw)
	queue_redraw()


func _process(delta: float) -> void:
	elapsed_time += delta
	if drift_amount > 0.0 and drift_speed > 0.0:
		queue_redraw()


func set_visual_state(
	target_progress: float,
	target_color: Color,
	target_opacity: float,
	animate := true
) -> void:
	if state_tween != null and state_tween.is_valid():
		state_tween.kill()
	state_tween = null

	if not animate or is_zero_approx(reveal_duration):
		_set_progress(target_progress)
		_set_graph_color(target_color)
		_set_graph_opacity(target_opacity)
		return

	state_tween = create_tween()
	state_tween.set_parallel(true)
	state_tween.set_trans(Tween.TRANS_SINE)
	state_tween.set_ease(Tween.EASE_IN_OUT)
	state_tween.tween_method(
		_set_progress,
		progress,
		clampf(target_progress, 0.0, 1.0),
		reveal_duration
	)
	state_tween.tween_method(
		_set_graph_color,
		graph_color,
		target_color,
		reveal_duration
	)
	state_tween.tween_method(
		_set_graph_opacity,
		graph_opacity,
		clampf(target_opacity, 0.0, 1.0),
		reveal_duration
	)


func set_graph_enabled(enabled: bool) -> void:
	visible = enabled
	set_process(enabled)


func _set_progress(value: float) -> void:
	progress = clampf(value, 0.0, 1.0)
	queue_redraw()


func _set_graph_color(value: Color) -> void:
	graph_color = value
	queue_redraw()


func _set_graph_opacity(value: float) -> void:
	graph_opacity = clampf(value, 0.0, 1.0)
	queue_redraw()


func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0 or graph_opacity <= 0.0:
		return

	var positions: Array[Vector2] = []
	positions.resize(NODE_POSITIONS.size())
	for node_index in NODE_POSITIONS.size():
		positions[node_index] = _node_position(node_index)

	for connection_index in CONNECTIONS.size():
		_draw_connection(connection_index, positions)

	for node_index in positions.size():
		_draw_node(node_index, positions[node_index])


func _draw_connection(index: int, positions: Array[Vector2]) -> void:
	var connection := CONNECTIONS[index]
	var activation := maxf(
		NODE_ACTIVATION[connection.x],
		NODE_ACTIVATION[connection.y]
	)
	var reveal := smoothstep(activation - 0.10, activation + 0.06, progress)
	if reveal <= 0.001:
		return

	var start := positions[connection.x]
	var finish := positions[connection.y]
	var midpoint := (start + finish) * 0.5
	var direction := finish - start
	var normal := Vector2(-direction.y, direction.x).normalized()
	var bend_sign := -1.0 if index % 2 == 0 else 1.0
	var bend := minf(size.x, size.y) * (0.007 + float(index % 3) * 0.002)
	var control := midpoint + normal * bend * bend_sign
	var points := PackedVector2Array()
	const SEGMENTS := 10
	for segment in SEGMENTS + 1:
		var t := reveal * float(segment) / float(SEGMENTS)
		points.append(_quadratic_bezier(start, control, finish, t))

	var center_factor := _center_visibility(midpoint / size)
	var color := graph_color
	color.a *= graph_opacity * center_factor * reveal * 0.62
	draw_polyline(points, color, line_width, true)


func _draw_node(index: int, position: Vector2) -> void:
	var reveal := smoothstep(
		NODE_ACTIVATION[index] - 0.06,
		NODE_ACTIVATION[index] + 0.04,
		progress
	)
	if reveal <= 0.001:
		return

	var center_factor := _center_visibility(position / size)
	var alpha := graph_opacity * center_factor * reveal
	var halo_color := graph_color
	halo_color.a *= alpha * 0.16 * glow_intensity
	draw_circle(position, node_size * 2.6, halo_color)

	var core_color := graph_color
	core_color.a *= alpha * 0.78
	draw_circle(position, node_size, core_color)


func _node_position(index: int) -> Vector2:
	var base := NODE_POSITIONS[index] * size
	var phase := float(index) * 1.731
	var drift := Vector2(
		sin(elapsed_time * drift_speed + phase),
		cos(elapsed_time * drift_speed * 0.83 + phase * 1.19)
	) * drift_amount
	return base + drift


func _center_visibility(normalized_position: Vector2) -> float:
	var centered := normalized_position - Vector2(0.5, 0.5)
	centered.x *= 1.22
	var edge_weight := smoothstep(0.17, 0.52, centered.length())
	return lerpf(1.0 - center_suppression, 1.0, edge_weight)


func _quadratic_bezier(
	start: Vector2,
	control: Vector2,
	finish: Vector2,
	t: float
) -> Vector2:
	var inverse := 1.0 - t
	return (
		inverse * inverse * start
		+ 2.0 * inverse * t * control
		+ t * t * finish
	)
