class_name Dungeon
extends Node2D
#Generate Rooms for dungeon

#Holds all of the rooms, in order
var rooms = []
var completed_rooms = []
var incomplete_rooms = []
var main_rooms = []
var branch_rooms = []
var completed_branch_rooms = []

#amt of main rooms
@export var main_rooms_goal = 50
var num_main_rooms = 0
var main_rooms_completed = false
var branch_rooms_completed = false
var final_room = false
var main_room_num = 0

var dungeon_completed = false

var tile_map
var floor_tile_map
var walls_tile_map
var player

var main_branch_chance = 0.6
var branch_branch_chance = 0.6

func _init():
	randomize() #Generate new random seed

	#Generate main rooms loop
	while not main_rooms_completed:
		generate_main_rooms()
		
	main_rooms[-1].set_room_type(3)
	final_room = true
	
	while not branch_rooms_completed:
		generate_branch_rooms()
		
	while not dungeon_completed:
		generate_dead_ends()
	
	print("Dungeon Generated!")
	
#0:MAIN, 1:BRANCH, 2:DEADEND, 3:FINAL
func generate_main_rooms():
	if num_main_rooms == main_rooms_goal:
		main_rooms_completed = true
	
	var room_number = -1
	#FIRST ROOM
	#create first room if no rooms yet
	if rooms.size() == 0:
		var currentRoom = Room.new(0)
		currentRoom.set_first_room()
		rooms.append(currentRoom)
		incomplete_rooms.append(currentRoom)
		num_main_rooms = num_main_rooms + 1
		main_rooms.append(currentRoom)
		
	else:
		var currentRoom = main_rooms[room_number] #get the last room created
		if not currentRoom.completed: #make sure the room isn't completed
				
			var nextMainRoom = Room.new(0)
			#set neighbor
			if currentRoom.set_neighbor(nextMainRoom, rooms):
				rooms.append(nextMainRoom)
				main_rooms.append(nextMainRoom)
				num_main_rooms += 1

func generate_branch_rooms():

	for room in main_rooms:
		var typeChance = randf()
		#get room
		var currentRoom = main_rooms[main_room_num]
		if typeChance <= main_branch_chance: #Branch
			currentRoom.branches = true
			var nextBranchRoom = Room.new(1) #branch type
			
			#set neighbors
			if currentRoom.set_neighbor(nextBranchRoom, rooms):
				#neighbor set successfully
				branch_rooms.append(nextBranchRoom)
				rooms.append(nextBranchRoom)
				currentRoom.branch_path.append(currentRoom) #Maybe add this to init instead
				currentRoom.branch_path.append(nextBranchRoom)
		
		main_room_num += 1 #increase main_room_num by 1
		
		if main_room_num == main_rooms.size():
			branch_rooms_completed = true
			
func generate_dead_ends():
	var branch_room_num = 0
	#Go through all branch rooms in branch_rooms
	for room in branch_rooms:
		var typeChance = randf()
		var currentRoom = branch_rooms[branch_room_num]
	#Decide if it branches or not
		if typeChance <= branch_branch_chance: #Branches into 2 branches
			currentRoom.branches = true
			var nextBranchRoom1 = Room.new(1)
			var nextBranchRoom2 = Room.new(1)
			
			if currentRoom.set_neighbor(nextBranchRoom1, rooms):
				branch_rooms.append(nextBranchRoom1)
				rooms.append(nextBranchRoom1)
				completed_branch_rooms.append(nextBranchRoom1)
				var start = currentRoom.get_branch_path_start(rooms)

				start.add_branch_room(nextBranchRoom1)
			
			if currentRoom.set_neighbor(nextBranchRoom2, rooms):
				branch_rooms.append(nextBranchRoom2)
				rooms.append(nextBranchRoom2)
				completed_branch_rooms.append(nextBranchRoom2)
				var start = currentRoom.get_branch_path_start(rooms)
				
				start.add_branch_room(nextBranchRoom2)
			
			currentRoom.branches = true
			branch_rooms.pop_at(branch_room_num)

		else:
			currentRoom.branches = false
			#set type as deadend
			currentRoom.set_room_type(2)
			#If dead end, then remove from branch_rooms
			currentRoom.completed = true
			branch_rooms.pop_at(branch_room_num)

		branch_room_num += 1
	
	if branch_rooms.size() == 0:
		dungeon_completed = true
	#When branch_rooms.size() == 0, dungeon_completed = true

func load_first_room(_floor_tile_map, _walls_tile_map, _player):
	player = _player
	floor_tile_map = _floor_tile_map
	walls_tile_map = _walls_tile_map
	for room in rooms:
		if room.first_room:
			room.create_floor(_floor_tile_map, player)
			#Clear & reset dungeon door
			room.create_doors(_walls_tile_map)
			return room
			
func load_room(roomTo):
	for room in rooms:
		if room == roomTo:
			room.create_floor(floor_tile_map, player)
			room.create_doors(walls_tile_map)
			return room
	
func get_room_doors(room):
	return room.doors #return room's door objects.

func _process(delta):
	pass
	
func is_branch_room(room):
	for branch_room in branch_rooms:
		if room == branch_room:
			return true
func is_main_room(room):
	for main_room in main_rooms:
		if room == main_room:
			return true

func draw_rooms():
	#for room in completed_rooms:
		#position, size
		#draw_rect(Rect2(room.position, room.size), Color.YELLOW_GREEN)
		#draw_rect(Rect2(room.position, room.size), Color.GREEN, false)
	for room in rooms:
		if room.roomType == 2:
			draw_rect(Rect2(room.position, room.size), Color.ORANGE)
			draw_rect(Rect2(room.position, room.size), Color.ORANGE_RED, false)
		else:
			draw_rect(Rect2(room.position, room.size), Color.DARK_GREEN)
			draw_rect(Rect2(room.position, room.size), Color.GREEN, false)
		
	for room in main_rooms:
		if not room.first_room and not room.final_room:
			#position, size
			draw_rect(Rect2(room.position, room.size), Color.YELLOW)
			draw_rect(Rect2(room.position, room.size), Color.ORANGE, false)
			
		if room.first_room:
			draw_rect(Rect2(room.position, room.size), Color.BLUE)
		if room.final_room:
			draw_rect(Rect2(room.position, room.size), Color.RED)
			#draw_rect(Rect2(room.position, room.size), Color.BLUE)
