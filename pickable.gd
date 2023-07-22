@tool
extends Node3D

@export var item_id:int = 0
@export var sprite:Texture2D:
	set(value):
		sprite = value
		$Sprite3D.texture = sprite

func get_item_id() -> int:
	return item_id
