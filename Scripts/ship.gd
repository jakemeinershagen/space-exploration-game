extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.1

@onready var player = get_parent().get_node("Player")
@onready var follow_cam = $FollowCam
@onready var ship_cam = follow_cam

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _on_button_interact():
	player.start_ship_mode()
	ship_cam.make_current()


func _physics_process(delta):
	if player.ship_mode:
		_ship_movement(delta)


func _ship_movement(delta):
	# Add the gravity.
	# I'm somewhat worried is_on_floor may cause problems later, but we'll see
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(-input_dir.y, 0, input_dir.x)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	move_and_slide()
