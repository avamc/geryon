extends Node2D
#Generate Rooms for dungeon

#Holds all of the rooms, in order
var rooms = []
var completed_rooms = []
var incomplete_rooms = []

var dungeonCompleted = false

@export var main_branch_chance = 0.3
@export var branch_branch_chance = 0.2

func _ready():
	randomize() #Generate new random seed
	
	#Generate Rooms loop
	while not dungeonCompleted:
		generate_rooms()
	print("DONE!")

#0:MAIN, 1:BRANCH, 2:DEADEND, 3:FINAL
func generate_rooms():
	#FIRST ROOM
	#create first room if no rooms yet
	if rooms.size() == 0:
		var currentRoom = Room.new(0)
		currentRoom.set_first_room()
		rooms.append(currentRoom)
		incomplete_rooms.append(currentRoom)
	else:
		var currentRoom = rooms[-1] #get the last room created
		var typeChance = randf() #generate random number
		
		if not currentRoom.completed:
			match currentRoom.roomType:
				currentRoom.RoomType.MAIN: #30% chance of a branch. Branches into a MAIN & BRANCH
					if typeChance >= main_branch_chance: #Branch
						currentRoom.branches = true
						var nextBranchRoom = Room.new(1)
						var nextMainRoom = Room.new(0)
						#set neighbors
						currentRoom.set_neighbor(nextBranchRoom)
						currentRoom.set_neighbor(nextMainRoom)
					else: #Don't Branch. Still create new main room
						currentRoom.branches = false
						var currentMainRoom = Room.new(0)
						#set neighbor
						currentRoom.set_neighbor(currentMainRoom)

				currentRoom.RoomType.BRANCH: #20% chance of a branch
					if typeChance >= branch_branch_chance: #Branches into 2 branches
						currentRoom.branches = true
						var nextBranchRoom1 = Room.new(1)
						var nextBranchRoom2 = Room.new(1)
					else:
						currentRoom.branches = false
						#set type as deadend
						currentRoom.set_room_type(2)
		else: #room is completed
			pass
			
