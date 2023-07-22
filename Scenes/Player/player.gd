extends CharacterBody3D

@onready var Cam = $Head/Camera3d as Camera3D
@onready var gui = $Gui

var mouseSensibility = 1200
var mouse_relative_x = 0
var mouse_relative_y = 0
const SPEED = 10.0
const JUMP_VELOCITY = 6

var hit_points = 100.0

var weapons: Array[Node3D] = [preload("res://dagger.tscn").instantiate(),
	preload("res://gun.tscn").instantiate(),
	preload("res://machinegun.tscn").instantiate()]
	
var unlocked = [true, false, false]
	
var weapon_index:int = 0
var weapon_node = weapons[weapon_index]

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	#print("PLAYER READY")
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	$Head/Camera3d.add_child(weapon_node)
	gui.hp = hit_points
	gui.magazine_ammo = weapon_node.magazine
	gui.ammo = weapon_node.ammo
	
func _physics_process(delta):
	var tree = get_tree()
	var nodes = tree.get_nodes_in_group("enemie")
	for n in nodes:
		n._update_player_position(global_transform.origin)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_pressed("Shoot"):
		shoot()
		
	if Input.is_action_just_pressed("Reload"):
		reload_magazine()
		
	if Input.is_action_just_pressed("NextWeapon"):
		next_weapon()
		
	if Input.is_action_just_pressed("PrevWapon"):
		prev_weapon()
		
	if Input.is_physical_key_pressed(KEY_ESCAPE):
		get_tree().quit()
	
	var input_dir = Input.get_vector("moveLeft", "moveRight", "moveUp", "moveDown")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	

func _input(event):
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x / mouseSensibility
		$Head/Camera3d.rotation.x -= event.relative.y / mouseSensibility
		$Head/Camera3d.rotation.x = clamp($Head/Camera3d.rotation.x, deg_to_rad(-90), deg_to_rad(90) )
#		mouse_relative_x = clamp(event.relative.x, -50, 50)
#		mouse_relative_y = clamp(event.relative.y, -50, 10)

func shoot():		
	weapon_node.shoot()
	gui.magazine_ammo = weapon_node.magazine

func reload_magazine():
	await weapon_node.reload()
	gui.magazine_ammo = weapon_node.magazine
	gui.ammo = weapon_node.ammo
	
func next_weapon():
	var prev_index = weapon_index
	weapon_index += 1
	weapon_index %= weapons.size()
	while not unlocked[weapon_index]:
		weapon_index += 1
		weapon_index %= weapons.size()
		
	if prev_index != weapon_index:
		switch_to_weapon()

func prev_weapon():
	var prev_index = weapon_index
	weapon_index -= 1
	if weapon_index < 0: weapon_index = weapons.size() - 1
	while not unlocked[weapon_index]:
		weapon_index -= 1
		if weapon_index < 0: weapon_index = weapons.size() - 1
		
	if prev_index != weapon_index:
		switch_to_weapon()
	
func switch_to_weapon():
	weapon_node.get_parent().remove_child(weapon_node)
	weapon_node = weapons[weapon_index]
	$Head/Camera3d.add_child(weapon_node)
	gui.magazine_ammo = weapon_node.magazine
	gui.ammo = weapon_node.ammo
	
	
func take_damage(dmg = 1.0):
	hit_points -= dmg
	print("DMG TAKEN")
	gui.hp = hit_points
	gui.take_damage()
	
func _on_item_detection_area_entered(area):
	var p = area.get_parent()
	if p.has_method("get_item_id"):
		var id = p.get_item_id()
		unlocked[id] = true
		weapon_index = id
		switch_to_weapon()
		p.queue_free()
