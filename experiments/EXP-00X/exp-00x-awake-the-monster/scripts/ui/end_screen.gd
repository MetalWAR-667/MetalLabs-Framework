extends Control

const MAIN_MENU_SCENE_PATH := "res://scenes/ui/menu/main_menu.tscn"

@onready var back_to_menu_button: Button = %BackToMenuButton


func _ready() -> void:
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	back_to_menu_button.grab_focus()


func _on_back_to_menu_pressed() -> void:
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
