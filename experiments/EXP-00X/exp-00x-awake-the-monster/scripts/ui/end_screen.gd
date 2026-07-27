extends Control

const HUD_SCENE_PATH := "res://scenes/ui/HUD.tscn"
const MAIN_MENU_SCENE_PATH := "res://scenes/ui/menu/MainMenu.tscn"

@onready var play_again_button: Button = %PlayAgainButton
@onready var back_to_menu_button: Button = %BackToMenuButton


func _ready() -> void:
	play_again_button.pressed.connect(_on_play_again_pressed)
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	play_again_button.grab_focus()


func _on_play_again_pressed() -> void:
	get_tree().change_scene_to_file(HUD_SCENE_PATH)


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
