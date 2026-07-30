extends Node2D

enum Behavior { DRIFT, ATTRACTION, REPULSION }
enum Rhythm { CONSTANT, SOFT_PULSES, LONG_PAUSES, SLOW_BREATHING }
enum ParticleScale { SMALL, MEDIUM }

const MAX_PARTICLES := 100
const BOUNDS := Vector2(1920.0, 1080.0)
const FOCUS_POINT := Vector2(900.0, 540.0)

const PRESETS: Array[Dictionary] = [
	{"name": "Baseline", "amount": 25, "behavior": Behavior.DRIFT, "speed": 24.0, "force": 12.0, "radius": 330.0, "scale": ParticleScale.SMALL, "rhythm": Rhythm.CONSTANT, "pulse": 4.0, "pause": 4.0},
	{"name": "Sparse Drift", "amount": 10, "behavior": Behavior.DRIFT, "speed": 12.0, "force": 8.0, "radius": 330.0, "scale": ParticleScale.SMALL, "rhythm": Rhythm.CONSTANT, "pulse": 5.0, "pause": 5.0},
	{"name": "Dense Drift", "amount": 100, "behavior": Behavior.DRIFT, "speed": 16.0, "force": 8.0, "radius": 330.0, "scale": ParticleScale.SMALL, "rhythm": Rhythm.CONSTANT, "pulse": 5.0, "pause": 5.0},
	{"name": "Attraction", "amount": 50, "behavior": Behavior.ATTRACTION, "speed": 22.0, "force": 16.0, "radius": 430.0, "scale": ParticleScale.SMALL, "rhythm": Rhythm.CONSTANT, "pulse": 5.0, "pause": 5.0},
	{"name": "Repulsion", "amount": 50, "behavior": Behavior.REPULSION, "speed": 22.0, "force": 20.0, "radius": 360.0, "scale": ParticleScale.SMALL, "rhythm": Rhythm.CONSTANT, "pulse": 5.0, "pause": 5.0},
	{"name": "Pulse", "amount": 25, "behavior": Behavior.DRIFT, "speed": 18.0, "force": 8.0, "radius": 330.0, "scale": ParticleScale.MEDIUM, "rhythm": Rhythm.SOFT_PULSES, "pulse": 4.0, "pause": 5.0},
]

@onready var preset_selector: OptionButton = %PresetSelector
@onready var density_selector: OptionButton = %DensitySelector
@onready var behavior_selector: OptionButton = %BehaviorSelector
@onready var scale_selector: OptionButton = %ScaleSelector
@onready var rhythm_selector: OptionButton = %RhythmSelector

var positions := PackedVector2Array()
var velocities := PackedVector2Array()
var particle_phases := PackedFloat32Array()
var elapsed_seconds := 0.0
var active_particles := 0
var population_alpha := 1.0
var current_preset := "Baseline"
var random := RandomNumberGenerator.new()


func _ready() -> void:
	random.seed = 6006
	_create_population()
	_populate_controls()
	_connect_controls()
	_apply_preset(0)


func _process(delta: float) -> void:
	elapsed_seconds += delta
	_update_rhythm()
	_update_population(delta)
	_update_metrics()
	queue_redraw()


func _draw() -> void:
	var radius := 3.0 if scale_selector.selected == ParticleScale.SMALL else 7.0
	var particle_color := Color(0.78, 0.80, 0.82, 0.68 * population_alpha)
	for index in active_particles:
		draw_circle(positions[index], radius, particle_color)

	if %ShowInfluenceZone.button_pressed:
		draw_arc(FOCUS_POINT, %InfluenceRadius.value, 0.0, TAU, 96, Color(0.55, 0.60, 0.66, 0.38), 2.0)
		draw_circle(FOCUS_POINT, 5.0, Color(0.75, 0.78, 0.82, 0.65))


func _create_population() -> void:
	for index in MAX_PARTICLES:
		positions.append(Vector2(
			random.randf_range(0.0, BOUNDS.x),
			random.randf_range(0.0, BOUNDS.y)
		))
		var angle := random.randf_range(0.0, TAU)
		velocities.append(Vector2.from_angle(angle))
		particle_phases.append(random.randf_range(0.0, TAU))


func _populate_controls() -> void:
	for preset in PRESETS:
		preset_selector.add_item(preset.name)
	for amount in [10, 25, 50, 100]:
		density_selector.add_item(str(amount))
		density_selector.set_item_metadata(density_selector.item_count - 1, amount)
	for label in ["Drift", "Attraction", "Repulsion"]:
		behavior_selector.add_item(label)
	for label in ["Small", "Medium"]:
		scale_selector.add_item(label)
	for label in ["Constant", "Soft Pulses", "Long Pauses", "Slow Breathing"]:
		rhythm_selector.add_item(label)


func _connect_controls() -> void:
	preset_selector.item_selected.connect(_apply_preset)
	density_selector.item_selected.connect(func(_index: int) -> void: _mark_custom())
	behavior_selector.item_selected.connect(func(_index: int) -> void: _mark_custom())
	scale_selector.item_selected.connect(func(_index: int) -> void: _mark_custom())
	rhythm_selector.item_selected.connect(func(_index: int) -> void: _mark_custom())
	for control in [%MovementSpeed, %ForceIntensity, %InfluenceRadius, %PulseDuration, %PauseDuration]:
		control.value_changed.connect(func(_value: float) -> void: _mark_custom())


func _apply_preset(index: int) -> void:
	var preset: Dictionary = PRESETS[index]
	_select_density(preset.amount)
	behavior_selector.select(preset.behavior)
	%MovementSpeed.value = preset.speed
	%ForceIntensity.value = preset.force
	%InfluenceRadius.value = preset.radius
	scale_selector.select(preset.scale)
	rhythm_selector.select(preset.rhythm)
	%PulseDuration.value = preset.pulse
	%PauseDuration.value = preset.pause
	elapsed_seconds = 0.0
	current_preset = preset.name


func _select_density(amount: int) -> void:
	for index in density_selector.item_count:
		if int(density_selector.get_item_metadata(index)) == amount:
			density_selector.select(index)
			return


func _mark_custom() -> void:
	current_preset = "Custom"


func _update_population(delta: float) -> void:
	var behavior := behavior_selector.selected
	var target_speed: float = %MovementSpeed.value
	var force_strength: float = %ForceIntensity.value
	var influence_radius: float = maxf(%InfluenceRadius.value, 1.0)
	var amount := int(density_selector.get_item_metadata(density_selector.selected))

	for index in amount:
		var position := positions[index]
		var velocity := velocities[index]
		var slow_turn := sin(elapsed_seconds * 0.17 + particle_phases[index]) * 0.16
		velocity = velocity.rotated(slow_turn * delta)

		if behavior != Behavior.DRIFT:
			var offset := FOCUS_POINT - position
			var distance := offset.length()
			if distance < influence_radius and distance > 0.001:
				var influence := 1.0 - distance / influence_radius
				var direction := offset / distance
				if behavior == Behavior.REPULSION:
					direction = -direction
				velocity += direction * force_strength * influence * delta / maxf(target_speed, 1.0)

		velocity = velocity.normalized()
		position += velocity * target_speed * delta
		position.x = fposmod(position.x, BOUNDS.x)
		position.y = fposmod(position.y, BOUNDS.y)
		positions[index] = position
		velocities[index] = velocity


func _update_rhythm() -> void:
	var amount := int(density_selector.get_item_metadata(density_selector.selected))
	var pulse_duration: float = maxf(%PulseDuration.value, 0.1)
	var pause_duration: float = maxf(%PauseDuration.value, 0.0)

	match rhythm_selector.selected:
		Rhythm.CONSTANT:
			population_alpha = 1.0
		Rhythm.SOFT_PULSES:
			var cycle := pulse_duration + pause_duration
			var phase := fmod(elapsed_seconds, cycle)
			population_alpha = sin(PI * phase / pulse_duration) ** 2.0 if phase < pulse_duration else 0.0
		Rhythm.LONG_PAUSES:
			var cycle := pulse_duration + pause_duration
			var phase := fmod(elapsed_seconds, cycle)
			var fade := minf(pulse_duration * 0.2, 0.8)
			if phase < pulse_duration:
				population_alpha = minf(
					minf(phase / fade, (pulse_duration - phase) / fade),
					1.0
				)
			else:
				population_alpha = 0.0
		Rhythm.SLOW_BREATHING:
			var period := pulse_duration + pause_duration
			population_alpha = 0.35 + 0.65 * (sin(elapsed_seconds * TAU / period) * 0.5 + 0.5)

	active_particles = int(round(amount * population_alpha))


func _update_metrics() -> void:
	%LocalMetrics.text = (
		"Active particles: %d / %d\nBehavior: %s\nRhythm: %s\nPreset: %s"
		% [
			active_particles,
			int(density_selector.get_item_metadata(density_selector.selected)),
			behavior_selector.get_item_text(behavior_selector.selected),
			rhythm_selector.get_item_text(rhythm_selector.selected),
			current_preset,
		]
	)
