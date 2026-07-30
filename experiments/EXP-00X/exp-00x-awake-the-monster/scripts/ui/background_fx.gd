class_name BackgroundFX
extends Control

@onready var transition_controller: BackgroundFXTransitionController = %TransitionController


func show_atmosphere() -> void:
	transition_controller.show_atmosphere()


func show_memory() -> void:
	transition_controller.show_memory()


func fade_to_atmosphere() -> void:
	transition_controller.fade_to_atmosphere()


func fade_to_memory() -> void:
	transition_controller.fade_to_memory()
