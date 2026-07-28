extends Control

const ITEM_SELECTION_SCENE_PATH := "res://scenes/ui/menu/item_selection_menu.tscn"

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var fullscreen_button: Button = %FullscreenButton
@onready var exit_button: Button = %ExitButton


func _ready() -> void:
	continue_button.disabled = true
	new_game_button.pressed.connect(_on_new_game_pressed)
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	new_game_button.grab_focus()


func _on_new_game_pressed() -> void:
	get_tree().change_scene_to_file(ITEM_SELECTION_SCENE_PATH)


func _on_fullscreen_pressed() -> void:
	var current_mode := DisplayServer.window_get_mode()
	var target_mode := DisplayServer.WINDOW_MODE_WINDOWED

	if current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		target_mode = DisplayServer.WINDOW_MODE_FULLSCREEN

	DisplayServer.window_set_mode(target_mode)


func _on_exit_pressed() -> void:
	get_tree().quit()
