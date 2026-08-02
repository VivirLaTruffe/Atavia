extends CharacterBody3D

@export var basic_speed := 5.0
@export var sprinting_speed := 7.0
@export var jump_velocity := 4.5
@export var reach := 3.0

@onready var cam: Camera3D = $Camera3D
@onready var voxel_world_link : VoxelWorld = get_tree().get_first_node_in_group("voxel_world")

var speed := 5.0

const SENSITIVITY := 0.003

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
	
	# Sprint
	if Input.is_action_pressed("sprint"):
		speed = sprinting_speed
	else:
		speed = basic_speed

	# Get the input direction and handle the movement/deceleration.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
	# Break
	if Input.is_action_just_pressed("break"):
		break_block()
		
	# Place
	if Input.is_action_just_pressed("place"):
		var block_id := 1
		place_block(block_id)

	move_and_slide()

# Get the camera rotation
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		rotate_y(event.relative.x*-SENSITIVITY)
		cam.rotate_x(event.relative.y*-SENSITIVITY)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))

# Break a block
func break_block() -> void:
	var voxel_hit_link := raycast_value()
	if voxel_hit_link != null:
		voxel_world_link.set_block(voxel_hit_link.block_position, 0)

func place_block(block_id: int) -> void:
	var voxel_hit_link := raycast_value()
	if voxel_hit_link != null:
		voxel_world_link.set_block(voxel_hit_link.previous_block_position, block_id)

func raycast_value() -> VoxelHit:
	var camera_position := cam.global_position
	var camera_orientation := -cam.global_transform.basis.z
	var voxel_hit_link := voxel_world_link.raycast(camera_position, camera_orientation, reach)
	return voxel_hit_link
