extends CharacterBody3D

@onready var nav_angent= $NavigationAgent3D
@onready var sprite = $Sprite3D

const SPEED = 4.0
const JUMP_VELOCITY = 4.5
const ATTACK = 5.0

var hit_points = 3.0

var agr_status = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	nav_angent.target_position = global_transform.origin

func _update_player_position(position:Vector3):
	nav_angent.target_position = position
	#print("new target position ", position)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if not agr_status: return
	
	var next_pos = nav_angent.get_next_path_position()
	var dir_vect = next_pos - global_transform.origin
	if dir_vect.length() > 0.1:
		var direction = dir_vect.normalized()
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED

	move_and_slide()


var attacked_body = null
var attack_timer:SceneTreeTimer = null
func _on_attack_area_body_entered(body):
	if body == self : return
	if body.name == "Player":
		attacked_body = body
		while attacked_body:
			attacked_body.take_damage(ATTACK)
			attack_timer = get_tree().create_timer(2)
			await attack_timer.timeout

func _on_attack_area_body_exited(body):
	if attacked_body == body : 
		attacked_body = null
		attack_timer.time_left = 0.0
		
func take_damage(dmg = 1.0):
	hit_points -= dmg
	print("ENEMIE DMG ", dmg)
	if hit_points <= 0.0:
		queue_free()
		return
	sprite.modulate = Color(1.0,0.0,0.0)
	var tween = create_tween()
	tween.tween_property(sprite,"modulate",Color(1.0,1.0,1.0),0.5)
	

func _on_agr_area_body_entered(body):
	if body.name == "Player":
		agr_status = true
