class_name EquipmentSlot
extends Control

@onready var item_icon: TextureRect = %ItemIcon

var equipped_item: ItemData


func equip(item: ItemData) -> void:
	if item == null:
		clear()
		return

	equipped_item = item
	item_icon.texture = item.hud_icon
	item_icon.visible = item.hud_icon != null
	tooltip_text = _build_tooltip(item)

	if item.hud_icon == null:
		push_warning(
			"EquipmentSlot cannot display %s without a HUD icon."
			% item.display_name
		)


func clear() -> void:
	equipped_item = null
	item_icon.texture = null
	item_icon.hide()
	tooltip_text = ""


func _build_tooltip(item: ItemData) -> String:
	if item.description.is_empty():
		return item.display_name
	return "%s\n%s" % [item.display_name, item.description]
