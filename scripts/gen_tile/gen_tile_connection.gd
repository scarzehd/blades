@tool
extends Marker3D
class_name GenTileConnection

var generated:bool = false

@export var connection_id:StringName
@export_file("*.tscn") var possible_tile_paths:Array[String]

var possible_tiles:Array[PackedScene]

var tile:GenTile
var draw3d:Draw3D
var direction:Vector3 = Vector3.FORWARD

var door_sizes:Dictionary[StringName, AABB] = {
	"small_door": AABB(Vector3(-1, -1.5, 0), Vector3(2, 3, 1)).grow(-0.01)
}

func _ready() -> void:
	direction = -global_basis.z
	if Engine.is_editor_hint():
		draw3d = Draw3D.new()
		draw3d.draw_vertex_points = true
		add_child(draw3d)
	for path in possible_tile_paths:
		possible_tiles.append(load(path) as PackedScene)

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
