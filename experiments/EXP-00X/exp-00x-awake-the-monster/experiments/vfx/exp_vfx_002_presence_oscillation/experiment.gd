extends Node2D

const TARGETS := {
	"opacity": {"shader_parameter": "opacity", "base": 0.62, "amplitude": 0.025, "period": 43.0, "phase": 0.0},
	"macro_influence": {"shader_parameter": "macro_influence", "base": 0.55, "amplitude": 0.04, "period": 61.0, "phase": 1.7},
	"macro_contrast": {"shader_parameter": "macro_contrast", "base": 1.0, "amplitude": 0.06, "period": 53.0, "phase": 3.1},
	"tint_brightness": {"shader_parameter": "fog_tint", "base": 1.0, "amplitude": 0.025, "period": 67.0, "phase": 4.4},
}

const BASE_TINT := Color(0.28, 0.36, 0.44, 1.0)

@onready var macro_experiment: Node = $BaseMacroDensity

var material_instance: ShaderMaterial
var elapsed_seconds := 0.0


func _ready() -> void:
	material_instance = macro_experiment.material_instance
	_connect_controls()
	_reset_defaults()


func _process(delta: float) -> void:
	elapsed_seconds += delta
	for target_id in TARGETS:
		_apply_target(target_id)


func _connect_controls() -> void:
	for target_id in TARGETS:
		var captured_id: String = target_id
		_control(captured_id, "Enabled").toggled.connect(
			func(_enabled: bool) -> void: _apply_target(captured_id)
		)
		for suffix in ["Base", "Amplitude", "Period", "Phase"]:
			var captured_suffix: String = suffix
			_control(captured_id, captured_suffix).value_changed.connect(
				func(_value: float) -> void: _apply_target(captured_id)
			)
	%ResetPresenceDefaults.pressed.connect(_reset_defaults)


func _reset_defaults() -> void:
	elapsed_seconds = 0.0
	for target_id in TARGETS:
		var defaults: Dictionary = TARGETS[target_id]
		_control(target_id, "Enabled").button_pressed = true
		_control(target_id, "Base").value = defaults.base
		_control(target_id, "Amplitude").value = defaults.amplitude
		_control(target_id, "Period").value = defaults.period
		_control(target_id, "Phase").value = defaults.phase
		_apply_target(target_id)


func _apply_target(target_id: String) -> void:
	if material_instance == null:
		return
	var base: float = _control(target_id, "Base").value
	var value := base
	if _control(target_id, "Enabled").button_pressed:
		var amplitude: float = _control(target_id, "Amplitude").value
		var period: float = maxf(_control(target_id, "Period").value, 0.1)
		var phase: float = _control(target_id, "Phase").value
		value += amplitude * sin((elapsed_seconds / period) * TAU + phase)

	if target_id == "tint_brightness":
		material_instance.set_shader_parameter(
			"fog_tint",
			Color(
				BASE_TINT.r * value,
				BASE_TINT.g * value,
				BASE_TINT.b * value,
				BASE_TINT.a
			)
		)
	else:
		material_instance.set_shader_parameter(
			TARGETS[target_id].shader_parameter,
			value
		)


func _control(target_id: String, suffix: String) -> Variant:
	return get_node("%%%s%s" % [target_id.to_pascal_case(), suffix])
