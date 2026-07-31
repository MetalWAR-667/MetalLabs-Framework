class_name ActorDice
extends Node2D

const ATTENTION_TEXTURE := preload("res://Assets/ui/symbols/attention_icon.png")
const SANITY_TEXTURE := preload("res://Assets/ui/symbols/sanity_icon.png")
const STRENGTH_TEXTURE := preload("res://Assets/ui/symbols/strength_icon.png")
const ROLL_SOUNDS: Array[AudioStream] = [
	preload("res://Assets/sounds/dice_rolls/floor/d6/d6_floor_1.mp3"),
	preload("res://Assets/sounds/dice_rolls/floor/d6/d6_floor_2.mp3"),
	preload("res://Assets/sounds/dice_rolls/floor/d6/d6_floor_3.mp3"),
	preload("res://Assets/sounds/dice_rolls/floor/d6/d6_floor_4.mp3"),
]
const SHUFFLE_OPEN_SOUNDS: Array[AudioStream] = [
	preload("res://Assets/sounds/dice_rolls/shuffle/shuffle_open_1.mp3"),
	preload("res://Assets/sounds/dice_rolls/shuffle/shuffle_open_2.mp3"),
	preload("res://Assets/sounds/dice_rolls/shuffle/shuffle_open_3.mp3"),
	preload("res://Assets/sounds/dice_rolls/shuffle/shuffle_open_4.mp3"),
]
const ENTRANCE_DURATION := 0.2
const EXIT_DURATION := 0.2
const ENTRANCE_SCALE := 0.9
const EXIT_SCALE := 0.95
const RESULT_BEFORE_FEEDBACK_DURATION := 0.15
const RESULT_AFTER_FEEDBACK_DURATION := 0.35
const SUCCESS_SCALE := 1.08
const FAILURE_SCALE := 0.96
const SUCCESS_HALF_DURATION := 0.17
const FAILURE_IMPACT_DURATION := 0.12
const FAILURE_RECOVERY_DURATION := 0.18
const SUCCESS_BRIGHTNESS := 1.2
const FAILURE_BRIGHTNESS := 0.72
const SUCCESS_SOUND := preload(
	"res://Assets/sounds/events/SFX_TABLETOPGAME_UI_Success_Bonus_002_forMUSIC_A_and_C.wav"
)
const FAILURE_SOUND := preload(
	"res://Assets/sounds/events/SFX_TABLETOP_UI_Lose_forMUSIC_B.wav"
)

@export var colormap_gradient: Gradient

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var result_sprite: Sprite2D = $ResultSprite
@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var shuffle_audio_player: AudioStreamPlayer = $ShuffleAudioPlayer
@onready var resolution_audio_player: AudioStreamPlayer = $ResolutionAudioPlayer
@onready var modifier_indicator: Label = $ModifierIndicator

var is_rolling := false
var resolution_feedback_active := false
var presentation_scale := Vector2.ONE
var presentation_position := Vector2.ZERO
var presentation_modulate := Color.WHITE
var presentation_self_modulate := Color.WHITE


func _ready() -> void:
	presentation_scale = scale
	presentation_position = position
	presentation_modulate = modulate
	presentation_self_modulate = self_modulate
	_apply_colormap()
	hide()


func roll(faces: Array[String], success_bonus: int = 0) -> String:
	if is_rolling:
		return ""
	if faces.is_empty():
		push_warning("ActorDice cannot roll without configured faces.")
		return ""

	is_rolling = true
	_set_modifier_indicator(success_bonus)
	result_sprite.hide()
	animated_sprite.show()
	animated_sprite.frame = 0
	_play_shuffle_open()
	await _animate_entrance()

	audio_player.stream = ROLL_SOUNDS.pick_random()
	audio_player.play()
	animated_sprite.play(&"default")

	await animated_sprite.animation_finished

	var result: String = faces.pick_random()
	animated_sprite.hide()
	result_sprite.texture = _texture_for_result(result)
	result_sprite.show()
	return result


func play_resolution_feedback(success: bool) -> void:
	if not is_rolling or resolution_feedback_active:
		return

	resolution_feedback_active = true
	await get_tree().create_timer(RESULT_BEFORE_FEEDBACK_DURATION).timeout
	if success:
		await _play_success_feedback()
	else:
		await _play_failure_feedback()
	await get_tree().create_timer(RESULT_AFTER_FEEDBACK_DURATION).timeout
	await _animate_exit()
	_restore_presentation_state()
	resolution_feedback_active = false
	is_rolling = false


func _play_shuffle_open() -> void:
	shuffle_audio_player.stream = SHUFFLE_OPEN_SOUNDS.pick_random()
	shuffle_audio_player.play()


func _set_modifier_indicator(success_bonus: int) -> void:
	var visible_bonus := maxi(0, success_bonus)
	modifier_indicator.visible = visible_bonus > 0
	modifier_indicator.text = "+%d" % visible_bonus


func _play_success_feedback() -> void:
	resolution_audio_player.stream = SUCCESS_SOUND
	resolution_audio_player.play()

	var bright_color := _brightness_color(
		presentation_self_modulate,
		SUCCESS_BRIGHTNESS
	)
	await _tween_scale_and_brightness(
		presentation_scale * SUCCESS_SCALE,
		bright_color,
		SUCCESS_HALF_DURATION
	)
	await _tween_scale_and_brightness(
		presentation_scale,
		presentation_self_modulate,
		SUCCESS_HALF_DURATION
	)


func _play_failure_feedback() -> void:
	resolution_audio_player.stream = FAILURE_SOUND
	resolution_audio_player.play()

	var shake_tween := create_tween()
	shake_tween.set_trans(Tween.TRANS_SINE)
	shake_tween.set_ease(Tween.EASE_IN_OUT)
	shake_tween.tween_property(
		self,
		"position",
		presentation_position + Vector2(5.0, 0.0),
		0.05
	)
	shake_tween.tween_property(
		self,
		"position",
		presentation_position + Vector2(-5.0, 0.0),
		0.06
	)
	shake_tween.tween_property(
		self,
		"position",
		presentation_position + Vector2(3.0, 0.0),
		0.05
	)
	shake_tween.tween_property(
		self,
		"position",
		presentation_position + Vector2(-3.0, 0.0),
		0.05
	)
	shake_tween.tween_property(
		self,
		"position",
		presentation_position,
		0.11
	)

	var dark_color := _brightness_color(
		presentation_self_modulate,
		FAILURE_BRIGHTNESS
	)
	await _tween_scale_and_brightness(
		presentation_scale * FAILURE_SCALE,
		dark_color,
		FAILURE_IMPACT_DURATION
	)
	await _tween_scale_and_brightness(
		presentation_scale,
		presentation_self_modulate,
		FAILURE_RECOVERY_DURATION
	)
	await shake_tween.finished


func _tween_scale_and_brightness(
	target_scale: Vector2,
	target_color: Color,
	duration: float
) -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "scale", target_scale, duration)
	tween.tween_property(self, "self_modulate", target_color, duration)
	await tween.finished


func _brightness_color(base_color: Color, multiplier: float) -> Color:
	return Color(
		base_color.r * multiplier,
		base_color.g * multiplier,
		base_color.b * multiplier,
		base_color.a
	)


func _animate_entrance() -> void:
	show()
	modulate.a = 0.0
	scale = presentation_scale * ENTRANCE_SCALE

	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 1.0, ENTRANCE_DURATION)
	tween.tween_property(self, "scale", presentation_scale, ENTRANCE_DURATION)
	await tween.finished


func _animate_exit() -> void:
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN)
	tween.tween_property(self, "modulate:a", 0.0, EXIT_DURATION)
	tween.tween_property(
		self,
		"scale",
		presentation_scale * EXIT_SCALE,
		EXIT_DURATION
	)
	await tween.finished

	hide()


func _restore_presentation_state() -> void:
	position = presentation_position
	scale = presentation_scale
	modulate = presentation_modulate
	self_modulate = presentation_self_modulate
	modifier_indicator.hide()


func _apply_colormap() -> void:
	if colormap_gradient == null:
		push_warning("ActorDice has no colormap gradient assigned.")
		return

	var colormap_texture := GradientTexture2D.new()
	colormap_texture.gradient = colormap_gradient

	for sprite: CanvasItem in [animated_sprite, result_sprite]:
		var material_instance := sprite.material.duplicate() as ShaderMaterial
		material_instance.set_shader_parameter("colormap", colormap_texture)
		sprite.material = material_instance


func _texture_for_result(result: String) -> Texture2D:
	match result:
		"ATENCIÓN":
			return ATTENTION_TEXTURE
		"CORDURA":
			return SANITY_TEXTURE
		"FUERZA":
			return STRENGTH_TEXTURE
		_:
			push_warning("ActorDice received an unknown face: %s" % result)
			return null
