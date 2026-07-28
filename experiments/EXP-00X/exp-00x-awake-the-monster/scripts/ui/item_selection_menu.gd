extends Control

const HUD_SCENE := preload("res://scenes/ui/hud.tscn")

@export var food_data: ItemData
@export var shotgun_data: ItemData
@export var shield_data: ItemData

@onready var item_illustrations: Array[TextureRect] = [
	%FoodIllustration,
	%ShotgunIllustration,
	%ShieldIllustration,
]

@onready var item_names: Array[Label] = [
	%FoodName,
	%ShotgunName,
	%ShieldName,
]

@onready var item_descriptions: Array[Label] = [
	%FoodDescription,
	%ShotgunDescription,
	%ShieldDescription,
]

@onready var choose_buttons: Array[Button] = [
	%ChooseFoodButton,
	%ChooseShotgunButton,
	%ChooseShieldButton,
]


func _ready() -> void:
	var items: Array[ItemData] = [food_data, shotgun_data, shield_data]

	for index in range(items.size()):
		_present_item(index, items[index])
		choose_buttons[index].pressed.connect(_on_item_chosen.bind(items[index]))

	choose_buttons[0].grab_focus()


func _present_item(index: int, item: ItemData) -> void:
	if item == null:
		push_warning("ItemSelectionMenu cannot present a null ItemData resource.")
		choose_buttons[index].disabled = true
		return

	item_illustrations[index].texture = item.illustration
	item_names[index].text = item.display_name
	item_descriptions[index].text = item.description


func _on_item_chosen(item: ItemData) -> void:
	if item == null:
		return

	for button in choose_buttons:
		button.disabled = true

	var hud := HUD_SCENE.instantiate() as GameHUD
	if hud == null:
		push_error("ItemSelectionMenu could not instantiate the HUD.")
		return

	hud.selected_item = item

	var scene_tree := get_tree()
	var previous_scene := scene_tree.current_scene
	scene_tree.root.add_child(hud)
	scene_tree.current_scene = hud
	previous_scene.queue_free()
