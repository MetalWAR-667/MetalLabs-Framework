class_name BackgroundFX
extends Control

const CARD_01_ID := "card_01_awaken"
const CARD_02_ID := "card_02_descent"
const CARD_03_ID := "card_03_threshold"
const CARD_04_ID := "card_04_stalker"
const CARD_05_ID := "card_05_refuge"
const CARD_06_ID := "card_06_icnophage"

@export_range(0.0, 6.0, 0.1) var composition_transition_duration := 2.2
@export_range(0.1, 1.0, 0.05) var success_feedback_duration := 0.4
@export_range(0.4, 2.0, 0.05) var failure_feedback_duration := 1.2

@onready var fog_rect: ColorRect = %FogRect
@onready var dream_graph: DreamGraph = %DreamGraph
@onready var transition_controller: BackgroundFXTransitionController = %TransitionController

var fog_material: ShaderMaterial
var composition_tween: Tween
var feedback_tween: Tween
var current_composition: Dictionary = {}
var previous_random_composition: Dictionary = {}
var random := RandomNumberGenerator.new()


func _ready() -> void:
	fog_material = fog_rect.material.duplicate() as ShaderMaterial
	fog_rect.material = fog_material
	random.randomize()
	current_composition = _calm_composition()
	_apply_composition(current_composition)


func set_card(card_identifier: String, animate_graph := true) -> void:
	var target_composition: Dictionary
	if card_identifier.contains(CARD_02_ID):
		target_composition = _vortex_composition()
	elif card_identifier.contains(CARD_01_ID):
		target_composition = _calm_composition()
	else:
		target_composition = _random_composition()
	_transition_to_composition(target_composition)

	var graph_state := _graph_state_for_card(card_identifier)
	dream_graph.set_visual_state(
		graph_state.progress,
		graph_state.color,
		graph_state.intensity,
		animate_graph
	)


func _graph_state_for_card(card_identifier: String) -> Dictionary:
	if card_identifier.contains(CARD_06_ID):
		return {
			"progress": 1.00,
			"color": Color(0.68, 0.70, 0.82, 1.0),
			"intensity": 0.50,
		}
	if card_identifier.contains(CARD_05_ID):
		return {
			"progress": 0.82,
			"color": Color(0.48, 0.17, 0.21, 1.0),
			"intensity": 0.42,
		}
	if card_identifier.contains(CARD_04_ID):
		return {
			"progress": 0.65,
			"color": Color(0.58, 0.45, 0.28, 1.0),
			"intensity": 0.36,
		}
	if card_identifier.contains(CARD_03_ID):
		return {
			"progress": 0.45,
			"color": Color(0.68, 0.65, 0.56, 1.0),
			"intensity": 0.30,
		}
	if card_identifier.contains(CARD_02_ID):
		return {
			"progress": 0.30,
			"color": Color(0.31, 0.28, 0.50, 1.0),
			"intensity": 0.24,
		}
	return {
		"progress": 0.15,
		"color": Color(0.38, 0.45, 0.55, 1.0),
		"intensity": 0.18,
	}


func show_atmosphere() -> void:
	transition_controller.show_atmosphere()


func show_memory() -> void:
	transition_controller.show_memory()


func fade_to_atmosphere() -> void:
	transition_controller.fade_to_atmosphere()


func fade_to_memory() -> void:
	transition_controller.fade_to_memory()


func play_success_feedback() -> void:
	var tween := start_success_feedback()
	await tween.finished


func start_success_feedback() -> Tween:
	_stop_feedback()
	var duration := success_feedback_duration
	feedback_tween = create_tween()
	feedback_tween.set_trans(Tween.TRANS_SINE)
	feedback_tween.set_ease(Tween.EASE_OUT)
	feedback_tween.tween_method(
		_set_success_feedback,
		0.0,
		1.0,
		duration * 0.15
	)
	feedback_tween.tween_method(
		_set_success_feedback,
		1.0,
		0.25,
		duration * 0.30
	)
	feedback_tween.tween_method(
		_set_success_feedback,
		0.25,
		0.52,
		duration * 0.15
	)
	feedback_tween.tween_method(
		_set_success_feedback,
		0.52,
		0.0,
		duration * 0.40
	)
	feedback_tween.tween_callback(_reset_feedback)
	return feedback_tween


func play_failure_feedback() -> void:
	var tween := start_failure_feedback()
	await tween.finished


func start_failure_feedback() -> Tween:
	_stop_feedback()
	var duration := failure_feedback_duration
	feedback_tween = create_tween()
	feedback_tween.set_trans(Tween.TRANS_SINE)
	feedback_tween.set_ease(Tween.EASE_IN_OUT)
	feedback_tween.tween_method(
		_set_failure_feedback,
		0.0,
		1.0,
		duration * 0.27
	)
	feedback_tween.tween_method(
		_set_failure_feedback,
		1.0,
		0.52,
		duration * 0.23
	)
	feedback_tween.tween_method(
		_set_failure_feedback,
		0.52,
		0.70,
		duration * 0.15
	)
	feedback_tween.tween_method(
		_set_failure_feedback,
		0.70,
		0.0,
		duration * 0.35
	)
	feedback_tween.tween_callback(_reset_feedback)
	return feedback_tween


func _set_success_feedback(intensity: float) -> void:
	fog_material.set_shader_parameter("success_flash", intensity)
	fog_material.set_shader_parameter(
		"feedback_distortion",
		intensity * 0.32
	)


func _set_failure_feedback(intensity: float) -> void:
	fog_material.set_shader_parameter("failure_pulse", intensity)
	fog_material.set_shader_parameter(
		"feedback_distortion",
		intensity * 0.52
	)


func _stop_feedback() -> void:
	if feedback_tween != null and feedback_tween.is_valid():
		feedback_tween.kill()
	feedback_tween = null
	_reset_feedback()


func _reset_feedback() -> void:
	fog_material.set_shader_parameter("success_flash", 0.0)
	fog_material.set_shader_parameter("failure_pulse", 0.0)
	fog_material.set_shader_parameter("feedback_distortion", 0.0)


func _calm_composition() -> Dictionary:
	return {
		"background_scale": 0.38,
		"background_speed": 0.0011,
		"background_direction": Vector2(0.62, 0.18),
		"background_opacity": 0.34,
		"background_contrast": 0.72,
		"background_tint": Color(0.14, 0.18, 0.25, 1.0),
		"mid_scale": 1.05,
		"mid_speed": 0.0042,
		"mid_direction": Vector2(-0.28, 0.68),
		"mid_opacity": 0.36,
		"mid_contrast": 1.05,
		"mid_tint": Color(0.19, 0.23, 0.31, 1.0),
		"foreground_scale": 2.2,
		"foreground_speed": 0.008,
		"foreground_direction": Vector2(0.72, -0.18),
		"foreground_opacity": 0.10,
		"foreground_contrast": 1.35,
		"foreground_tint": Color(0.26, 0.29, 0.34, 1.0),
		"void_color": Color(0.010, 0.014, 0.026, 1.0),
		"field_center": Vector2(0.5, 0.5),
		"field_radius": 0.72,
		"field_strength": 0.055,
		"field_falloff": 0.52,
		"temporal_drift": 0.10,
		"background_field_influence": 0.16,
		"mid_field_influence": 0.48,
		"foreground_field_influence": 0.22,
	}


func _vortex_composition() -> Dictionary:
	return {
		"background_scale": 0.48,
		"background_speed": 0.0024,
		"background_direction": Vector2(0.48, 0.30),
		"background_opacity": 0.44,
		"background_contrast": 0.86,
		"background_tint": Color(0.12, 0.17, 0.25, 1.0),
		"mid_scale": 1.32,
		"mid_speed": 0.008,
		"mid_direction": Vector2(-0.42, 0.76),
		"mid_opacity": 0.52,
		"mid_contrast": 1.35,
		"mid_tint": Color(0.18, 0.24, 0.34, 1.0),
		"foreground_scale": 2.65,
		"foreground_speed": 0.014,
		"foreground_direction": Vector2(0.76, -0.34),
		"foreground_opacity": 0.17,
		"foreground_contrast": 1.62,
		"foreground_tint": Color(0.28, 0.31, 0.37, 1.0),
		"void_color": Color(0.008, 0.012, 0.024, 1.0),
		"field_center": Vector2(0.5, 0.5),
		"field_radius": 0.74,
		"field_strength": 0.34,
		"field_falloff": 0.46,
		"temporal_drift": 0.14,
		"background_field_influence": 0.30,
		"mid_field_influence": 1.0,
		"foreground_field_influence": 0.48,
	}


func _random_composition() -> Dictionary:
	var candidate: Dictionary
	for attempt in range(5):
		candidate = _build_random_composition()
		if (
			previous_random_composition.is_empty()
			or _composition_difference(
				candidate,
				previous_random_composition
			) >= 0.32
		):
			break
	previous_random_composition = candidate.duplicate(true)
	return candidate


func _build_random_composition() -> Dictionary:
	var background_angle := random.randf_range(-PI, PI)
	var mid_angle := background_angle + random.randf_range(1.2, 2.6)
	var foreground_angle := mid_angle + random.randf_range(1.0, 2.2)
	var palette_shift := random.randf_range(-0.025, 0.025)

	return {
		"background_scale": random.randf_range(0.34, 0.58),
		"background_speed": random.randf_range(0.0010, 0.0030),
		"background_direction": Vector2.from_angle(background_angle),
		"background_opacity": random.randf_range(0.30, 0.48),
		"background_contrast": random.randf_range(0.68, 0.95),
		"background_tint": Color(
			0.14 + palette_shift,
			0.18 + palette_shift,
			0.27 + palette_shift,
			1.0
		),
		"mid_scale": random.randf_range(0.95, 1.48),
		"mid_speed": random.randf_range(0.0045, 0.0090),
		"mid_direction": Vector2.from_angle(mid_angle),
		"mid_opacity": random.randf_range(0.34, 0.54),
		"mid_contrast": random.randf_range(1.0, 1.48),
		"mid_tint": Color(
			0.19 + palette_shift,
			0.24 + palette_shift,
			0.34 + palette_shift,
			1.0
		),
		"foreground_scale": random.randf_range(2.0, 3.0),
		"foreground_speed": random.randf_range(0.009, 0.016),
		"foreground_direction": Vector2.from_angle(foreground_angle),
		"foreground_opacity": random.randf_range(0.08, 0.18),
		"foreground_contrast": random.randf_range(1.30, 1.75),
		"foreground_tint": Color(
			0.26 + palette_shift,
			0.30 + palette_shift,
			0.38 + palette_shift,
			1.0
		),
		"void_color": Color(0.008, 0.012, 0.025, 1.0),
		"field_center": Vector2(0.5, 0.5),
		"field_radius": random.randf_range(0.48, 0.82),
		"field_strength": random.randf_range(-0.24, 0.28),
		"field_falloff": random.randf_range(0.28, 0.56),
		"temporal_drift": random.randf_range(0.08, 0.22),
		"background_field_influence": random.randf_range(0.12, 0.34),
		"mid_field_influence": random.randf_range(0.62, 1.0),
		"foreground_field_influence": random.randf_range(0.24, 0.52),
	}


func _composition_difference(a: Dictionary, b: Dictionary) -> float:
	var center_distance: float = (
		(a.field_center as Vector2).distance_to(b.field_center)
	)
	var strength_distance: float = absf(
		a.field_strength - b.field_strength
	)
	var scale_distance: float = absf(a.mid_scale - b.mid_scale)
	return center_distance + strength_distance + scale_distance * 0.25


func _transition_to_composition(target: Dictionary) -> void:
	if composition_tween != null and composition_tween.is_valid():
		composition_tween.kill()

	if current_composition.is_empty() or is_zero_approx(
		composition_transition_duration
	):
		current_composition = target.duplicate(true)
		_apply_composition(current_composition)
		return

	var start := current_composition.duplicate(true)
	var destination := target.duplicate(true)
	composition_tween = create_tween()
	composition_tween.set_trans(Tween.TRANS_SINE)
	composition_tween.set_ease(Tween.EASE_IN_OUT)
	composition_tween.tween_method(
		_interpolate_composition.bind(start, destination),
		0.0,
		1.0,
		composition_transition_duration
	)


func _interpolate_composition(
	weight: float,
	start: Dictionary,
	target: Dictionary
) -> void:
	for parameter: String in target:
		var from_value: Variant = start[parameter]
		var to_value: Variant = target[parameter]
		var value: Variant
		if from_value is Vector2:
			value = (from_value as Vector2).lerp(to_value, weight)
		elif from_value is Color:
			value = (from_value as Color).lerp(to_value, weight)
		else:
			value = lerpf(float(from_value), float(to_value), weight)
		current_composition[parameter] = value
		fog_material.set_shader_parameter(parameter, value)


func _apply_composition(composition: Dictionary) -> void:
	for parameter: String in composition:
		fog_material.set_shader_parameter(
			parameter,
			composition[parameter]
		)
