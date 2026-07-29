extends Control

const MAIN_MENU_SCENE_PATH := "res://scenes/ui/menu/main_menu.tscn"
const HOLD_TIME := 3.0
const FADE_TIME := 1.0

@onready var logo: TextureRect = %Logo

var _music: AudioStream = preload("res://Assets/music/Awake the monster_final.mp3")
var _finished: bool = false
var _shader_time: float = 0.0


func _ready() -> void:
	MusicPlayer.play(_music, FADE_TIME)

	logo.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(logo, "modulate:a", 1.0, FADE_TIME)
	tween.tween_interval(HOLD_TIME)
	tween.tween_property(logo, "modulate:a", 0.0, FADE_TIME)
	tween.tween_callback(_go_to_main_menu)


func _process(delta: float) -> void:
	_shader_time += delta
	if logo.material is ShaderMaterial:
		logo.material.set_shader_parameter("custom_time", _shader_time)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") or (event is InputEventMouseButton and event.pressed):
		_go_to_main_menu()


func _go_to_main_menu() -> void:
	if _finished:
		return
	_finished = true
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)
