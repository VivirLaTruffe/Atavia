extends VoxelTerrain
class_name VoxelWorld

@onready var voxel_tool := get_voxel_tool()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	voxel_tool.channel = VoxelBuffer.CHANNEL_TYPE


# Called when you do an action concerning a block
func raycast(caster_position: Vector3, caster_orientation: Vector3, caster_reach: float) -> VoxelHit:
	var block = voxel_tool.raycast(caster_position, caster_orientation, caster_reach)
	if block == null:
		return null
	
	var voxel_hit := VoxelHit.new()
	voxel_hit.block_position = block.position
	voxel_hit.previous_block_position = block.previous_position
	return voxel_hit 

func set_block(block_position: Vector3i, block_id: int) -> void:
	voxel_tool.set_voxel(block_position, block_id)
