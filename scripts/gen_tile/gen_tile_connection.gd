extends Marker3D
class_name GenTileConnection

var generated:bool = false

@export var direction:Vector3
@export var connection_id:String
@export_file("*.tscn") var possible_tile_paths:Array[String]

var possible_tiles:Array[PackedScene]

var tile:GenTile

func _ready() -> void:
	for path in possible_tile_paths:
		possible_tiles.append(load(path) as PackedScene)
