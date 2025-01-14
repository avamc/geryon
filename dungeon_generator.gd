extends Node2D
#Generate Rooms for dungeon

#Holds all of the rooms, in order
var rooms = []
var completed_rooms = []
var incomplete_rooms = []
var main_rooms = []
var branch_rooms = []

#amt of main rooms
var main_rooms_goal = 30
var num_main_rooms = 0
var main_rooms_completed = false
var final_room = false

var dungeonCompleted = false

@export var main_branch_chance = 0.3
@export var branch_branch_chance = 0.2

func _ready():
	randomize() #Generate new random seed
	
	#Generate Rooms loop
	while not dungeonCompleted:
		if not main_rooms_completed:
			generate_rooms()
		else: #main rooms are complete
			#make last main room the final room
			main_rooms[-1].set_room_type(3)
			final_room = true
			#finish the branches
			generate_branch_rooms()
			break
	print("DONE!")

func generate_branch_rooms():
	for room in main_rooms:
		if room.branches == true:
			pass
	pass
	#finish generating the branches for the main rooms? idk.

#0:MAIN, 1:BRANCH, 2:DEADEND, 3:FINAL
func generate_rooms():
	if num_main_rooms == main_rooms_goal:
		print("main rooms filled.")
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
		print("First room generated")
	else:
		var currentRoom = main_rooms[room_number] #get the last room created
		var typeChance = randf() #generate random number
		
		if not currentRoom.completed: #make sure the room isn't completed
			match currentRoom.roomType:
				
				#GENERATE ROOM(S) FROM MAIN
				currentRoom.RoomType.MAIN: #30% chance of a branch. Branches into a MAIN & BRANCH

					if typeChance >= main_branch_chance and not main_rooms_completed: #Branch
						#print("branching into branch and main")
						currentRoom.branches = true
						var nextBranchRoom = Room.new(1) #branch type
						var nextMainRoom = Room.new(0) #main type
						#set neighbors
						if currentRoom.set_neighbor(nextBranchRoom, rooms):
							print("neighbor set")
							#neighbor set successfully
							branch_rooms.append(nextBranchRoom)
							rooms.append(nextBranchRoom)
						else:
							print("neighbor not set")
						
						if currentRoom.set_neighbor(nextMainRoom, rooms):
							print("neighbor set")
							main_rooms.append(nextMainRoom)
							rooms.append(nextMainRoom)
							num_main_rooms += 1
						else:
							print("neighbor not set")
						
					if typeChance <= main_branch_chance and not main_rooms_completed: #Don't Branch. Still create new main room
						#print("no branch, creating new main room")
						currentRoom.branches = false
						var nextMainRoom = Room.new(0)
						#set neighbor
						if currentRoom.set_neighbor(nextMainRoom, rooms):
							rooms.append(nextMainRoom)
							main_rooms.append(nextMainRoom)
							num_main_rooms += 1
						else:
							print("neighbor not set")

				#GENERATE ROOM(S) FROM BRANCH
				currentRoom.RoomType.BRANCH: #20% chance of a branch
					if typeChance >= branch_branch_chance: #Branches into 2 branches
						#print("branching into 2 branches")
						currentRoom.branches = true
						var nextBranchRoom1 = Room.new(1)
						var nextBranchRoom2 = Room.new(1)
						
						if currentRoom.set_neighbor(nextBranchRoom1):
							branch_rooms.append(nextBranchRoom1)
							rooms.append(nextBranchRoom1)
						
						if currentRoom.set_neighbor(nextBranchRoom2):
							branch_rooms.append(nextBranchRoom2)
							rooms.append(nextBranchRoom2)
					else:
						#print("dead end")
						currentRoom.branches = false
						#set type as deadend
						currentRoom.set_room_type(2)
						
			#Take out of incomplete rooms and add to completed
			incomplete_rooms.remove_at(room_number)
			completed_rooms.append(currentRoom)
			
func _process(delta):
	pass
	#queue_redraw()

func _draw():
	#for room in completed_rooms:
		#position, size
		#draw_rect(Rect2(room.position, room.size), Color.YELLOW_GREEN)
		#draw_rect(Rect2(room.position, room.size), Color.GREEN, false)
		
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
			
	for room in branch_rooms:
		draw_rect(Rect2(room.position, room.size), Color.GREEN)
