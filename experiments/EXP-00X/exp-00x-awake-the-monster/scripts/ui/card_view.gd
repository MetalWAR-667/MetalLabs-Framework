class_name CardView
extends Control

signal option_selected(option_index: int)

@export_group("Narrative reveal")
@export_range(1.0, 120.0, 1.0) var text_characters_per_second := 40.0
@export_range(0.0, 1.0, 0.01) var comma_pause := 0.08
@export_range(0.0, 2.0, 0.01) var sentence_pause := 0.18
@export_range(0.0, 1.0, 0.01) var options_fade_duration := 0.18

@export_group("Option hover")
@export_range(0.0, 1.0, 0.01) var hover_duration := 0.16
@export_range(0.0, 10.0, 1.0) var hover_text_offset := 4.0

@export_group("Illustration movement")
@export_range(1.0, 3.0, 0.01) var illustration_start_scale := 2.02
@export_range(0.5, 1.0, 0.01) var illustration_end_scale := 1.0
@export_range(0.0, 30.0, 0.1) var illustration_zoom_duration := 8.0

@onready var image_region: Control = %ImageRegion
@onready var illustration: TextureRect = %Illustration
@onready var narrative_text: RichTextLabel = %NarrativeText
@onready var narrative_scroll_bar: VScrollBar = narrative_text.get_v_scroll_bar()
@onready var decisions_region: VBoxContainer = %DecisionsRegion
@onready var card_border: TextureRect = $CardCenter/CardCanvas/CardBorder
@onready var threat_bar: Control = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar
)
@onready var attention_icon: Sprite2D = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/HBoxContainer/AttentionIcon
)
@onready var sanity_icon: Sprite2D = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/HBoxContainer/SanityIcon
)
@onready var strength_icon: Sprite2D = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/HBoxContainer/StrengthIcon
)
@onready var attention_amount: Label = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/AttentionAmount
)
@onready var sanity_amount: Label = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/SanityAmount
)
@onready var strength_amount: Label = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/StrengthAmount
)
@onready var damage_indicator: Control = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/DamageIndicator
)
@onready var damage_text: Label = (
	$CardCenter/CardCanvas/MainLayout/ImageRegion/CardThreatBar/DamageIndicator/DamageText
)

@onready var option_buttons: Array[Button] = [
	%OptionButton01,
	%OptionButton02,
	%OptionButton03,
]

@onready var option_labels: Array[Label] = [
	%OptionText01,
	%OptionText02,
	%OptionText03,
]

@onready var option_contents: Array[Control] = [
	%OptionContent01,
	%OptionContent02,
	%OptionContent03,
]

@onready var option_hover_backgrounds: Array[ColorRect] = [
	%OptionHoverBackground01,
	%OptionHoverBackground02,
	%OptionHoverBackground03,
]

var reveal_generation := 0
var text_revealing := false
var options_available := false
var requested_option_enabled: Array[bool] = [false, false, false]
var options_fade_tween: Tween
var illustration_tween: Tween
var damage_feedback_tween: Tween
var hover_tweens: Array[Tween] = [null, null, null]
var border_shader_time := 0.0
var interaction_locked := false


func _ready() -> void:
	narrative_text.mouse_filter = Control.MOUSE_FILTER_PASS
	narrative_text.gui_input.connect(_on_narrative_gui_input)
	narrative_scroll_bar.visibility_changed.connect(_keep_narrative_scroll_bar_invisible)
	_keep_narrative_scroll_bar_invisible()
	for index in range(option_buttons.size()):
		var button := option_buttons[index]
		button.pressed.connect(_on_option_pressed.bind(index))
		button.mouse_entered.connect(_on_option_hover_changed.bind(index, true))
		button.mouse_exited.connect(_on_option_hover_changed.bind(index, false))
		button.focus_entered.connect(_on_option_hover_changed.bind(index, true))
		button.focus_exited.connect(_on_option_hover_changed.bind(index, false))


func _process(delta: float) -> void:
	border_shader_time += delta
	if card_border.material is ShaderMaterial:
		card_border.material.set_shader_parameter(
			"custom_time",
			border_shader_time
		)


func _keep_narrative_scroll_bar_invisible() -> void:
	narrative_scroll_bar.modulate.a = 0.0


func _input(event: InputEvent) -> void:
	if not text_revealing or not event.is_action_pressed("ui_accept"):
		return

	get_viewport().set_input_as_handled()
	_complete_text_reveal()


func _on_narrative_gui_input(event: InputEvent) -> void:
	if (
		not text_revealing
		or event is not InputEventMouseButton
	):
		return

	var mouse_event := event as InputEventMouseButton
	if (
		mouse_event.button_index != MOUSE_BUTTON_LEFT
		or not mouse_event.pressed
	):
		return

	narrative_text.accept_event()
	_complete_text_reveal()


func set_card(card_data: CardData) -> void:
	if card_data == null:
		push_warning("CardView cannot present a null CardData resource.")
		return

	_cancel_card_presentation()
	illustration.texture = card_data.illustration
	narrative_text.text = card_data.description
	_set_options(card_data.options)
	if card_data.options.size() == 1 and _option_has_threat(card_data.options[0]):
		var option := card_data.options[0]
		show_threat(option.required_stat, option.required_successes, option.damage)
	else:
		hide_threat()

	_start_illustration_zoom()
	_start_text_reveal()


func set_options_enabled(enabled: bool) -> void:
	if enabled:
		interaction_locked = false
	for index in range(option_buttons.size()):
		if option_buttons[index].visible:
			requested_option_enabled[index] = enabled
	_apply_requested_option_states()


func set_option_enabled(option_index: int, enabled: bool) -> void:
	if option_index < 0 or option_index >= option_buttons.size():
		return
	if not option_buttons[option_index].visible:
		return

	requested_option_enabled[option_index] = enabled
	_apply_requested_option_states()


func reset_option_interaction_state() -> void:
	# Touch interfaces can retain focus/hover after a button disables itself
	# during its pressed signal. Clear every transient visual/input state before
	# the committed option becomes available for another threat round.
	for button in option_buttons:
		button.set_pressed_no_signal(false)
		button.release_focus()
	get_viewport().gui_release_focus()
	_reset_option_hover()


func prepare_option_retry(option_index: int) -> void:
	if option_index < 0 or option_index >= option_buttons.size():
		return
	reset_option_interaction_state()
	options_available = true
	for index in range(requested_option_enabled.size()):
		requested_option_enabled[index] = index == option_index
	interaction_locked = false
	_apply_requested_option_states()


func set_option_texts(texts: Array[String]) -> void:
	for index in range(option_buttons.size()):
		var has_option := index < texts.size() and not texts[index].is_empty()
		option_buttons[index].visible = has_option
		requested_option_enabled[index] = has_option
		option_labels[index].text = texts[index] if has_option else ""
	_apply_requested_option_states()


func show_threat(required_stat: CardOptionData.StatType, amount: int, damage: int) -> void:
	threat_bar.show()
	attention_icon.visible = required_stat == CardOptionData.StatType.ATTENTION
	attention_amount.visible = attention_icon.visible
	sanity_icon.visible = required_stat == CardOptionData.StatType.SANITY
	sanity_amount.visible = sanity_icon.visible
	strength_icon.visible = required_stat == CardOptionData.StatType.STRENGTH
	strength_amount.visible = strength_icon.visible

	var amount_text := "×%d" % amount
	attention_amount.text = amount_text
	sanity_amount.text = amount_text
	strength_amount.text = amount_text
	damage_indicator.visible = damage > 0
	damage_text.text = str(damage)


func play_damage_feedback() -> void:
	if not damage_indicator.visible:
		return

	if damage_feedback_tween != null and damage_feedback_tween.is_valid():
		damage_feedback_tween.kill()

	damage_indicator.pivot_offset = damage_indicator.size / 2.0
	damage_indicator.scale = Vector2.ONE
	damage_text.modulate = Color(1, 1, 1, 1)

	damage_feedback_tween = create_tween()
	damage_feedback_tween.set_parallel(true)
	damage_feedback_tween.set_trans(Tween.TRANS_BACK)
	damage_feedback_tween.set_ease(Tween.EASE_OUT)
	damage_feedback_tween.tween_property(
		damage_indicator, "scale", Vector2.ONE * 1.5, 0.12
	)
	damage_feedback_tween.tween_property(
		damage_text, "modulate", Color(1.0, 0.25, 0.2, 1.0), 0.1
	)
	damage_feedback_tween.chain().tween_property(
		damage_indicator, "scale", Vector2.ONE, 0.35
	)
	damage_feedback_tween.tween_property(
		damage_text, "modulate", Color(1, 1, 1, 1), 0.35
	)


func hide_threat() -> void:
	threat_bar.hide()
	attention_icon.hide()
	attention_amount.hide()
	sanity_icon.hide()
	sanity_amount.hide()
	strength_icon.hide()
	strength_amount.hide()
	damage_indicator.hide()
	damage_text.text = "0"


func _set_options(options: Array[CardOptionData]) -> void:
	for index in range(option_buttons.size()):
		var has_option := (
			index < options.size()
			and options[index] != null
			and not options[index].text.is_empty()
		)
		option_buttons[index].visible = has_option
		requested_option_enabled[index] = has_option
		option_labels[index].text = options[index].text if has_option else ""


func _start_text_reveal() -> void:
	reveal_generation += 1
	var generation := reveal_generation
	text_revealing = true
	options_available = false
	narrative_text.visible_characters = 0
	decisions_region.modulate.a = 0.0
	_apply_requested_option_states()
	_reveal_text(generation)


func _reveal_text(generation: int) -> void:
	var character_count := narrative_text.get_total_character_count()
	while (
		generation == reveal_generation
		and text_revealing
		and narrative_text.visible_characters < character_count
	):
		narrative_text.visible_characters += 1
		var character_index := narrative_text.visible_characters - 1
		var delay := 1.0 / maxf(text_characters_per_second, 1.0)
		if character_index >= 0 and character_index < narrative_text.text.length():
			var character := narrative_text.text[character_index]
			if character == ",":
				delay += comma_pause
			elif character in [".", ";", ":", "\n"]:
				delay += sentence_pause
		await get_tree().create_timer(delay).timeout

	if generation == reveal_generation and text_revealing:
		_complete_text_reveal()


func _complete_text_reveal() -> void:
	if not text_revealing:
		return

	reveal_generation += 1
	text_revealing = false
	narrative_text.visible_characters = -1
	call_deferred("_reveal_options")


func _reveal_options() -> void:
	if text_revealing:
		return

	options_available = true
	_apply_requested_option_states()
	if options_fade_tween != null and options_fade_tween.is_valid():
		options_fade_tween.kill()
	if is_zero_approx(options_fade_duration):
		decisions_region.modulate.a = 1.0
		return

	options_fade_tween = create_tween()
	options_fade_tween.set_trans(Tween.TRANS_SINE)
	options_fade_tween.set_ease(Tween.EASE_OUT)
	options_fade_tween.tween_property(
		decisions_region,
		"modulate:a",
		1.0,
		options_fade_duration
	)


func _start_illustration_zoom() -> void:
	if illustration_tween != null and illustration_tween.is_valid():
		illustration_tween.kill()

	illustration.scale = Vector2.ONE * illustration_end_scale
	var visible_center := image_region.global_position + image_region.size * 0.5
	illustration.pivot_offset = (
		illustration.get_global_transform().affine_inverse() * visible_center
	)
	illustration.scale = Vector2.ONE * illustration_start_scale

	if is_zero_approx(illustration_zoom_duration):
		illustration.scale = Vector2.ONE * illustration_end_scale
		return

	illustration_tween = create_tween()
	illustration_tween.set_trans(Tween.TRANS_SINE)
	illustration_tween.set_ease(Tween.EASE_IN_OUT)
	illustration_tween.tween_property(
		illustration,
		"scale",
		Vector2.ONE * illustration_end_scale,
		illustration_zoom_duration
	)


func _on_option_hover_changed(option_index: int, hovered: bool) -> void:
	if option_index < 0 or option_index >= option_buttons.size():
		return

	var existing_tween := hover_tweens[option_index]
	if existing_tween != null and existing_tween.is_valid():
		existing_tween.kill()

	var target_alpha := 1.0 if hovered else 0.0
	var base_x := 10.0
	var target_x := base_x + hover_text_offset if hovered else base_x
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(
		option_hover_backgrounds[option_index],
		"modulate:a",
		target_alpha,
		hover_duration
	)
	tween.tween_property(
		option_contents[option_index],
		"position:x",
		target_x,
		hover_duration
	)
	hover_tweens[option_index] = tween


func _reset_option_hover() -> void:
	for index in range(option_buttons.size()):
		var tween := hover_tweens[index]
		if tween != null and tween.is_valid():
			tween.kill()
		hover_tweens[index] = null
		option_hover_backgrounds[index].modulate.a = 0.0
		option_contents[index].position.x = 10.0


func _apply_requested_option_states() -> void:
	for index in range(option_buttons.size()):
		var can_interact := (
			options_available
			and option_buttons[index].visible
			and requested_option_enabled[index]
		)
		option_buttons[index].disabled = not can_interact


func _cancel_card_presentation() -> void:
	reveal_generation += 1
	text_revealing = false
	options_available = false
	interaction_locked = false
	if options_fade_tween != null and options_fade_tween.is_valid():
		options_fade_tween.kill()
	if illustration_tween != null and illustration_tween.is_valid():
		illustration_tween.kill()
	options_fade_tween = null
	illustration_tween = null
	_reset_option_hover()


func _option_has_threat(option: CardOptionData) -> bool:
	return option != null and option.required_stat != CardOptionData.StatType.NONE


func _on_option_pressed(option_index: int) -> void:
	if option_index < 0 or option_index >= option_buttons.size():
		return

	var diagnostic_button := option_buttons[option_index]
	print(
		"[RETRY-01] OPTION INPUT",
		" index=", option_index,
		" pressed=", diagnostic_button.button_pressed,
		" disabled=", diagnostic_button.disabled,
		" visible=", diagnostic_button.visible
	)
	print(
		"[RETRY-02] CARDVIEW STATE",
		" index=", option_index,
		" interaction_locked=", interaction_locked,
		" options_available=", options_available,
		" requested_enabled=", requested_option_enabled[option_index]
	)
	if interaction_locked:
		return

	var selected_button := option_buttons[option_index]
	if not selected_button.visible or selected_button.disabled or text_revealing:
		return

	# Do not disable a BaseButton from inside its own pressed callback. Mobile
	# browsers may then lose the touch release and retain the pressed capture.
	# Logical locking blocks repeated input while allowing the touch lifecycle
	# to finish normally.
	interaction_locked = true
	print("[RETRY-03] CARDVIEW EMIT", " index=", option_index)
	option_selected.emit(option_index)
