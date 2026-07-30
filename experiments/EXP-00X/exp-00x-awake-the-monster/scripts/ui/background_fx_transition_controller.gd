class_name BackgroundFXTransitionController
extends Node

@export_range(0.0, 10.0, 0.1) var fade_duration := 1.5

@onready var atmospheric_layer: Control = %AtmosphericLayer
@onready var memory_layer: Control = %MemoryLayer

var active_tween: Tween


func show_atmosphere() -> void:
	_stop_active_transition()
	atmospheric_layer.modulate.a = 1.0
	memory_layer.modulate.a = 0.0


func show_memory() -> void:
	_stop_active_transition()
	atmospheric_layer.modulate.a = 0.0
	memory_layer.modulate.a = 1.0


func fade_to_atmosphere() -> void:
	_crossfade(1.0, 0.0)


func fade_to_memory() -> void:
	_crossfade(0.0, 1.0)


func _crossfade(atmosphere_alpha: float, memory_alpha: float) -> void:
	_stop_active_transition()
	if is_zero_approx(fade_duration):
		atmospheric_layer.modulate.a = atmosphere_alpha
		memory_layer.modulate.a = memory_alpha
		return

	active_tween = create_tween()
	active_tween.set_parallel(true)
	active_tween.set_trans(Tween.TRANS_SINE)
	active_tween.set_ease(Tween.EASE_IN_OUT)
	active_tween.tween_property(
		atmospheric_layer,
		"modulate:a",
		atmosphere_alpha,
		fade_duration
	)
	active_tween.tween_property(
		memory_layer,
		"modulate:a",
		memory_alpha,
		fade_duration
	)


func _stop_active_transition() -> void:
	if active_tween != null and active_tween.is_valid():
		active_tween.kill()
	active_tween = null
