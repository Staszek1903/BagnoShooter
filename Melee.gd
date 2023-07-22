extends Node3D
class_name Melee

@onready var anim = $AnimationPlayer
@onready var magazine = MAGAZINE_SIZE
@onready var pivot:Node3D = $".."
@onready var player:Node3D = $"../../.."

var MAGAZINE_SIZE:int = -1
var ammo:int = -1
@export var damage = 1.0
@export var recoil_time = 0.4
var recoil_angle_degree = 5.0
var recoil_power = 5.0

var recoil_flag:bool = false

func _ready():
	assert(pivot)
	assert(player)
	print("PIVOT NAME: ",pivot.name)
	print("PLAYER NAME: ",player.name)
	var collisionBody:CollisionObject3D = $"../../.."
	assert(collisionBody)

func shoot():
	if recoil_flag: return

	anim.seek(0)
	anim.play("shoot")
	
	for body in bodies_in_range:
		if body and body.has_method("take_damage"):
			body.take_damage(damage)
	recoil_flag = true

	
	await get_tree().create_timer(recoil_time).timeout
	recoil_flag = false
	
func reload():
	pass

var bodies_in_range = []

func _on_area_3d_body_entered(body):
	if body == player: return
	bodies_in_range.append(body)
	print("body entered: ", body.name, " ", body)


func _on_area_3d_body_exited(body):
	bodies_in_range.erase(body)
	print("body exited: ", body.name, " ", body)
