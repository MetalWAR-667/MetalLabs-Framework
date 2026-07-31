extends Control

const FINAL_VERTICAL_SLICE_PATH := "res://scenes/ui/menu/end_screen.tscn"

@export_range(0.5, 3.0, 0.1) var hold_to_skip_duration := 1.5
@export_range(0.0, 2.0, 0.05) var initial_black_duration := 0.25
@export_range(0.0, 1.0, 0.05) var video_start_delay := 0.12
@export_range(0.0, 2.0, 0.05) var fade_duration := 0.4

@onready var video_player: VideoStreamPlayer = %VideoPlayer
@onready var epilogue_audio: AudioStreamPlayer = %EpilogueAudio
@onready var fade_overlay: ColorRect = %FadeOverlay
@onready var skip_indicator: Control = %SkipIndicator
@onready var skip_progress: ProgressBar = %SkipProgress

var hold_elapsed := 0.0
var playback_started := false
var exit_started := false
var paused_by_focus_loss := false


func _ready() -> void:
	MusicPlayer.stop()
	video_player.finished.connect(_on_video_finished)
	fade_overlay.modulate.a = 1.0
	skip_indicator.hide()
	skip_progress.value = 0.0
	await get_tree().create_timer(initial_black_duration).timeout
	if exit_started:
		return

	epilogue_audio.play()
	await get_tree().create_timer(video_start_delay).timeout
	if exit_started:
		return

	video_player.play()
	playback_started = true
	var fade_in := create_tween()
	fade_in.set_trans(Tween.TRANS_SINE)
	fade_in.set_ease(Tween.EASE_OUT)
	fade_in.tween_property(fade_overlay, "modulate:a", 0.0, fade_duration)


func _process(delta: float) -> void:
	if not playback_started or exit_started:
		return

	if Input.is_action_pressed("ui_accept"):
		hold_elapsed = minf(hold_elapsed + delta, hold_to_skip_duration)
		skip_indicator.show()
		skip_progress.value = hold_elapsed / hold_to_skip_duration * 100.0
		if hold_elapsed >= hold_to_skip_duration:
			_exit_to_final()
		return

	if hold_elapsed > 0.0:
		_reset_skip_progress()


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		if playback_started and not exit_started:
			video_player.paused = true
			epilogue_audio.stream_paused = true
			paused_by_focus_loss = true
	elif what == NOTIFICATION_APPLICATION_FOCUS_IN:
		if paused_by_focus_loss and not exit_started:
			video_player.paused = false
			epilogue_audio.stream_paused = false
			paused_by_focus_loss = false


func _on_video_finished() -> void:
	_exit_to_final()


func _exit_to_final() -> void:
	if exit_started:
		return

	exit_started = true
	playback_started = false
	_reset_skip_progress()

	var fade_out := create_tween()
	fade_out.set_parallel(true)
	fade_out.set_trans(Tween.TRANS_SINE)
	fade_out.set_ease(Tween.EASE_IN)
	fade_out.tween_property(fade_overlay, "modulate:a", 1.0, fade_duration)
	fade_out.tween_property(epilogue_audio, "volume_db", -40.0, fade_duration)
	await fade_out.finished

	video_player.stop()
	epilogue_audio.stop()
	get_tree().change_scene_to_file(FINAL_VERTICAL_SLICE_PATH)


func _reset_skip_progress() -> void:
	hold_elapsed = 0.0
	skip_progress.value = 0.0
	skip_indicator.hide()
