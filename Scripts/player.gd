extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.1

@onready var cam_pivot = $CameraPivot
@onready var fpv_cam = $FPVCam
@onready var interact_ray = $FPVCam/RayCast3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_enabled = true

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event):
	if movement_enabled:
		_camera_motion(event)
	else:
		pass
	
	if Input.is_action_just_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT)\
			and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	if Input.is_action_just_pressed("interact"):
		_interact()

func _physics_process(delta):
	if movement_enabled:
		_player_movement(delta)
	else:
		pass


func _player_movement(delta):
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
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _camera_motion(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
		
		fpv_cam.rotate_x(deg_to_rad(-event.relative.y) * MOUSE_SENSITIVITY)
		fpv_cam.rotation.x = clamp(fpv_cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		
		cam_pivot.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY))
		cam_pivot.rotation.x = clamp(cam_pivot.rotation.x, deg_to_rad(-90), deg_to_rad(30))

func _interact():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		if collider.has_signal("interact"):
			collider.emit_signal("interact")
