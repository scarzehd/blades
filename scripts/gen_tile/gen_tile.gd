extends Node3D
class_name GenTile

var connections:Array[GenTileConnection] = []
var collision_shape:CollisionShape3D
var area:Area3D

func _ready() -> void:
	#bounds.grow(-1)
	area = Area3D.new()
	add_child(area)
	collision_shape = CollisionShape3D.new()
	area.add_child(collision_shape)
	area.collision_layer = 4
	area.collision_mask = 4
	update_bounding_box()
	for child in get_children():
		if child is GenTileConnection:
			connections.append(child)
			child.tile = self

func update_bounding_box():
	var aabb = calculate_aabb()
	var shape = BoxShape3D.new()
	var center = aabb.get_center()
	#center.y = -center.y
	collision_shape.position = center
	#collision_shape.top_level = true
	shape.size = aabb.size
	collision_shape.shape = shape
	#print(aabb.size)

func calculate_aabb(node:Node = self, bounds:AABB = AABB()) -> AABB:
	if node is VisualInstance3D and not node.is_in_group("ignore_tile_bounds"):
		var child_bounds:AABB = node.transform * node.get_aabb()
		# If the bounds are empty, use the first child's bounds instead.
		# This way the origin isn't unintentionally included in the bounds when it shouldn't be
		if bounds:
			bounds = bounds.merge(child_bounds)
		else:
			bounds = child_bounds
	
	var children = node.get_children()
	for child in children:
		bounds = calculate_aabb(child, AABB(bounds))
	
	return bounds
