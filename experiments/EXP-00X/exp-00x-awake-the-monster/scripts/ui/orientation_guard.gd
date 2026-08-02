extends CanvasLayer

# Awake the Monster has one supported mobile composition: landscape. Native
# platforms receive a sensor-landscape request; browsers that cannot honor it
# are safely blocked until their viewport becomes wider than it is tall.

@onready var portrait_blocker: Control = %PortraitBlocker

var was_paused_before_block := false
var is_blocking_portrait := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if DisplayServer.has_feature(DisplayServer.FEATURE_ORIENTATION):
		DisplayServer.screen_set_orientation(DisplayServer.SCREEN_SENSOR_LANDSCAPE)
	get_viewport().size_changed.connect(_update_orientation_guard)
	call_deferred("_update_orientation_guard")


func _update_orientation_guard() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	var is_portrait := viewport_size.y > viewport_size.x

	if is_portrait == is_blocking_portrait:
		portrait_blocker.visible = is_portrait
		return

	if is_portrait:
		was_paused_before_block = get_tree().paused
		get_tree().paused = true
		is_blocking_portrait = true
		portrait_blocker.show()
	else:
		is_blocking_portrait = false
		portrait_blocker.hide()
		get_tree().paused = was_paused_before_block
