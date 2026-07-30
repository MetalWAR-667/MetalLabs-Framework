extends Control

const PREVIEW_RESOLUTION := Vector2i(1920, 1080)

const EXPERIMENTS: Array[Dictionary] = [
	{
		"id": "none",
		"label": "None",
	},
	{
		"id": "exp_vfx_001_dual_drift",
		"label": "EXP-VFX-001 — Dual Drift",
	},
	{
		"id": "exp_vfx_002_heat_distortion",
		"label": "EXP-VFX-002 — Heat Distortion",
	},
	{
		"id": "exp_vfx_003_ink",
		"label": "EXP-VFX-003 — Ink",
	},
	{
		"id": "exp_vfx_004_impossible_shadows",
		"label": "EXP-VFX-004 — Impossible Shadows",
	},
]

const EXPERIMENT_SCENES := {
	"exp_vfx_001_dual_drift": "res://experiments/vfx/exp_vfx_001_dual_drift/experiment.tscn",
	"exp_vfx_002_heat_distortion": "res://experiments/vfx/exp_vfx_002_heat_distortion/experiment.tscn",
	"exp_vfx_003_ink": "res://experiments/vfx/exp_vfx_003_ink/experiment.tscn",
	"exp_vfx_004_impossible_shadows": "res://experiments/vfx/exp_vfx_004_impossible_shadows/experiment.tscn",
}

@onready var experiment_selector: OptionButton = %ExperimentSelector
@onready var activate_button: Button = %ActivateButton
@onready var reset_button: Button = %ResetButton
@onready var pause_button: Button = %PauseButton
@onready var background_selector: OptionButton = %BackgroundSelector
@onready var status_label: Label = %StatusLabel
@onready var telemetry_label: Label = %TelemetryLabel

@onready var reference_background: ColorRect = \
	$MainMargin/MainLayout/Workspace/PreviewFrame/PreviewAspect/PreviewSurface/SubViewport/ReferenceBackground
@onready var gradient_background: TextureRect = \
	$MainMargin/MainLayout/Workspace/PreviewFrame/PreviewAspect/PreviewSurface/SubViewport/GradientBackground
@onready var experiment_container: Node2D = \
	$MainMargin/MainLayout/Workspace/PreviewFrame/PreviewAspect/PreviewSurface/SubViewport/ExperimentContainer

var current_experiment_id := "none"
var preview_paused := false


func _ready() -> void:
	_populate_selectors()
	activate_button.pressed.connect(_on_activate_pressed)
	reset_button.pressed.connect(_on_reset_pressed)
	pause_button.pressed.connect(_on_pause_pressed)
	background_selector.item_selected.connect(_on_background_selected)

	experiment_selector.select(0)
	background_selector.select(0)
	_apply_background_reference(0)
	_set_status("No experiment selected.")
	_update_telemetry()


func _process(_delta: float) -> void:
	_update_telemetry()


func _populate_selectors() -> void:
	experiment_selector.clear()
	for experiment in EXPERIMENTS:
		experiment_selector.add_item(str(experiment["label"]))
		experiment_selector.set_item_metadata(
			experiment_selector.item_count - 1,
			experiment["id"]
		)

	background_selector.clear()
	for background_name in ["Dark Void", "Mid Gray", "White", "Simple Gradient"]:
		background_selector.add_item(background_name)


func _on_activate_pressed() -> void:
	current_experiment_id = str(
		experiment_selector.get_item_metadata(experiment_selector.selected)
	)
	_activate_current_experiment()


func _on_reset_pressed() -> void:
	_activate_current_experiment()


func _on_pause_pressed() -> void:
	preview_paused = not preview_paused
	experiment_container.process_mode = (
		Node.PROCESS_MODE_DISABLED
		if preview_paused
		else Node.PROCESS_MODE_INHERIT
	)
	pause_button.text = "Resume" if preview_paused else "Pause"
	_set_status("Preview paused." if preview_paused else "Preview resumed.")


func _on_background_selected(index: int) -> void:
	_apply_background_reference(index)


func _activate_current_experiment() -> void:
	_clear_experiment_container()

	if current_experiment_id == "none":
		_set_status("No experiment selected.")
		return

	var scene_path := str(EXPERIMENT_SCENES.get(current_experiment_id, ""))
	if scene_path.is_empty() or not ResourceLoader.exists(scene_path):
		_set_status("%s — Not implemented." % _current_experiment_name())
		return

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		_set_status("%s — Failed to load." % _current_experiment_name())
		return

	experiment_container.add_child(packed_scene.instantiate())
	_set_status("%s — Active." % _current_experiment_name())


func _clear_experiment_container() -> void:
	for child in experiment_container.get_children():
		experiment_container.remove_child(child)
		child.queue_free()


func _apply_background_reference(index: int) -> void:
	gradient_background.visible = index == 3
	reference_background.visible = index != 3

	match index:
		0:
			reference_background.color = Color(0.025, 0.03, 0.045, 1.0)
		1:
			reference_background.color = Color(0.35, 0.35, 0.35, 1.0)
		2:
			reference_background.color = Color.WHITE
		3:
			pass
		_:
			reference_background.color = Color(0.025, 0.03, 0.045, 1.0)


func _update_telemetry() -> void:
	var fps := Performance.get_monitor(Performance.TIME_FPS)
	var frame_time_ms := 1000.0 / fps if fps > 0.0 else 0.0
	telemetry_label.text = (
		"Experiment: %s\n"
		+ "Preview: %d × %d\n"
		+ "FPS: %.1f\n"
		+ "Frame: %.2f ms\n"
		+ "State: %s"
	) % [
		_current_experiment_name(),
		PREVIEW_RESOLUTION.x,
		PREVIEW_RESOLUTION.y,
		fps,
		frame_time_ms,
		"Paused" if preview_paused else "Running",
	]


func _current_experiment_name() -> String:
	for experiment in EXPERIMENTS:
		if experiment["id"] == current_experiment_id:
			return str(experiment["label"])
	return "None"


func _set_status(message: String) -> void:
	status_label.text = "Status: %s" % message
