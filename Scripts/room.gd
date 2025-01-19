class_name Room
extends Node2D

@export var tilemap:TileMapLayer

var tile_size:int
var actual_size:Vector2i
var cells:int
var neighbor:Room #idk
var size:Vector2i
var grid_position:Vector2i

var max_width = 30
var min_width = 15
var max_height = 25
var min_height = 15

#Door options
var neighbors = []
var northNeighbor:Room
var westNeighbor:Room
var eastNeighbor:Room
var southNeighbor:Room

#the path coming out of the room..?
var branch_path = []

#Amt of overlaps the room has. 
var room_overlaps = 0

#If the room & neighbors are completed.
var completed = false

enum RoomType {MAIN, BRANCH, DEADEND, FINAL}
var roomType

var branches
var first_room = false
var final_room = false

var door_positions = []
var doors = []

#Called by room.new()
func _init(_type):
	randomize()
	#Assign roomType
	if _type == 0:
		roomType = RoomType.MAIN
	elif _type == 1:
		roomType = RoomType.BRANCH
	elif _type == 2:
		roomType = RoomType.DEADEND
	elif _type == 3:
		roomType = RoomType.FINAL
		final_room = true
		
	#Assign size
	actual_size = Vector2(randf_range(min_width, max_width), randf_range(min_height, max_height))
	
	#Make it so that the rooms are all odd sizes. So that the doors go in middle
	while not actual_size.x%2:
		actual_size.x = randf_range(min_width, max_width)
	while not actual_size.y%2:
		actual_size.y = randf_range(min_height, max_height)
	size = Vector2(30, 30)

func set_first_room():
	first_room = true
	position = Vector2(0,0)
	grid_position = Vector2(0,0)
	
func set_room_type(_type):
	if _type == 0:
		roomType = RoomType.MAIN
	elif _type == 1:
		roomType = RoomType.BRANCH
	elif _type == 2:
		roomType = RoomType.DEADEND
	elif _type == 3:
		roomType = RoomType.FINAL
		final_room = true

func set_neighbor(neighbor, rooms):
	#NO ONE CAN HAVE WEST NEIGHBOR!..?
	var neighborChance = randf()
	if neighborChance < 0.3: #NORTH
		if not northNeighbor: 
			if add_north_neighbor(neighbor, rooms):
				return true
			else:
				pass
		elif not eastNeighbor: 
			if add_east_neighbor(neighbor, rooms):
				return true
			else:
				pass
		elif not southNeighbor: 
			if add_south_neighbor(neighbor, rooms):
				return true
			else:
				pass
		else: #Room full of neighbors. #Use later in case of error?
			print("no neighbor added")
			return false

	if neighborChance > 0.3 and neighborChance < 0.6: #EAST
		if not eastNeighbor: 
			if add_east_neighbor(neighbor, rooms):
				return true
			else:
				pass
		elif not northNeighbor: 
			if add_north_neighbor(neighbor, rooms):
				return true
			else:
				pass
			
		elif not southNeighbor: 
			if add_south_neighbor(neighbor, rooms):
				return true
			else:
				pass
		else:
			print("no neighbor added")
			return false
			
	if neighborChance > 0.6: #SOUTH
		if not southNeighbor:
			if add_south_neighbor(neighbor, rooms):
				return true
			else:
				pass
		elif not eastNeighbor: 
			if add_east_neighbor(neighbor, rooms):
				return true
			else:
				pass
		elif not northNeighbor: 
			if add_north_neighbor(neighbor, rooms):
				return true
			else:
				pass
		else:
			print("no neighbor added")
			return false
	
func overlaps(rooms):
	var overlaps = false
	for room in rooms:
		if position == room.position and self != room:
			overlaps = true
			return true
			break
	if overlaps == false:
		return false
			
func add_north_neighbor(neighbor, rooms):
	#set neighbor's position
	neighbor.position.x = self.position.x
	neighbor.position.y = self.position.y - neighbor.size.y
	neighbor.grid_position.x = self.grid_position.x
	neighbor.grid_position.y = self.grid_position.y - 1
	
	if not neighbor.overlaps(rooms):
		northNeighbor = neighbor
		neighbor.southNeighbor = self
		return true
	else:
		return false

func add_south_neighbor(neighbor, rooms):
	#set neighbor's position
	neighbor.position.x = self.position.x
	neighbor.position.y = self.position.y + self.size.y
	neighbor.grid_position.x = self.grid_position.x
	neighbor.grid_position.y = self.grid_position.y + 1
	
	if not neighbor.overlaps(rooms):
		southNeighbor = neighbor
		neighbor.northNeighbor = self
		return true
	else:
		return false
			
func add_east_neighbor(neighbor, rooms):
	#set neighbor's position
	neighbor.position.x = self.position.x + self.size.x
	neighbor.position.y = self.position.y
	neighbor.grid_position.x = self.grid_position.x + 1
	neighbor.grid_position.y = self.grid_position.y
	
	if not neighbor.overlaps(rooms):
		eastNeighbor = neighbor
		neighbor.westNeighbor = self
		return true
	else:
		return false
		
func get_branch_path_start(rooms):
	#Go through all rooms
	for room in rooms:
		#Check each room in the room's branch path
		for branch in room.branch_path:
			if self == branch:
				#It's in this room's path.
				return room.branch_path[0]
				
func add_branch_room(room):
	room.branch_path.append(room)
		
func get_room_neighbors():
	if neighbors.size() == 0:
		return false
	else:
		return neighbors
	
func get_room_type():
	return roomType
	
func room_complete():
	return completed
	
func create_floor(tile_map, _player):
	for x in actual_size.x:
		for y in actual_size.y:
			tile_map.set_cell(Vector2i(y, -x), 0, Vector2i(1, 0))
	var player_position = Vector2(actual_size.x/2, 40)
	return player_position
	#Create the room with tileset. 
	
func set_first_room_west_door(tile_map):
	var x = 1
	var y = actual_size.y/2
	tile_map.set_cell(Vector2i(x, y - 2), 0, Vector2i(0, 6)) #top
	tile_map.set_cell(Vector2i(x, y-1), 0, Vector2i(1, 4)) #middle blocked
	tile_map.set_cell(Vector2i(x, y), 0, Vector2i(3, 6)) #bottom
	return Vector2(x, y-1)
	#Don't add a collider or anything.
	
func create_doors(tile_map):
	#IF FIRST ROOM, add start room as west room? Or have a blocked exit there.
	#set_cell(LOCATION, SOURCE, ATLAS COORDS)
	if northNeighbor: 
		var middle = actual_size.x/2
		tile_map.set_cell(Vector2i(middle, -1), 0, Vector2i(1, 4)) #right
		tile_map.set_cell(Vector2i(middle + 2, -1), 0, Vector2i(2, 4)) #left
		#(Vector2i(middle, -1))
		var northDoor = DungeonDoor.new("north", northNeighbor, (Vector2i(middle+1, -2)))
		doors.append(northDoor)
	if southNeighbor:
		var middle = actual_size.x/2
		var y = actual_size.y - 2
		tile_map.set_cell(Vector2i(middle, y), 0, Vector2i(1, 4)) #right
		tile_map.set_cell(Vector2i(middle + 2, y), 0, Vector2i(2, 4)) #left
		#(Vector2i(middle, y+1))
		var southDoor = DungeonDoor.new("south", southNeighbor, (Vector2i(middle, y+2)))
		doors.append(southDoor)
	if westNeighbor:
		var x = 1
		var y = actual_size.y/2
		tile_map.set_cell(Vector2i(x, y - 2), 0, Vector2i(0, 4)) #top
		tile_map.set_cell(Vector2i(x, y), 0, Vector2i(3, 4)) #bottom
		var westDoor = DungeonDoor.new("west", westNeighbor, (Vector2i (x-2, y)))
		doors.append(westDoor)
	if eastNeighbor:
		var x = actual_size.x
		var y = actual_size.y/2
		tile_map.set_cell(Vector2i(x, y - 2), 0, Vector2i(0, 4)) #top
		tile_map.set_cell(Vector2i(x, y), 0, Vector2i(3, 4)) #bottom
		#(Vector2i(x-1, y-1))
		var eastDoor = DungeonDoor.new("east", eastNeighbor, (Vector2i(x, y-1)))
		doors.append(eastDoor)
	#return list of Door objects instead?
	return doors
