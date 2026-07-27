extends Control
class_name PauseMenu

signal resume_requested
signal main_menu_requested

@onready var continue_button: Button = %ContinueButton
@onready var back_to_menu_button: Button = %BackToMenuButton
@onready var leave_confirmation: ConfirmationDialog = %LeaveConfirmation


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)
	leave_confirmation.confirmed.connect(_on_leave_confirmed)
	leave_confirmation.canceled.connect(_on_leave_canceled)


func open() -> void:
	show()
	continue_button.grab_focus()


func close() -> void:
	leave_confirmation.hide()
	hide()


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	var key_event := event as InputEventKey
	if visible and not leave_confirmation.visible and key_event.pressed and not key_event.echo and key_event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		resume_requested.emit()


func _on_continue_pressed() -> void:
	resume_requested.emit()


func _on_back_to_menu_pressed() -> void:
	leave_confirmation.popup_centered()


func _on_leave_confirmed() -> void:
	main_menu_requested.emit()


func _on_leave_canceled() -> void:
	back_to_menu_button.grab_focus()
