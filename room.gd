class_name Room
extends Node2D

@export var tilemap:TileMapLayer

var tile_size:int
var size:Vector2i
var cells:int
var neighbor:Room #idk

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

func set_neighbor(neighbor):
	#NO ONE CAN HAVE WEST NEIGHBOR!..?
	var neighborChance = randf()
	if neighborChance < 0.3: #NORTH
		if not northNeighbor: #If northNeighbor is empty:
			northNeighbor = neighbor
		elif not eastNeighbor:
			eastNeighbor = neighbor
		elif not southNeighbor:
			southNeighbor = neighbor
		else: 
			return false
	if neighborChance > 0.3 and neighborChance < 0.6: #EAST
		if not eastNeighbor:
			eastNeighbor = neighbor
		elif not northNeighbor:
			northNeighbor = neighbor
		elif not southNeighbor:
			southNeighbor = neighbor
		else:
			return false
	if neighborChance > 0.6: #SOUTH
		if not southNeighbor:
			southNeighbor = neighbor
		elif not eastNeighbor:
			eastNeighbor = neighbor
		elif not northNeighbor:
			northNeighbor = neighbor
		else:
			return false


		
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
