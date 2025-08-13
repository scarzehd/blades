@tool
extends Marker3D
class_name GenTileConnection

var generated:bool = false

@export var connection_id:StringName
@export var connection_data:GenTileConnectionData

var possible_tiles:Array[PackedScene]

var weights:Array[float]

var tile:GenTile
var draw3d:Draw3D
#var direction:Vector3 = Vector3.FORWARD

var door_sizes:Dictionary[StringName, AABB] = {
	"small_door": AABB(Vector3(-1, -1.5, 0), Vector3(2, 3, 1)).grow(-0.01),
	"small_hall": AABB(Vector3(-2.5, -1.5, 0), Vector3(5, 6, 1)).grow(-0.01),
	"large_hall": AABB(Vector3(-4, -1.5, 0), Vector3(8, 7, 1)).grow(-0.01)
}


func _ready() -> void:
	#direction = -global_basis.z
	if Engine.is_editor_hint():
		draw3d = Draw3D.new()
		draw3d.draw_vertex_points = true
		add_child(draw3d)
	for path in connection_data.possible_tiles:
		possible_tiles.append(load(path) as PackedScene)
	
	weights = Array(connection_data.weights)

func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		return
	
	draw3d.clear()
	
	if not door_sizes.has(connection_id):
		return
	
	var door_size = door_sizes[connection_id]
	
	draw3d.position = door_size.get_center()
	draw3d.cube(Vector3.ZERO, Basis.IDENTITY.scaled(door_size.size / 2), Color.GREEN)
	draw3d.draw_line([-draw3d.position, Vector3.FORWARD - draw3d.position], Color.RED)
