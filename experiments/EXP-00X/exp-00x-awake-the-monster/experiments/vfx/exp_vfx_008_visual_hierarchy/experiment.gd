extends Node2D

const SCENARIOS: Array[Dictionary] = [
	{"name": "Solo Fog", "fog": true, "ink": false, "particles": false},
	{"name": "Solo Particles", "fog": false, "ink": false, "particles": true},
	{"name": "Solo Ink", "fog": false, "ink": true, "particles": false},
	{"name": "Fog + Particles", "fog": true, "ink": false, "particles": true},
	{"name": "Fog + Ink", "fog": true, "ink": true, "particles": false},
	{"name": "Ink + Particles", "fog": false, "ink": true, "particles": true},
	{"name": "Los tres simultáneamente", "fog": true, "ink": true, "particles": true},
]

const DRAW_ORDERS: Array[Dictionary] = [
	{"name": "Fog > Ink > Particles", "order": ["fog", "ink", "particles"]},
	{"name": "Fog > Particles > Ink", "order": ["fog", "particles", "ink"]},
	{"name": "Ink > Fog > Particles", "order": ["ink", "fog", "particles"]},
	{"name": "Ink > Particles > Fog", "order": ["ink", "particles", "fog"]},
	{"name": "Particles > Fog > Ink", "order": ["particles", "fog", "ink"]},
	{"name": "Particles > Ink > Fog", "order": ["particles", "ink", "fog"]},
]

@onready var fog_system: Node2D = $FogSystem
@onready var ink_system: Node2D = $InkSystem
@onready var particle_system: Node2D = $ParticleSystem


func _ready() -> void:
	$FogSystem/Controls.hide()
	$InkSystem/Controls.hide()
	$ParticleSystem/Controls.hide()
	$ParticleSystem/DarkBackground.hide()

	for scenario in SCENARIOS:
		%ScenarioSelector.add_item(scenario.name)
	for draw_order in DRAW_ORDERS:
		%OrderSelector.add_item(draw_order.name)

	%ScenarioSelector.item_selected.connect(_apply_scenario)
	%OrderSelector.item_selected.connect(_apply_draw_order)
	%FogEnabled.toggled.connect(func(value: bool) -> void: _set_visibility("fog", value))
	%InkEnabled.toggled.connect(func(value: bool) -> void: _set_visibility("ink", value))
	%ParticlesEnabled.toggled.connect(
		func(value: bool) -> void: _set_visibility("particles", value)
	)
	%FogOpacity.value_changed.connect(func(value: float) -> void: _set_opacity(fog_system, value))
	%InkOpacity.value_changed.connect(func(value: float) -> void: _set_opacity(ink_system, value))
	%ParticlesOpacity.value_changed.connect(
		func(value: float) -> void: _set_opacity(particle_system, value)
	)

	%FogOpacity.value = 1.0
	%InkOpacity.value = 1.0
	%ParticlesOpacity.value = 1.0
	_apply_draw_order(0)
	_apply_scenario(0)


func _apply_scenario(index: int) -> void:
	var scenario: Dictionary = SCENARIOS[index]
	%FogEnabled.set_pressed_no_signal(scenario.fog)
	%InkEnabled.set_pressed_no_signal(scenario.ink)
	%ParticlesEnabled.set_pressed_no_signal(scenario.particles)
	fog_system.visible = scenario.fog
	ink_system.visible = scenario.ink
	particle_system.visible = scenario.particles
	_update_active_combination()


func _apply_draw_order(index: int) -> void:
	var order: Array = DRAW_ORDERS[index].order
	for layer_index in order.size():
		_system(str(order[layer_index])).z_index = layer_index


func _set_visibility(system_id: String, visible: bool) -> void:
	_system(system_id).visible = visible
	_update_active_combination()


func _set_opacity(system: CanvasItem, opacity: float) -> void:
	var modulation := system.modulate
	modulation.a = opacity
	system.modulate = modulation


func _system(system_id: String) -> Node2D:
	match system_id:
		"fog":
			return fog_system
		"ink":
			return ink_system
		_:
			return particle_system


func _update_active_combination() -> void:
	var active: Array[String] = []
	if fog_system.visible:
		active.append("Fog")
	if ink_system.visible:
		active.append("Ink")
	if particle_system.visible:
		active.append("Particles")
	%ActiveCombination.text = (
		"Active combination: %s" % " + ".join(active)
		if not active.is_empty()
		else "Active combination: None"
	)
