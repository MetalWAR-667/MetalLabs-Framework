extends Node

var _player: AudioStreamPlayer = AudioStreamPlayer.new()


func _ready() -> void:
	add_child(_player)
	_player.bus = "Master"


func play(stream: AudioStream, fade_in: float = 0.0) -> void:
	if _player.stream == stream and _player.playing:
		return

	_player.stream = stream
	_player.volume_db = -40.0 if fade_in > 0.0 else 0.0
	_player.play()

	if fade_in > 0.0:
		var tween: Tween = create_tween()
		tween.tween_property(_player, "volume_db", 0.0, fade_in)


func stop() -> void:
	_player.stop()
	_player.stream = null
