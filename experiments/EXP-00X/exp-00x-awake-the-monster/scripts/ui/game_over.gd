extends Control

const MAIN_MENU_PATH := "res://scenes/ui/menu/main_menu.tscn"

@export_range(0.35, 0.5, 0.01) var reveal_duration := 0.45
@export_range(2.0, 3.0, 0.1) var hold_duration := 2.5
@export_range(0.35, 0.75, 0.05) var fade_duration := 0.45

@onready var game_over_image: TextureRect = %GameOverImage


func _ready() -> void:
	MusicPlayer.stop()
	game_over_image.modulate.a = 0.0
	await get_tree().process_frame
	game_over_image.pivot_offset = game_over_image.size * 0.5
	game_over_image.scale = Vector2(1.2, 1.2)

	var reveal_tween := create_tween()
	reveal_tween.set_parallel(true)
	reveal_tween.set_trans(Tween.TRANS_SINE)
	reveal_tween.set_ease(Tween.EASE_OUT)
	reveal_tween.tween_property(
		game_over_image,
		"modulate:a",
		1.0,
		reveal_duration
	)
	reveal_tween.tween_property(
		game_over_image,
		"scale",
		Vector2.ONE,
		reveal_duration
	)
	await reveal_tween.finished

	await get_tree().create_timer(hold_duration).timeout

	var fade_tween := create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN)
	fade_tween.tween_property(
		game_over_image,
		"modulate:a",
		0.0,
		fade_duration
	)
	await fade_tween.finished

	get_tree().change_scene_to_file(MAIN_MENU_PATH)
