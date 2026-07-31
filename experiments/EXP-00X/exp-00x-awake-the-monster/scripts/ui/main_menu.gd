extends Control

const ITEM_SELECTION_SCENE_PATH := "res://scenes/ui/menu/item_selection_menu.tscn"
const HUD_SCENE := preload("res://scenes/ui/hud.tscn")
const MENU_MUSIC: AudioStream = preload(
	"res://Assets/music/Awake the monster_final.mp3"
)
const GAMEPLAY_MUSIC: AudioStream = preload(
	"res://Assets/music/Stone Above the Void.mp3"
)
const UI_HOVER_SOUND: AudioStream = preload(
	"res://Assets/sounds/events/Quiz_And_Puzzle_Musical_SFX  (289).wav"
)
const UI_CLICK_SOUND: AudioStream = preload(
	"res://Assets/sounds/events/Quiz_And_Puzzle_Musical_SFX  (290).wav"
)

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var fullscreen_button: Button = %FullscreenButton
@onready var exit_button: Button = %ExitButton
@onready var menu_ui_audio: AudioStreamPlayer = %MenuUIAudio

# Referencias a los nodos con shaders
@onready var title_texture: TextureRect = $Background/Title
@onready var logo_texture: TextureRect = $LogoMetalLabs
@onready var mist_vortex: ColorRect = %MistVortex
@onready var eye_motive: TextureRect = %EyeMotiveSelector

var shader_time: float = 0.0


func _ready() -> void:
	MusicPlayer.play(MENU_MUSIC)
	continue_button.disabled = not SaveManager.has_valid_save()
	
	# Conectar señales de los botones
	new_game_button.pressed.connect(_on_new_game_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	fullscreen_button.pressed.connect(_on_fullscreen_pressed)
	exit_button.pressed.connect(_on_exit_pressed)
	
	# Conectar señales de hover para efectos visuales
	for button: Button in [new_game_button, continue_button, fullscreen_button, exit_button]:
		button.mouse_entered.connect(_on_button_hover.bind(button))
		button.mouse_exited.connect(_on_button_unhover.bind(button))
		button.focus_entered.connect(_on_button_focus_entered.bind(button))

	# Dar foco inicial al botón de "Nueva partida"
	new_game_button.grab_focus()

	# Iniciar efectos visuales sutiles
	_setup_button_animations()

	# Reubicar el ojo si la ventana cambia de tamaño (incluye el paso a pantalla completa)
	get_viewport().size_changed.connect(_on_viewport_resized)

	# Configurar Pivot Offset de los botones para que escalen desde el centro
	await get_tree().process_frame
	for button: Button in [new_game_button, continue_button, fullscreen_button, exit_button]:
		button.pivot_offset = button.size / 2

	await get_tree().create_timer(0.1).timeout
	_align_eye_to_button(new_game_button, false)


func _on_viewport_resized() -> void:
	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused is Button:
		_align_eye_to_button(focused, false)
	else:
		_align_eye_to_button(new_game_button, false)


# Usamos _process para una animación fluida
func _process(delta: float) -> void:
	shader_time += delta

	# Actualizar shader de Título
	if title_texture.material is ShaderMaterial:
		title_texture.material.set_shader_parameter("custom_time", shader_time)

	# Actualizar shader de Logo
	if logo_texture.material is ShaderMaterial:
		logo_texture.material.set_shader_parameter("custom_time", shader_time)

	# Actualizar shader del remolino de bruma de fondo
	if mist_vortex.material is ShaderMaterial:
		mist_vortex.material.set_shader_parameter("custom_time", shader_time)


func _setup_button_animations() -> void:
	var tween: Tween = create_tween()
	tween.set_loops()
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.tween_method(_update_button_pulse, 0.0, 1.0, 2.0)


func _update_button_pulse(value: float) -> void:
	var pulse: float = sin(value * TAU) * 0.02 + 1.0
	var focused: Control = get_viewport().gui_get_focus_owner()  # <-- CORREGIDO
	if focused is Button:
		focused.scale = Vector2(pulse, pulse)


func _on_button_focus_entered(button: Button) -> void:
	_align_eye_to_button(button, true)


func _align_eye_to_button(button: Button, animated: bool) -> void:
	var button_center_global: Vector2 = button.get_global_rect().position + button.get_global_rect().size / 2.0
	var parent_control: Control = eye_motive.get_parent()
	var local_pos: Vector2 = parent_control.get_global_transform().affine_inverse() * button_center_global
	var target_y: float = local_pos.y - eye_motive.size.y / 2.0

	if animated:
		var tween: Tween = create_tween()
		tween.set_ease(Tween.EASE_OUT)
		tween.set_trans(Tween.TRANS_CUBIC)
		tween.tween_property(eye_motive, "position:y", target_y, 0.25)
	else:
		eye_motive.position.y = target_y


func _on_button_hover(button: Button) -> void:
	if button.disabled:
		return

	_play_ui_sound(UI_HOVER_SOUND)
	_align_eye_to_button(button, true)

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", Vector2(1.08, 1.08), 0.15)


func _on_button_unhover(button: Button) -> void:
	if button.disabled:
		return

	var focused: Control = get_viewport().gui_get_focus_owner()
	if focused is Button and focused != button:
		_align_eye_to_button(focused, true)

	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)


func _on_new_game_pressed() -> void:
	_play_ui_sound(UI_CLICK_SOUND)
	MusicPlayer.stop()
	SaveManager.clear_save()
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(new_game_button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(new_game_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	await menu_ui_audio.finished
	get_tree().change_scene_to_file(ITEM_SELECTION_SCENE_PATH)


func _on_continue_pressed() -> void:
	var saved_state := SaveManager.load_game()
	if saved_state.is_empty():
		continue_button.disabled = true
		new_game_button.grab_focus()
		return

	var hud := HUD_SCENE.instantiate() as GameHUD
	if hud == null:
		push_error("MainMenu could not instantiate the HUD.")
		return

	_play_ui_sound(UI_CLICK_SOUND)
	await menu_ui_audio.finished
	MusicPlayer.play(GAMEPLAY_MUSIC)
	hud.pending_save_state = saved_state

	var scene_tree := get_tree()
	var previous_scene := scene_tree.current_scene
	scene_tree.root.add_child(hud)
	scene_tree.current_scene = hud
	previous_scene.queue_free()


func _on_fullscreen_pressed() -> void:
	_play_ui_sound(UI_CLICK_SOUND)
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(fullscreen_button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(fullscreen_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	var current_mode: int = DisplayServer.window_get_mode()
	var target_mode: int = DisplayServer.WINDOW_MODE_WINDOWED

	if current_mode != DisplayServer.WINDOW_MODE_FULLSCREEN:
		target_mode = DisplayServer.WINDOW_MODE_FULLSCREEN
		
		await get_tree().create_timer(0.1).timeout
		DisplayServer.window_set_mode(target_mode)
		fullscreen_button.text = "Ventana" if target_mode == DisplayServer.WINDOW_MODE_WINDOWED else "Pantalla completa"
	else:
		await get_tree().create_timer(0.1).timeout
		DisplayServer.window_set_mode(target_mode)
		fullscreen_button.text = "Ventana" if target_mode == DisplayServer.WINDOW_MODE_WINDOWED else "Pantalla completa"


func _on_exit_pressed() -> void:
	_play_ui_sound(UI_CLICK_SOUND)
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(exit_button, "scale", Vector2(0.95, 0.95), 0.1)
	tween.tween_property(exit_button, "scale", Vector2(1.0, 1.0), 0.1)
	
	await menu_ui_audio.finished
	get_tree().quit()


func _play_ui_sound(sound: AudioStream) -> void:
	menu_ui_audio.stream = sound
	menu_ui_audio.play()


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_UP:
				var current_focus: Control = get_viewport().gui_get_focus_owner()  # <-- CORREGIDO
				if current_focus:
					var buttons: Array[Button] = [exit_button, fullscreen_button, continue_button, new_game_button]
					var index: int = buttons.find(current_focus)
					if index > 0:
						buttons[index - 1].grab_focus()
				else:
					new_game_button.grab_focus()
				get_viewport().set_input_as_handled()
			
			KEY_DOWN:
				var current_focus: Control = get_viewport().gui_get_focus_owner()  # <-- CORREGIDO
				if current_focus:
					var buttons: Array[Button] = [new_game_button, continue_button, fullscreen_button, exit_button]
					var index: int = buttons.find(current_focus)
					if index < buttons.size() - 1 and index != -1:
						var next_button: Button = buttons[index + 1]
						if not next_button.disabled:
							next_button.grab_focus()
				else:
					new_game_button.grab_focus()
				get_viewport().set_input_as_handled()
