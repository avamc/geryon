class_name Room
extends Node2D

@export var tilemap:TileMapLayer

var tile_size:int
var actual_size:Vector2i
var cells:int
var neighbor:Room #idk
var size:Vector2i
var grid_position:Vector2i

var max_width = 60
var min_width = 20
var max_height = 60
var min_height = 20

#Door options
var neighbors = []
var northNeighbor:Room
var westNeighbor:Room
var eastNeighbor:Room
var southNeighbor:Room

#If the room & neighbors are completed.
var completed = false

enum RoomType {MAIN, BRANCH, DEADEND, FINAL}
var roomType

var branches
var first_room = false
var final_room = false

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
	size = Vector2(30, 30)
	#Location if first room
	if first_room == true:
		#position is a property of Node2D
		position = Vector2(0,0)
		grid_position = Vector2(0,0)
	
func set_first_room():
	first_room = true
	
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
		if not northNeighbor and not overlaps(rooms): 
			add_north_neighbor(neighbor)
			return true
		elif not eastNeighbor and not overlaps(rooms): 
			add_east_neighbor(neighbor)
			return true
		elif not southNeighbor: 
			add_south_neighbor(neighbor)
			return true
		else: 
			#print("Room full of neighbors. New neighbor was not added.")
			return false

	if neighborChance > 0.3 and neighborChance < 0.6: #EAST
		if not eastNeighbor and not overlaps(rooms): 
			add_east_neighbor(neighbor)
			return true
		elif not northNeighbor and not overlaps(rooms): 
			add_north_neighbor(neighbor)
			return true
		elif not southNeighbor and not overlaps(rooms): 
			add_south_neighbor(neighbor)
			return true
		else:
			#print("Room full of neighbors. New neighbor was not added.")
			return false
	if neighborChance > 0.6: #SOUTH
		if not southNeighbor and not overlaps(rooms): 
			add_south_neighbor(neighbor)
			return true
		elif not eastNeighbor and not overlaps(rooms): 
			add_east_neighbor(neighbor)
			return true
		elif not northNeighbor and not overlaps(rooms): 
			add_north_neighbor(neighbor)
			return true
		else:
			#print("Room full of neighbors. New neighbor was not added.")
			return false
	
func overlaps(rooms):
	for room in rooms:
		if grid_position == room.grid_position:
			return true
		else:
			return false
			
func add_north_neighbor(neighbor):
	northNeighbor = neighbor
	neighbor.southNeighbor = self
	#set neighbor's position
	neighbor.position.x = self.position.x
	neighbor.position.y = self.position.y - neighbor.size.y
	neighbor.grid_position.x = self.grid_position.x
	neighbor.grid_position.y = self.grid_position.y - 1

func add_south_neighbor(neighbor):
	southNeighbor = neighbor
	neighbor.northNeighbor = self
	#set neighbor's position
	neighbor.position.x = self.position.x
	neighbor.position.y = self.position.y + self.size.y
	neighbor.grid_position.x = self.grid_position.x
	neighbor.grid_position.y = self.grid_position.y + 1
			
func add_east_neighbor(neighbor):
	eastNeighbor = neighbor
	neighbor.westNeighbor = self
	#set neighbor's position
	neighbor.position.x = self.position.x + self.size.x
	neighbor.position.y = self.position.y
	neighbor.grid_position.x = self.grid_position.x + 1
	neighbor.grid_position.y = self.grid_position.y
		
func get_room_neighbors():
	if neighbors.size() == 0:
		return false
	else:
		return neighbors
	
func get_room_type():
	print(roomType)
	return roomType
	
func room_complete():
	return completed
	
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
