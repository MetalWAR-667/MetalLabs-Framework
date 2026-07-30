extends Node2D

const PROFILES: Array[Dictionary] = [
	{
		"name": "Calm", "fog": true, "ink": false, "particles": true,
		"fog_speed": Vector3(0.0008, 0.0025, 0.004), "fog_opacity": Vector3(0.18, 0.24, 0.06),
		"fog_contrast": Vector3(0.65, 0.90, 1.10), "fog_tint": Color(0.19, 0.25, 0.30),
		"ink_mix": 0.0, "ink_amount": 0.42, "ink_contrast": 1.3, "ink_spread": 0.02,
		"particle_amount": 25, "particle_behavior": 0, "particle_speed": 12.0,
		"particle_force": 8.0, "particle_radius": 330.0, "particle_rhythm": 0, "particle_scale": 0,
	},
	{
		"name": "Dream", "fog": true, "ink": true, "particles": true,
		"fog_speed": Vector3(0.0012, 0.004, 0.007), "fog_opacity": Vector3(0.30, 0.38, 0.11),
		"fog_contrast": Vector3(0.75, 1.10, 1.35), "fog_tint": Color(0.22, 0.27, 0.36),
		"ink_mix": 0.08, "ink_amount": 0.46, "ink_contrast": 1.45, "ink_spread": 0.035,
		"particle_amount": 50, "particle_behavior": 0, "particle_speed": 15.0,
		"particle_force": 8.0, "particle_radius": 380.0, "particle_rhythm": 3, "particle_scale": 0,
	},
	{
		"name": "Presence", "fog": true, "ink": false, "particles": true,
		"fog_speed": Vector3(0.0010, 0.0035, 0.006), "fog_opacity": Vector3(0.24, 0.34, 0.08),
		"fog_contrast": Vector3(0.70, 1.15, 1.30), "fog_tint": Color(0.18, 0.23, 0.29),
		"ink_mix": 0.0, "ink_amount": 0.45, "ink_contrast": 1.5, "ink_spread": 0.03,
		"particle_amount": 50, "particle_behavior": 1, "particle_speed": 17.0,
		"particle_force": 14.0, "particle_radius": 420.0, "particle_rhythm": 0, "particle_scale": 0,
	},
	{
		"name": "Corruption", "fog": true, "ink": true, "particles": true,
		"fog_speed": Vector3(0.0018, 0.006, 0.011), "fog_opacity": Vector3(0.34, 0.46, 0.16),
		"fog_contrast": Vector3(0.95, 1.45, 1.75), "fog_tint": Color(0.24, 0.24, 0.27),
		"ink_mix": 0.20, "ink_amount": 0.58, "ink_contrast": 2.0, "ink_spread": 0.065,
		"particle_amount": 50, "particle_behavior": 2, "particle_speed": 25.0,
		"particle_force": 22.0, "particle_radius": 360.0, "particle_rhythm": 1, "particle_scale": 0,
	},
	{
		"name": "Nightmare", "fog": true, "ink": true, "particles": true,
		"fog_speed": Vector3(0.0025, 0.009, 0.016), "fog_opacity": Vector3(0.42, 0.56, 0.22),
		"fog_contrast": Vector3(1.10, 1.75, 2.10), "fog_tint": Color(0.20, 0.18, 0.22),
		"ink_mix": 0.30, "ink_amount": 0.66, "ink_contrast": 2.35, "ink_spread": 0.09,
		"particle_amount": 50, "particle_behavior": 2, "particle_speed": 32.0,
		"particle_force": 28.0, "particle_radius": 470.0, "particle_rhythm": 3, "particle_scale": 1,
	},
]

@onready var fog_system: Node = $FogSystem
@onready var ink_system: Node = $InkSystem
@onready var particle_system: Node = $ParticleSystem
@onready var ink_effect: ColorRect = $InkSystem/InkEffect


func _ready() -> void:
	_hide_source_interfaces()
	for profile in PROFILES:
		%ProfileSelector.add_item(profile.name)
	%ProfileSelector.item_selected.connect(_apply_profile)
	%FogEnabled.toggled.connect(func(value: bool) -> void: fog_system.visible = value)
	%InkEnabled.toggled.connect(func(value: bool) -> void: ink_system.visible = value)
	%ParticlesEnabled.toggled.connect(func(value: bool) -> void: particle_system.visible = value)
	_apply_profile(0)


func _hide_source_interfaces() -> void:
	$FogSystem/Controls.hide()
	$InkSystem/Controls.hide()
	$ParticleSystem/Controls.hide()
	$ParticleSystem/DarkBackground.hide()


func _apply_profile(index: int) -> void:
	var profile: Dictionary = PROFILES[index]
	%ProfileSelector.select(index)
	%FogEnabled.set_pressed_no_signal(profile.fog)
	%InkEnabled.set_pressed_no_signal(profile.ink)
	%ParticlesEnabled.set_pressed_no_signal(profile.particles)
	fog_system.visible = profile.fog
	ink_system.visible = profile.ink
	particle_system.visible = profile.particles
	_apply_fog(profile)
	_apply_ink(profile)
	_apply_particles(profile)
	%ActiveProfile.text = "Active profile: %s" % profile.name


func _apply_fog(profile: Dictionary) -> void:
	var material: ShaderMaterial = fog_system.material_instance
	var speeds: Vector3 = profile.fog_speed
	var opacities: Vector3 = profile.fog_opacity
	var contrasts: Vector3 = profile.fog_contrast
	for layer_data in [
		["background", speeds.x, opacities.x, contrasts.x],
		["mid", speeds.y, opacities.y, contrasts.y],
		["foreground", speeds.z, opacities.z, contrasts.z],
	]:
		var layer: String = layer_data[0]
		material.set_shader_parameter("%s_speed" % layer, layer_data[1])
		material.set_shader_parameter("%s_opacity" % layer, layer_data[2])
		material.set_shader_parameter("%s_contrast" % layer, layer_data[3])
		material.set_shader_parameter("%s_tint" % layer, profile.fog_tint)


func _apply_ink(profile: Dictionary) -> void:
	var material: ShaderMaterial = ink_system.material_instance
	material.set_shader_parameter("observation_mode", 2)
	material.set_shader_parameter("ink_amount", profile.ink_amount)
	material.set_shader_parameter("ink_contrast", profile.ink_contrast)
	material.set_shader_parameter("spread", profile.ink_spread)
	ink_effect.modulate.a = profile.ink_mix


func _apply_particles(profile: Dictionary) -> void:
	particle_system._select_density(profile.particle_amount)
	particle_system.behavior_selector.select(profile.particle_behavior)
	particle_system.scale_selector.select(profile.particle_scale)
	particle_system.rhythm_selector.select(profile.particle_rhythm)
	particle_system.get_node("%MovementSpeed").value = profile.particle_speed
	particle_system.get_node("%ForceIntensity").value = profile.particle_force
	particle_system.get_node("%InfluenceRadius").value = profile.particle_radius
	particle_system.elapsed_seconds = 0.0
	particle_system.current_preset = profile.name
