class_name ActorData
extends Resource

@export var display_name: String
@export var portrait: Texture2D

@export_group("Dice")
@export var dice_faces: Array[String]

@export_group("Stats")
@export var health: int
@export var attention: int
@export var sanity: int
@export var strength: int
