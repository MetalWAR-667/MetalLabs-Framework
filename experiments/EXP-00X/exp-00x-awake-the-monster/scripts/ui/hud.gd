class_name GameHUD
extends Control

const MAIN_MENU_PATH := "res://scenes/ui/menu/main_menu.tscn"
const ACT1_EPILOGUE_PATH := "res://scenes/ui/menu/act1_epilogue.tscn"
const GAME_OVER_PATH := "res://scenes/ui/menu/game_over.tscn"
const COMPANION_REVEAL_DURATION := 0.45
const COMPANION_REVEAL_SCALE := 0.96
const COMPANION_REVEAL_OFFSET := Vector2(0.0, 12.0)
const ACTOR_LAYOUT_REFERENCE_SIZE := Vector2(1920.0, 1080.0)
const ACTOR_LAYOUT_RIGHT_SAFE_INSET := 48.0

@export var player_data: ActorData
@export var companion_data: ActorData
@export var initial_card: CardData
@export var second_card: CardData
@export var third_card: CardData
@export var fourth_card: CardData
@export var fifth_card: CardData
@export var sixth_card: CardData

@onready var card_view: CardView = $CardViewResponsive
@onready var background_fx: BackgroundFX = $BackgroundFX
@onready var player_actor_panel: ActorPanel = $ActorPanel
@onready var equipment_slot: EquipmentSlot = $EquipmentSlot
@onready var companion_actor_panel: ActorPanel = $Companion
@onready var player_dice: ActorDice = $DicePlayer
@onready var companion_dice: ActorDice = $DiceCompanion
@onready var pause_menu: PauseMenu = $PauseMenu

var current_card: CardData
var current_player_health: int
var current_player_sanity: int
var is_resolving_test := false
var selected_item: ItemData
var selected_item_remaining_uses := 0
var sacrificed_initial_item := false
var remaining_threat := 0
var threat_resolution_active := false
var selected_option: CardOptionData
var selected_option_index := -1
var current_ally: ActorData
var ally_current_health := 0
var ally_participates := false
var protagonist_roll_result := ""
var ally_roll_result := ""
var equipped_bonus_applied := false
var pending_save_state: Dictionary = {}
var companion_final_position := Vector2.ZERO
var companion_final_scale := Vector2.ONE
var companion_final_mouse_filter := Control.MOUSE_FILTER_STOP
var companion_is_presented := false
var companion_reveal_tween: Tween
var is_game_over := false
var actor_layout_reference: Dictionary = {}


func _ready() -> void:
	print(
		"[RETRY-00] INPUT CONFIG",
		" emulate_mouse_from_touch=",
		ProjectSettings.get_setting(
			"input_devices/pointing/emulate_mouse_from_touch"
		),
		" emulate_touch_from_mouse=",
		ProjectSettings.get_setting(
			"input_devices/pointing/emulate_touch_from_mouse"
		)
	)
	card_view.option_selected.connect(_on_card_option_selected)
	_capture_actor_layout_reference()
	resized.connect(_on_hud_resized)
	_apply_responsive_actor_layout()
	current_ally = null
	ally_current_health = 0
	ally_participates = false
	protagonist_roll_result = ""
	ally_roll_result = ""
	_initialize_companion_presentation()
	companion_dice.hide()
	current_player_health = player_data.health
	current_player_sanity = player_data.sanity
	player_actor_panel.set_actor(player_data)
	if selected_item != null and selected_item_remaining_uses <= 0:
		selected_item_remaining_uses = selected_item.uses
	equipment_slot.equip(selected_item)
	companion_actor_panel.set_actor(companion_data)
	if selected_item != null:
		print_debug("Selected initial item: %s" % selected_item.display_name)
	pause_menu.resume_requested.connect(_on_pause_resume_requested)
	pause_menu.main_menu_requested.connect(_on_pause_main_menu_requested)
	if pending_save_state.is_empty():
		_load_card(initial_card)
	else:
		_restore_saved_state(pending_save_state)
	pending_save_state = {}


func _capture_actor_layout_reference() -> void:
	# Actor cards keep their authored 1920x1080 composition. Only the complete
	# actor assemblies are positioned and scaled responsively by the HUD.
	actor_layout_reference = {
		"player_panel_position": player_actor_panel.position,
		"player_panel_scale": player_actor_panel.scale,
		"companion_panel_position": companion_actor_panel.position,
		"companion_panel_scale": companion_actor_panel.scale,
		"equipment_position": equipment_slot.position,
		"equipment_scale": equipment_slot.scale,
		"player_dice_position": player_dice.position,
		"player_dice_scale": player_dice.scale,
		"companion_dice_position": companion_dice.position,
		"companion_dice_scale": companion_dice.scale,
	}


func _on_hud_resized() -> void:
	_apply_responsive_actor_layout()


func _apply_responsive_actor_layout() -> void:
	if actor_layout_reference.is_empty():
		return

	var viewport_size := size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return

	var layout_scale := minf(
		viewport_size.x / ACTOR_LAYOUT_REFERENCE_SIZE.x,
		viewport_size.y / ACTOR_LAYOUT_REFERENCE_SIZE.y
	)
	var vertical_offset := (
		viewport_size.y - ACTOR_LAYOUT_REFERENCE_SIZE.y * layout_scale
	) * 0.5

	player_actor_panel.position = _responsive_actor_position(
		actor_layout_reference["player_panel_position"],
		viewport_size,
		layout_scale,
		vertical_offset
	)
	player_actor_panel.scale = (
		actor_layout_reference["player_panel_scale"] * layout_scale
	)
	equipment_slot.position = _responsive_actor_position(
		actor_layout_reference["equipment_position"],
		viewport_size,
		layout_scale,
		vertical_offset
	)
	equipment_slot.scale = actor_layout_reference["equipment_scale"] * layout_scale
	var responsive_player_dice_position := _responsive_actor_position(
		actor_layout_reference["player_dice_position"],
		viewport_size,
		layout_scale,
		vertical_offset
	)
	var responsive_player_dice_scale: Vector2 = (
		actor_layout_reference["player_dice_scale"] * layout_scale
	)
	player_dice.set_layout_transform(
		responsive_player_dice_position,
		responsive_player_dice_scale
	)

	companion_final_position = _responsive_actor_position(
		actor_layout_reference["companion_panel_position"],
		viewport_size,
		layout_scale,
		vertical_offset
	)
	companion_final_scale = (
		actor_layout_reference["companion_panel_scale"] * layout_scale
	)
	var responsive_companion_dice_position := _responsive_actor_position(
		actor_layout_reference["companion_dice_position"],
		viewport_size,
		layout_scale,
		vertical_offset
	)
	var responsive_companion_dice_scale: Vector2 = (
		actor_layout_reference["companion_dice_scale"] * layout_scale
	)
	companion_dice.set_layout_transform(
		responsive_companion_dice_position,
		responsive_companion_dice_scale
	)

	if companion_reveal_tween != null and companion_reveal_tween.is_valid():
		companion_reveal_tween.kill()
		companion_reveal_tween = null
	companion_actor_panel.position = companion_final_position
	companion_actor_panel.scale = companion_final_scale
	companion_actor_panel.modulate.a = 1.0


func _responsive_actor_position(
		reference_position: Vector2,
		viewport_size: Vector2,
		layout_scale: float,
		vertical_offset: float
) -> Vector2:
	var reference_right_margin := (
		ACTOR_LAYOUT_REFERENCE_SIZE.x - reference_position.x
	)
	return Vector2(
		viewport_size.x
		- (reference_right_margin + ACTOR_LAYOUT_RIGHT_SAFE_INSET)
		* layout_scale,
		vertical_offset + reference_position.y * layout_scale
	)


func _on_card_option_selected(option_index: int) -> void:
	print(
		"[RETRY-04] HUD RECEIVED",
		" index=", option_index,
		" is_resolving_test=", is_resolving_test,
		" remaining_threat=", remaining_threat,
		" selected_option_index=", selected_option_index
	)
	if is_game_over:
		return

	if current_card == sixth_card:
		await _resolve_sixth_card_participant_selection(option_index)
		return

	if option_index < 0 or option_index >= current_card.options.size():
		card_view.set_options_enabled(true)
		return

	var requested_option := current_card.options[option_index]
	if requested_option == null:
		card_view.set_options_enabled(true)
		return

	if threat_resolution_active and requested_option != selected_option:
		_prepare_next_threat_round()
		return

	if current_card == initial_card:
		_load_card(second_card)
	elif current_card == second_card and not is_resolving_test:
		selected_option = requested_option
		selected_option_index = option_index
		await _resolve_current_threat_round(third_card)
	elif current_card == third_card and not is_resolving_test:
		await _resolve_third_card_option(option_index, requested_option)
	elif current_card == fourth_card and not is_resolving_test:
		selected_option = requested_option
		selected_option_index = option_index
		await _resolve_current_threat_round(fifth_card)
	elif current_card == fifth_card:
		_resolve_fifth_card_option(option_index)


func _resolve_third_card_option(option_index: int, selected_option: CardOptionData) -> void:
	match option_index:
		0:
			if selected_item == null:
				_configure_current_card_options()
				return

			selected_item = null
			selected_item_remaining_uses = 0
			equipment_slot.clear()
			sacrificed_initial_item = true
			print_debug("Initial item sacrificed at the Threshold.")
			_load_card(fourth_card)
		1:
			_load_card(second_card)
		2:
			self.selected_option = selected_option
			selected_option_index = option_index
			await _resolve_current_threat_round(fourth_card)


func _resolve_fifth_card_option(option_index: int) -> void:
	match option_index:
		0:
			current_ally = companion_data
			ally_current_health = maxi(0, current_ally.health - 1)
			companion_actor_panel.set_health(ally_current_health)
			_reveal_companion()
			_load_card(sixth_card)
		1:
			current_ally = null
			ally_current_health = 0
			_set_companion_visible_immediately(false)
			_load_card(sixth_card)


func _resolve_sixth_card_participant_selection(option_index: int) -> void:
	if not threat_resolution_active:
		if current_ally == null:
			if option_index != 0:
				card_view.set_options_enabled(true)
				return
			ally_participates = false
		else:
			if option_index < 0 or option_index > 1:
				card_view.set_options_enabled(true)
				return
			ally_participates = option_index == 1

		selected_option = current_card.options[0]
		selected_option_index = 0
		remaining_threat = 2 if ally_participates else selected_option.required_successes
		threat_resolution_active = true
		print_debug("Card 06 participants — protagonist: true, ally: %s" % ally_participates)
		print_debug("Remaining threat: %d" % remaining_threat)
	else:
		var committed_option_index := 1 if ally_participates else 0
		if option_index != committed_option_index:
			_prepare_next_sixth_card_round()
			return

	card_view.show_threat(selected_option.required_stat, remaining_threat, selected_option.damage)
	var protagonist_success_bonus := _consume_equipped_success_bonus(
		selected_option.required_stat
	)
	await _roll_sixth_card_dice(protagonist_success_bonus)

	var round_successes := protagonist_success_bonus
	if _rolled_stat_matches(protagonist_roll_result, selected_option.required_stat):
		round_successes += 1
	if ally_participates and _rolled_stat_matches(ally_roll_result, selected_option.required_stat):
		round_successes += 1

	remaining_threat = maxi(0, remaining_threat - round_successes)
	print_debug("Card 06 round — successes: %d, remaining threat: %d" % [
		round_successes,
		remaining_threat,
	])

	if remaining_threat <= 0:
		print_debug("Threat neutralized")
		_resolve_ally_rest()
		await background_fx.play_success_feedback()
		SaveManager.clear_save()
		get_tree().paused = false
		get_tree().change_scene_to_file(ACT1_EPILOGUE_PATH)
		return

	card_view.show_threat(selected_option.required_stat, remaining_threat, selected_option.damage)
	if await _apply_player_damage(selected_option.damage):
		return
	if ally_participates:
		_apply_ally_damage(selected_option.damage)
	_prepare_next_sixth_card_round()
	_autosave()
	if round_successes > 0:
		background_fx.play_success_feedback()
	else:
		background_fx.play_failure_feedback()


func _roll_sixth_card_dice(protagonist_success_bonus: int) -> void:
	protagonist_roll_result = await player_dice.roll(
		player_data.dice_faces,
		protagonist_success_bonus
	)
	print_debug("Card 06 roll — participant: protagonist, actor: %s, symbol: %s" % [
		player_data.display_name,
		protagonist_roll_result,
	])
	await player_dice.play_resolution_feedback(
		protagonist_success_bonus > 0
		or _rolled_stat_matches(
			protagonist_roll_result,
			selected_option.required_stat
		)
	)

	ally_roll_result = ""
	if not ally_participates:
		companion_dice.hide()
		return

	companion_dice.show()
	ally_roll_result = await companion_dice.roll(current_ally.dice_faces)
	print_debug("Card 06 roll — participant: ally, actor: %s, symbol: %s" % [
		current_ally.display_name,
		ally_roll_result,
	])
	await companion_dice.play_resolution_feedback(
		_rolled_stat_matches(
			ally_roll_result,
			selected_option.required_stat
		)
	)


func _apply_ally_damage(damage: int) -> void:
	ally_current_health -= damage
	companion_actor_panel.set_health(ally_current_health)
	print_debug("Fugitivo Pálido Health: %d" % ally_current_health)

	if ally_current_health <= 0:
		push_warning("Fugitivo Pálido has reached %d Health. Ally defeat is not implemented yet." % ally_current_health)


func _resolve_ally_rest() -> void:
	if current_ally == null:
		return

	if ally_participates:
		print_debug("Descanso no aplicado:\nel aliado participó en el encuentro.")
		return

	var previous_health := ally_current_health
	ally_current_health = mini(ally_current_health + 1, current_ally.health)
	companion_actor_panel.set_health(ally_current_health)
	print_debug("Descanso del aliado:\n%s\nSalud anterior: %d\nSalud actual: %d" % [
		current_ally.display_name,
		previous_health,
		ally_current_health,
	])


func _prepare_next_sixth_card_round() -> void:
	var committed_option_index := 1 if ally_participates else 0
	card_view.prepare_option_retry(committed_option_index)


func _resolve_current_threat_round(completion_card: CardData) -> void:
	is_resolving_test = true
	if not threat_resolution_active:
		remaining_threat = selected_option.required_successes
		threat_resolution_active = true
		print_debug("Remaining threat: %d" % remaining_threat)

	card_view.show_threat(selected_option.required_stat, remaining_threat, selected_option.damage)
	var success_bonus := _consume_equipped_success_bonus(
		selected_option.required_stat
	)
	print("[RETRY-05] HUD START ROLL", " index=", selected_option_index)
	var result := await player_dice.roll(
		player_data.dice_faces,
		success_bonus
	)
	var rolled_symbol_succeeded := _rolled_stat_matches(
		result,
		selected_option.required_stat
	)
	var round_successes := success_bonus
	if rolled_symbol_succeeded:
		round_successes += 1
	if round_successes > 0:
		background_fx.start_success_feedback()
	else:
		background_fx.start_failure_feedback()
	await player_dice.play_resolution_feedback(round_successes > 0)

	if round_successes > 0:
		remaining_threat = maxi(0, remaining_threat - round_successes)
		if remaining_threat > 0:
			card_view.show_threat(selected_option.required_stat, remaining_threat, selected_option.damage)

	if remaining_threat <= 0:
		print_debug("Threat neutralized")
		is_resolving_test = false
		_load_card(completion_card)
		return

	print_debug("Remaining threat: %d" % remaining_threat)
	if await _apply_player_damage(selected_option.damage):
		return
	print(
		"[RETRY-06] FAILURE RESOLVED",
		" is_resolving_test=", is_resolving_test,
		" remaining_threat=", remaining_threat
	)
	is_resolving_test = false
	_prepare_next_threat_round()
	print(
		"[RETRY-07] RETRY READY",
		" interaction_locked=", card_view.interaction_locked,
		" options_available=", card_view.options_available,
		" is_resolving_test=", is_resolving_test,
		" selected_option_index=", selected_option_index
	)
	_autosave()


func _rolled_stat_matches(result: String, required_stat: CardOptionData.StatType) -> bool:
	match required_stat:
		CardOptionData.StatType.ATTENTION:
			return result == "ATENCIÓN"
		CardOptionData.StatType.SANITY:
			return result == "CORDURA"
		CardOptionData.StatType.STRENGTH:
			return result == "FUERZA"
		_:
			return false


func _consume_equipped_success_bonus(
	required_stat: CardOptionData.StatType
) -> int:
	if equipped_bonus_applied:
		return 0

	if selected_item == null or selected_item_remaining_uses <= 0:
		return 0

	var success_bonus := selected_item.get_success_bonus(required_stat)
	if success_bonus <= 0:
		return 0

	equipped_bonus_applied = true
	selected_item_remaining_uses -= 1
	if selected_item_remaining_uses <= 0:
		selected_item_remaining_uses = 0
		selected_item = null
		equipment_slot.clear()

	return success_bonus


func _apply_player_damage(damage: int) -> bool:
	card_view.play_damage_feedback()
	current_player_health -= damage
	player_actor_panel.set_health(current_player_health)

	if current_player_health <= 0:
		await _start_game_over_sequence()
		return true

	return false


func _start_game_over_sequence() -> void:
	if is_game_over:
		return

	is_game_over = true
	card_view.set_options_enabled(false)
	get_viewport().gui_release_focus()
	SaveManager.clear_save()

	var fade_overlay := ColorRect.new()
	fade_overlay.name = "GameOverFade"
	fade_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	fade_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(fade_overlay)
	fade_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	move_child(fade_overlay, get_child_count() - 1)

	var fade_tween := create_tween()
	fade_tween.set_trans(Tween.TRANS_SINE)
	fade_tween.set_ease(Tween.EASE_IN_OUT)
	fade_tween.tween_property(fade_overlay, "color:a", 1.0, 0.45)
	await fade_tween.finished

	get_tree().paused = false
	get_tree().change_scene_to_file(GAME_OVER_PATH)


func _prepare_next_threat_round() -> void:
	card_view.prepare_option_retry(selected_option_index)


func _load_card(card: CardData, save_after_load := true) -> void:
	current_card = card
	remaining_threat = 0
	threat_resolution_active = false
	equipped_bonus_applied = false
	selected_option = null
	selected_option_index = -1
	card_view.set_card(card)
	background_fx.set_card(card.resource_path, save_after_load)
	_configure_current_card_options()

	if card == fourth_card:
		var item_name := selected_item.display_name if selected_item != null else "none"
		print_debug("Card 04 state — item: %s, sacrificed: %s" % [item_name, sacrificed_initial_item])
	elif card == fifth_card:
		var fifth_card_item_name := selected_item.display_name if selected_item != null else "none"
		print_debug("Card 05 state\nHealth: %d\nItem: %s\nSacrificed: %s" % [
			current_player_health,
			fifth_card_item_name,
			sacrificed_initial_item,
		])
	elif card == sixth_card:
		var sixth_card_item_name := selected_item.display_name if selected_item != null else "none"
		var ally_name := current_ally.display_name if current_ally != null else "none"
		print_debug("Card 06 state\nHealth: %d\nItem: %s\nSacrificed: %s\nAlly: %s\nAlly Health: %d" % [
			current_player_health,
			sixth_card_item_name,
			sacrificed_initial_item,
			ally_name,
			ally_current_health,
		])

	if save_after_load:
		_autosave()


func _autosave() -> void:
	if current_card == null:
		return

	SaveManager.save_game({
		"card_path": current_card.resource_path,
		"player_health": current_player_health,
		"player_sanity": current_player_sanity,
		"selected_item_path": (
			selected_item.resource_path if selected_item != null else ""
		),
		"item_remaining_uses": selected_item_remaining_uses,
		"sacrificed_initial_item": sacrificed_initial_item,
		"ally_present": current_ally != null,
		"ally_health": ally_current_health,
		"threat_active": threat_resolution_active,
		"remaining_threat": remaining_threat,
		"selected_option_index": selected_option_index,
		"ally_participates": ally_participates,
		"bonus_applied": equipped_bonus_applied,
	})


func _restore_saved_state(state: Dictionary) -> void:
	var saved_card := load(state.card_path) as CardData
	if saved_card == null or not _is_known_card(saved_card):
		push_warning("HUD could not restore the saved card. Starting a clean game.")
		SaveManager.clear_save()
		_load_card(initial_card)
		return

	current_player_health = state.player_health
	current_player_sanity = state.player_sanity
	player_actor_panel.set_health(current_player_health)
	player_actor_panel.set_sanity(current_player_sanity)
	sacrificed_initial_item = state.sacrificed_initial_item
	ally_current_health = state.ally_health
	ally_participates = state.ally_participates
	current_ally = companion_data if state.ally_present else null
	if current_ally == null:
		_set_companion_visible_immediately(false)
	else:
		companion_actor_panel.set_health(ally_current_health)
		_set_companion_visible_immediately(true)

	selected_item = null
	selected_item_remaining_uses = state.item_remaining_uses
	if not state.selected_item_path.is_empty() and selected_item_remaining_uses > 0:
		selected_item = load(state.selected_item_path) as ItemData
		if selected_item == null:
			push_warning("HUD could not restore the saved item. Starting a clean game.")
			SaveManager.clear_save()
			selected_item_remaining_uses = 0
			equipment_slot.clear()
			_load_card(initial_card)
			return
	if selected_item == null:
		selected_item_remaining_uses = 0
		equipment_slot.clear()
	else:
		equipment_slot.equip(selected_item)

	_load_card(saved_card, false)
	threat_resolution_active = state.threat_active
	remaining_threat = state.remaining_threat
	equipped_bonus_applied = state.bonus_applied

	var option_index: int = state.selected_option_index
	if threat_resolution_active:
		if option_index < 0 or option_index >= current_card.options.size():
			push_warning("HUD found an incomplete active threat. Starting the card clean.")
			threat_resolution_active = false
			remaining_threat = 0
			equipped_bonus_applied = false
		else:
			selected_option = current_card.options[option_index]
			selected_option_index = option_index
			card_view.show_threat(
				selected_option.required_stat,
				remaining_threat,
				selected_option.damage
			)
			if current_card == sixth_card:
				_prepare_next_sixth_card_round()
			else:
				_prepare_next_threat_round()

	print_debug("Prototype save restored: %s" % current_card.resource_path)


func _initialize_companion_presentation() -> void:
	companion_final_position = companion_actor_panel.position
	companion_final_scale = companion_actor_panel.scale
	companion_final_mouse_filter = companion_actor_panel.mouse_filter
	_set_companion_visible_immediately(false)


func _reveal_companion() -> void:
	if companion_is_presented:
		return

	if companion_reveal_tween != null and companion_reveal_tween.is_valid():
		companion_reveal_tween.kill()

	companion_is_presented = true
	companion_actor_panel.position = (
		companion_final_position + COMPANION_REVEAL_OFFSET
	)
	companion_actor_panel.scale = (
		companion_final_scale * COMPANION_REVEAL_SCALE
	)
	companion_actor_panel.modulate.a = 0.0
	companion_actor_panel.mouse_filter = companion_final_mouse_filter
	companion_actor_panel.set_process(true)
	companion_actor_panel.show()

	companion_reveal_tween = create_tween()
	companion_reveal_tween.set_parallel(true)
	companion_reveal_tween.set_trans(Tween.TRANS_SINE)
	companion_reveal_tween.set_ease(Tween.EASE_OUT)
	companion_reveal_tween.tween_property(
		companion_actor_panel,
		"modulate:a",
		1.0,
		COMPANION_REVEAL_DURATION
	)
	companion_reveal_tween.tween_property(
		companion_actor_panel,
		"scale",
		companion_final_scale,
		COMPANION_REVEAL_DURATION
	)
	companion_reveal_tween.tween_property(
		companion_actor_panel,
		"position",
		companion_final_position,
		COMPANION_REVEAL_DURATION
	)
	companion_reveal_tween.finished.connect(
		_on_companion_reveal_finished,
		CONNECT_ONE_SHOT
	)


func _on_companion_reveal_finished() -> void:
	companion_actor_panel.position = companion_final_position
	companion_actor_panel.scale = companion_final_scale
	companion_actor_panel.modulate.a = 1.0
	companion_reveal_tween = null


func _set_companion_visible_immediately(should_be_visible: bool) -> void:
	if companion_reveal_tween != null and companion_reveal_tween.is_valid():
		companion_reveal_tween.kill()
	companion_reveal_tween = null

	companion_is_presented = should_be_visible
	companion_actor_panel.position = companion_final_position
	companion_actor_panel.scale = companion_final_scale
	companion_actor_panel.modulate.a = 1.0
	companion_actor_panel.mouse_filter = (
		companion_final_mouse_filter
		if should_be_visible
		else Control.MOUSE_FILTER_IGNORE
	)
	companion_actor_panel.set_process(should_be_visible)
	companion_actor_panel.visible = should_be_visible
	companion_dice.hide()


func _is_known_card(card: CardData) -> bool:
	return card in [
		initial_card,
		second_card,
		third_card,
		fourth_card,
		fifth_card,
		sixth_card,
	]


func _configure_current_card_options() -> void:
	if current_card == third_card:
		card_view.set_option_enabled(0, selected_item != null)
	elif current_card == fourth_card:
		for option_index in range(current_card.options.size()):
			var option := current_card.options[option_index]
			if option != null and option.requires_sacrificed_item:
				card_view.set_option_enabled(option_index, sacrificed_initial_item)
	elif current_card == sixth_card:
		card_view.hide_threat()
		if current_ally == null:
			var solo_option_texts: Array[String] = [
				"Aferrarse al recuerdo del mundo despierto.",
			]
			card_view.set_option_texts(solo_option_texts)
		else:
			var participant_option_texts: Array[String] = [
				"Continuar solo",
				"Pedir ayuda al Fugitivo",
			]
			card_view.set_option_texts(participant_option_texts)


func _unhandled_key_input(event: InputEvent) -> void:
	if is_game_over:
		get_viewport().set_input_as_handled()
		return

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
