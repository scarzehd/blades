extends Node3D
class_name TileGenerator

@export var starting_tile:GenTile
@export var map_size:AABB

var temp_tiles:Array[GenTile]

var placed_tiles:Array[GenTile]

## Set pieces are tiles that are guaranteed to generate exactly once.
## Currently, only the first set piece is used.
@export_file("*.tscn") var set_pieces:Array[String]
@export var set_piece_distance:Array[int]

@export var debug_step:bool = false

signal generation_finished

func _ready() -> void:
	generate()

func generate():
	randomize()
	var connections_left:Array[GenTileConnection] = starting_tile.connections
	
	set_tile_placed(starting_tile)
	
	# Generate set pieces
	
	if set_pieces.size() > 0 and set_pieces.size() == set_piece_distance.size():
		var current_tile:GenTile = starting_tile
		var set_piece_scene = set_pieces[0]
		var set_piece:GenTile = create_tile(load(set_piece_scene))
		var target_distance = set_piece_distance[0]
		var distance_traveled := 0
		while distance_traveled < target_distance:
			distance_traveled += 1
			await debug_halt()
			var current_connection:GenTileConnection = current_tile.connections.pick_random()
			var possible_tiles:Array[GenTile]
			var possible_tile_scenes:Array[String]
			var weights:Array[float]
			
			# Find tiles that have the same connection ID, and can lead to the set piece
			for i in range(current_connection.possible_tiles.size()):
				var scene = current_connection.possible_tiles[i]
				var tile := create_tile(scene)
				
				var matching_self = false
				var matching_set_piece = false
				
				#if scene.resource_path == set_piece_scene_path:
					#matching_set_piece = true
				
				for potential_connection in tile.connections:
					if not matching_set_piece:
						for connection in set_piece.connections:
							if connection.connection_id == potential_connection.connection_id:
								matching_set_piece = true
								break
						#for tile_scene in potential_connection.connection_data.possible_tiles:
							#if tile_scene == set_piece_scene:
								#matching_set_piece = true
								#break
						if matching_set_piece:
							continue # If there's a connection matching self, that connection can't also connect to the set piece
					if potential_connection.connection_id == current_connection.connection_id and not matching_self:
						matching_self = true
					
				
				if matching_self and matching_set_piece:
					possible_tiles.append(tile)
					weights.append(current_connection.weights[i])
					possible_tile_scenes.append(scene.resource_path)
			
			# Keep picking random tiles until we find one that fits or run out of options
			var chosen_tile:GenTile = null
			var chosen_connection:GenTileConnection = null
			while possible_tiles.size() > 0:
				var new_tile:GenTile = Utils.pick_random_weighted(possible_tiles, weights)
				# We did this earlier but it'll be kind of a hassle to store the result.
				# If it's slow, this is the place to start.
				var opposite_connections = new_tile.connections.filter(func(connection): return connection.connection_id == current_connection.connection_id)
				await get_tree().physics_frame
				while opposite_connections.size() > 0:
					var end = false
					var current_opposite_connection:GenTileConnection = opposite_connections.pick_random()
					match_connections(current_connection, current_opposite_connection, new_tile)
					await debug_halt()
					if not map_size.has_point(new_tile.collision_shape.global_position):
						opposite_connections.erase(current_opposite_connection)
						end = true
						break
					
					await get_tree().physics_frame
					var results = check_tile_collision(new_tile)
					
					for result in results:
						if result != current_connection.tile:
							opposite_connections.erase(current_opposite_connection)
							end = true
							break

					if end:
						new_tile.position = Vector3.ZERO
						continue
					
					chosen_connection = current_opposite_connection
					break
				
				if chosen_connection:
					chosen_tile = new_tile
					break
				
				var i = possible_tiles.find(new_tile)
				possible_tiles.erase(new_tile)
				possible_tile_scenes.remove_at(i)
				weights.remove_at(i)
			
			if chosen_tile:
				set_tile_placed(chosen_tile)
				for connection in chosen_tile.connections:
					if connection == chosen_connection:
						continue
					connections_left.append(connection)
				connections_left.erase(chosen_connection)
				current_tile = chosen_tile
				connections_left.erase(current_connection)
				#if possible_tile_scenes[possible_tiles.find(chosen_tile)] == set_piece_scene_path:
					#placed = true
					#distance_traveled = target_distance
		#if not placed:
		var set_piece_connections:Array[StringName]
		for connection in set_piece.connections:
			if not set_piece_connections.has(connection.connection_id):
				set_piece_connections.append(connection.connection_id)
		
		var possible_connections:Array[GenTileConnection] = connections_left.filter(func(connection): return set_piece_connections.has(connection.connection_id))
		
		while possible_connections.size() > 0:
			var current_connection:GenTileConnection = possible_connections.pick_random()
			possible_connections.erase(current_connection)
			connections_left.erase(current_connection)
			var possible_opposite_connections:Array[GenTileConnection] = set_piece.connections.filter(func(connection): return connection.connection_id == current_connection.connection_id)
			
			while possible_opposite_connections.size() > 0:
				var current_opposite_connection:GenTileConnection = possible_opposite_connections.pick_random()
				possible_opposite_connections.erase(current_opposite_connection)
				
				match_connections(current_connection, current_opposite_connection, set_piece)
				await get_tree().physics_frame
				var results = check_tile_collision(set_piece)
				var end = false
				for result in results:
					if result == current_connection.tile:
						continue
					end = true
					break
				
				if end:
					continue
				#if check_tile_collision(set_piece):
					#print(true)
					#continue
				
				set_tile_placed(set_piece)
				for connection in set_piece.connections:
					if connection == current_opposite_connection:
						continue
					connections_left.append(connection)
				connections_left.erase(current_connection)
	
	while connections_left.size() > 0:
		await debug_halt()
		var current_connection:GenTileConnection = connections_left.pick_random()
		var possible_tiles:Array[GenTile]
		var weights:Array[float]
		
		# Find tiles that have the same connection ID
		for i in range(current_connection.possible_tiles.size()):
			var scene = current_connection.possible_tiles[i]
			var tile := create_tile(scene)
			for potential_connection in tile.connections:
				if potential_connection.connection_id == current_connection.connection_id:
					possible_tiles.append(tile)
					weights.append(current_connection.weights[i])
					break
		
		# Keep picking random tiles until we find one that fits or run out of options
		var chosen_tile:GenTile
		var chosen_connection:GenTileConnection
		while possible_tiles.size() > 0:
			var current_tile:GenTile = Utils.pick_random_weighted(possible_tiles, weights)
			# We did this earlier but it'll be kind of a hassle to store the result.
			# If it's slow, this is the place to start.
			var opposite_connections = current_tile.connections.filter(func(connection): return connection.connection_id == current_connection.connection_id)
			await get_tree().physics_frame
			while opposite_connections.size() > 0:
				var end = false
				var current_opposite_connection:GenTileConnection = opposite_connections.pick_random()
				match_connections(current_connection, current_opposite_connection, current_tile)
				await debug_halt()
				if not map_size.has_point(current_tile.collision_shape.global_position):
					opposite_connections.erase(current_opposite_connection)
					end = true
					break
				
				await get_tree().physics_frame
				var results = check_tile_collision(current_tile)
				
				for result in results:
					if result != current_connection.tile:
						opposite_connections.erase(current_opposite_connection)
						end = true
						break

				if end:
					current_tile.position = Vector3.ZERO
					continue
				
				chosen_connection = current_opposite_connection
				break
			
			var i = possible_tiles.find(current_tile)
			possible_tiles.erase(current_tile)
			weights.remove_at(i)
			
			if chosen_connection:
				chosen_tile = current_tile
				break
		
		if not chosen_tile:
			chosen_tile = create_tile(load(current_connection.connection_data.fallback_tile))
			chosen_connection = chosen_tile.connections[0]
			match_connections(current_connection, chosen_connection, chosen_tile)
		
		if chosen_tile:
			set_tile_placed(chosen_tile)
			for connection in chosen_tile.connections:
				if connection == chosen_connection:
					continue
				connections_left.append(connection)
			connections_left.erase(chosen_connection)
		
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

func match_connections(current_connection:GenTileConnection, opposite_connection:GenTileConnection, opposite_tile:GenTile):
	var desired_rotation = atan2((-opposite_connection.direction).z, (-opposite_connection.direction).x) - atan2(current_connection.direction.z, current_connection.direction.x)
	opposite_tile.global_rotation = Vector3(0, desired_rotation, 0)
	opposite_tile.global_position = current_connection.global_position - opposite_connection.global_position

func check_tile_collision(tile:GenTile) -> Array[GenTile]:
	var query := PhysicsShapeQueryParameters3D.new()
	query.collide_with_areas = true
	query.collide_with_bodies = false
	query.collision_mask = 4
	query.shape_rid = tile.collision_shape.shape.get_rid()
	query.exclude = [tile.area.get_rid()]
	query.transform = tile.collision_shape.global_transform
	var space_state = get_world_3d().direct_space_state
	var results = space_state.intersect_shape(query)
	
	var tiles:Array[GenTile]
	
	for result in results:
		var parent = result.collider.get_parent()
		if parent is GenTile and placed_tiles.has(parent):
			tiles.append(parent)
	
	return tiles
