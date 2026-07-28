class_name GameHUD
extends Control

const MAIN_MENU_PATH := "res://scenes/ui/menu/MainMenu.tscn"

@export var player_data: ActorData
@export var companion_data: ActorData
@export var initial_card: CardData
@export var second_card: CardData
@export var third_card: CardData
@export var fourth_card: CardData
@export var fifth_card: CardData

@onready var card_view: CardView = $CardViewResponsive
@onready var player_actor_panel: ActorPanel = $ActorPanel
@onready var companion_actor_panel: ActorPanel = $Companion
@onready var player_dice: ActorDice = $DicePlayer
@onready var pause_menu: PauseMenu = $PauseMenu

var current_card: CardData
var current_player_health: int
var is_resolving_test := false
var selected_item: ItemData
var sacrificed_initial_item := false
var remaining_threat := 0
var threat_resolution_active := false
var selected_option: CardOptionData


func _ready() -> void:
	card_view.option_selected.connect(_on_card_option_selected)
	current_player_health = player_data.health
	player_actor_panel.set_actor(player_data)
	companion_actor_panel.set_actor(companion_data)
	if selected_item != null:
		print_debug("Selected initial item: %s" % selected_item.display_name)
	pause_menu.resume_requested.connect(_on_pause_resume_requested)
	pause_menu.main_menu_requested.connect(_on_pause_main_menu_requested)
	_load_card(initial_card)


func _on_card_option_selected(option_index: int) -> void:
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
		await _resolve_current_threat_round(third_card)
	elif current_card == third_card and not is_resolving_test:
		await _resolve_third_card_option(option_index, requested_option)
	elif current_card == fourth_card and not is_resolving_test:
		selected_option = requested_option
		await _resolve_current_threat_round(fifth_card)
	elif current_card == fifth_card:
		print_debug("Card 05 option selected: %d" % option_index)
		card_view.set_options_enabled(true)


func _resolve_third_card_option(option_index: int, selected_option: CardOptionData) -> void:
	match option_index:
		0:
			if selected_item == null:
				_configure_current_card_options()
				return

			selected_item = null
			sacrificed_initial_item = true
			print_debug("Initial item sacrificed at the Threshold.")
			_load_card(fourth_card)
		1:
			_load_card(second_card)
		2:
			self.selected_option = selected_option
			await _resolve_current_threat_round(fourth_card)


func _resolve_current_threat_round(completion_card: CardData) -> void:
	is_resolving_test = true
	if not threat_resolution_active:
		remaining_threat = selected_option.required_successes
		threat_resolution_active = true
		print_debug("Remaining threat: %d" % remaining_threat)

	card_view.show_threat(selected_option.required_stat, remaining_threat, selected_option.damage)
	var result := await player_dice.roll(player_data.dice_faces)

	if _rolled_stat_matches(result, selected_option.required_stat):
		remaining_threat = maxi(0, remaining_threat - 1)
		if remaining_threat > 0:
			card_view.show_threat(selected_option.required_stat, remaining_threat, selected_option.damage)

	if remaining_threat <= 0:
		print_debug("Threat neutralized")
		_load_card(completion_card)
		is_resolving_test = false
		return

	print_debug("Remaining threat: %d" % remaining_threat)
	_apply_player_damage(selected_option.damage)
	_prepare_next_threat_round()
	is_resolving_test = false


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


func _apply_player_damage(damage: int) -> void:
	current_player_health -= damage
	player_actor_panel.set_health(current_player_health)

	if current_player_health <= 0:
		push_warning("Jack has reached %d Health. Defeat is not implemented yet." % current_player_health)


func _prepare_next_threat_round() -> void:
	card_view.set_options_enabled(false)
	var selected_index := current_card.options.find(selected_option)
	if selected_index >= 0:
		card_view.set_option_enabled(selected_index, true)


func _load_card(card: CardData) -> void:
	current_card = card
	remaining_threat = 0
	threat_resolution_active = false
	selected_option = null
	card_view.set_card(card)
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


func _configure_current_card_options() -> void:
	if current_card == third_card:
		card_view.set_option_enabled(0, selected_item != null)
	elif current_card == fourth_card:
		for option_index in range(current_card.options.size()):
			var option := current_card.options[option_index]
			if option != null and option.requires_sacrificed_item:
				card_view.set_option_enabled(option_index, sacrificed_initial_item)


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
