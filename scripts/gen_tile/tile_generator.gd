extends Node3D
class_name TileGenerator

@export var starting_tile:GenTile
@export var map_size:AABB

var temp_tiles:Array[GenTile]

var placed_tiles:Array[GenTile]

@export var debug_step:bool = false

signal generation_finished

func _ready() -> void:
	generate()

func generate():
	randomize()
	var connections_left:Array[GenTileConnection] = starting_tile.connections
	
	set_tile_placed(starting_tile)
	
	while connections_left.size() > 0:
		await debug_halt()
		var current_connection:GenTileConnection = connections_left.pick_random()
		var possible_tiles:Array[GenTile]
		
		# Find tiles that have the same connection ID and opposite direction
		for scene in current_connection.possible_tiles:
			var tile := create_tile(scene)
			for potential_connection in tile.connections:
				if potential_connection.connection_id == current_connection.connection_id:
					possible_tiles.append(tile)
		
		# Keep picking random tiles until we find one that fits or run out of options
		var chosen_tile:GenTile = null
		var desired_position:Vector3
		var desired_rotation:float
		var chosen_connection:GenTileConnection = null
		while possible_tiles.size() > 0:
			var current_tile:GenTile = possible_tiles.pick_random()
			# We did this earlier but it'll be kind of a hassle to store the result.
			# If it's slow, this is the place to start.
			var opposite_connections = current_tile.connections.filter(func(connection): return connection.connection_id == current_connection.connection_id)
			await get_tree().physics_frame
			while opposite_connections.size() > 0:
				var end = false
				var current_opposite_connection:GenTileConnection = opposite_connections.pick_random()
				desired_rotation = atan2((-current_opposite_connection.direction).z, (-current_opposite_connection.direction).x) - atan2(current_connection.direction.z, current_connection.direction.x)
				current_tile.global_rotation = Vector3(0, desired_rotation, 0)
				desired_position = current_connection.global_position - current_opposite_connection.global_position
				current_tile.global_position = desired_position
				await debug_halt()
				#var current_transform = current_tile.global_transform.translated(desired_position)
				if not map_size.has_point(current_tile.collision_shape.global_position):
					opposite_connections.erase(current_opposite_connection)
					end = true
					break
				
				var query := PhysicsShapeQueryParameters3D.new()
				query.collide_with_areas = true
				query.collide_with_bodies = false
				query.collision_mask = 4
				query.shape_rid = current_tile.collision_shape.shape.get_rid()
				query.exclude = [current_connection.tile.area.get_rid()]
				query.transform = current_tile.collision_shape.global_transform
				var space_state = get_world_3d().direct_space_state
				#
				#var results = space_state.intersect_shape(query)
				#var shape_cast:ShapeCast3D = ShapeCast3D.new()
				#shape_cast.shape = current_tile.collision_shape.shape
				#shape_cast.collide_with_areas = true
				#shape_cast.collide_with_bodies = false
				#add_child(shape_cast)
				#shape_cast.position = current_tile.collision_shape.global_position
				#shape_cast.collision_mask = 4
				#
				#shape_cast.force_shapecast_update()
				
				var results = space_state.intersect_shape(query)
				
				for result in results:
					#var node = instance_from_id(result.collider_id)
					#var parent = node.get_parent()
					var parent = result.collider.get_parent()
					#print(result.collider.name + ", " + str(result.shape))
					if parent is GenTile and placed_tiles.has(parent) and parent != current_tile and parent != current_connection.tile:
						opposite_connections.erase(current_opposite_connection)
						#print("Tile " + current_tile.name + " intersects tile " + parent.name)
						end = true
						break
				
				#shape_cast.queue_free()
					
					#if placed_tile.intersecting_tiles.has(current_tile):
						#opposite_connections.erase(current_opposite_connection)
						#print("Tile " + current_tile.name + " intersects tile " + placed_tile.name)
						#end = true
						#break
				
				if end:
					current_tile.position = Vector3.ZERO
					continue
				
				chosen_connection = current_opposite_connection
				break
			
			possible_tiles.erase(current_tile)
			
			if chosen_connection:
				chosen_tile = current_tile
				#possible_tiles.erase(chosen_tile)
				break
		
		if chosen_tile:
			chosen_tile.global_position = desired_position
			set_tile_placed(chosen_tile)
			for connection in chosen_tile.connections:
				connection.direction = connection.direction.rotated(Vector3.UP, desired_rotation)
				if connection == chosen_connection:
					continue
				connections_left.append(connection)
			#connections_left.erase(chosen_connection)
		
		connections_left.erase(current_connection)
	
	cleanup_temp_tiles()
	#if bake_navmesh:
		#var baking_regions:Array[NavigationRegion3D] = []
		#for tile in placed_tiles:
			#for child in tile.get_children():
				#if child is not NavigationRegion3D:
					#continue
				#
				#child.bake_navigation_mesh(true)
				#baking_regions.append(child)
		#
		#while true:
			#for region in baking_regions:
				#if region.is_baking():
					#await get_tree().process_frame
					#continue
			#break
	
	generation_finished.emit()

func create_tile(scene:PackedScene) -> GenTile:
	var tile:GenTile = scene.instantiate() as GenTile
	temp_tiles.append(tile)
	add_child(tile)
	tile.global_position = Vector3.ZERO
	tile.collision_shape.disabled = true
	if debug_step:
		tile.hide()
	return tile

func cleanup_temp_tiles():
	for tile in temp_tiles:
		if not placed_tiles.has(tile):
			tile.queue_free()

func set_tile_placed(tile:GenTile):
	placed_tiles.append(tile)
	temp_tiles.erase(tile)
	tile.collision_shape.disabled = false
	if debug_step:
		tile.show()

func debug_halt():
	if debug_step:
		while true:
			await get_tree().process_frame
			if Input.is_action_just_pressed("debug_step"):
				break
	return null
