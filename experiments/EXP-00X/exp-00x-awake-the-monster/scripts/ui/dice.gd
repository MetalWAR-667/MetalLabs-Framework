class_name ActorDice
extends Node2D

const ATTENTION_TEXTURE := preload("res://Assets/ui/symbols/attention_icon.png")
const SANITY_TEXTURE := preload("res://Assets/ui/symbols/sanity_icon.png")
const STRENGTH_TEXTURE := preload("res://Assets/ui/symbols/strength_icon.png")

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var result_sprite: Sprite2D = $ResultSprite

var is_rolling := false


func roll(faces: Array[String]) -> String:
	if is_rolling:
		return ""
	if faces.is_empty():
		push_warning("ActorDice cannot roll without configured faces.")
		return ""

	is_rolling = true
	result_sprite.hide()
	animated_sprite.show()
	animated_sprite.frame = 0
	animated_sprite.play(&"default")

	await animated_sprite.animation_finished

	var result: String = faces.pick_random()
	animated_sprite.hide()
	result_sprite.texture = _texture_for_result(result)
	result_sprite.show()
	is_rolling = false
	return result


func _texture_for_result(result: String) -> Texture2D:
	match result:
		"ATENCIÓN":
			return ATTENTION_TEXTURE
		"CORDURA":
			return SANITY_TEXTURE
		"FUERZA":
			return STRENGTH_TEXTURE
		_:
			push_warning("ActorDice received an unknown face: %s" % result)
			return null
