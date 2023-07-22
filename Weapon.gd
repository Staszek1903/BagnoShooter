extends Node3D
class_name Weapon

@onready var anim = $AnimationPlayer
@onready var gunRay = $RayCast3d as RayCast3D
@onready var _bullet_scene : PackedScene \
	= preload("res://Scenes/Bullet/Bullet.tscn")
@onready var magazine = MAGAZINE_SIZE
@onready var pivot:Node3D = $".."
@onready var player:Node3D = $"../../.."

@export var MAGAZINE_SIZE:int = 0
@export var ammo:int = 0
@export var damage = 1.0
@export var recoil_time = 0.0
@export var recoil_angle_degree = 5.0
@export var recoil_power = 5.0

var recoil_flag:bool = false

func _ready():
	assert(pivot)
	assert(player)
	print("PIVOT NAME: ",pivot.name)
	print("PLAYER NAME: ",player.name)
	var collisionBody:CollisionObject3D = $"../../.."
	assert(collisionBody)
	gunRay.add_exception(collisionBody)

func shoot():
	if recoil_flag: return
	if not gunRay.is_colliding():
		return
	if magazine == 0: return
	magazine -= 1
	anim.seek(0)
	anim.play("shoot")
	
	var bulletInst = _bullet_scene.instantiate() as Node3D
	bulletInst.set_as_top_level(true)
	get_tree().get_root().add_child(bulletInst)
	bulletInst.global_transform.origin = gunRay.get_collision_point() as Vector3
	bulletInst.look_at((gunRay.get_collision_point() \
		+ gunRay.get_collision_normal()),Vector3.BACK)
	print(gunRay.get_collision_point())
	print(gunRay.get_collision_point()+gunRay.get_collision_normal())
	
	var node = gunRay.get_collider()
	if node and node.has_method("take_damage"):
		node.take_damage(damage)
	recoil_flag = true
	pivot.rotation.x += deg_to_rad(recoil_power)
	player.rotation.y += deg_to_rad(randf_range(-recoil_angle_degree * 0.5,
		recoil_angle_degree * 0.5))
	
	
	await get_tree().create_timer(recoil_time).timeout
	recoil_flag = false
	
func reload():
	var empty_space = MAGAZINE_SIZE - magazine
	var to_reload = min(ammo, empty_space)
	
	if to_reload > 0:
		recoil_flag = true
		anim.play("reload")
		await anim.animation_finished
		recoil_flag = false
	
	ammo -= to_reload
	magazine += to_reload
