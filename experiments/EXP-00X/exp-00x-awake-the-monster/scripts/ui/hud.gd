extends Control

const MAIN_MENU_PATH := "res://scenes/ui/menu/MainMenu.tscn"

@export var player_data: ActorData
@export var companion_data: ActorData
@export var initial_card: CardData

@onready var card_view: CardView = $CardViewResponsive
@onready var player_actor_panel: ActorPanel = $ActorPanel
@onready var companion_actor_panel: ActorPanel = $Companion
@onready var pause_menu: PauseMenu = $PauseMenu


func _ready() -> void:
	card_view.set_card(initial_card)
	player_actor_panel.set_actor(player_data)
	companion_actor_panel.set_actor(companion_data)
	pause_menu.resume_requested.connect(_on_pause_resume_requested)
	pause_menu.main_menu_requested.connect(_on_pause_main_menu_requested)


func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return

	if key_event.keycode == KEY_ESCAPE and not get_tree().paused:
		get_viewport().set_input_as_handled()
		_open_pause_menu()


func _open_pause_menu() -> void:
	get_tree().paused = true
	pause_menu.open()


func _on_pause_resume_requested() -> void:
	pause_menu.close()
	get_tree().paused = false
	get_viewport().gui_release_focus()


func _on_pause_main_menu_requested() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_PATH)
