extends Node2D

@export var playerScene:PackedScene
#@export var doorScene:PackedScene

var dungeon:Dungeon
@export var floor_tile_map:TileMapLayer
@export var walls_tile_map:TileMapLayer

var first_room_loaded = false
var player
var doors = []
var currentRoom
var roomFrom
var coolDownDoor

# Called when the node enters the scene tree for the first time.
func _ready():
	player = playerScene.instantiate()
	add_child(player)
	player.position = $PlayerSpawnpoint.position
	dungeon = Dungeon.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(walls_tile_map.local_to_map(player.position))
	#print(player.position)
	pass

#Load First Room
func _on_door_area_entered(area):
	#Entered the first door to get into the dungeon.
	$Door.queue_free()
	
	#player.position = (floor_tile_map.local_to_map(y/2, -1))
	floor_tile_map.clear()
	walls_tile_map.clear()
	
	if not first_room_loaded:
		#Load the first room. Dungeon generates rooms from tilemap parameters.
		currentRoom = dungeon.load_first_room(floor_tile_map, walls_tile_map, player)
		doors = dungeon.get_room_doors(currentRoom)
		var player_position = currentRoom.set_first_room_west_door(walls_tile_map)
		player.position = walls_tile_map.map_to_local(player_position)
	load_doors()

#Load the next dungeon room.
func on_room_entered(roomTo, room_direction):
	roomFrom = currentRoom
	#Get rid of last doors.
	for door in doors:
		door.delete()
	doors.clear()
	#Clear tilemap.
	floor_tile_map.clear()
	walls_tile_map.clear()

	#LOAD NEW ROOM!
	currentRoom = dungeon.load_room(roomTo)
	doors = dungeon.get_room_doors(currentRoom)
	
	if currentRoom.first_room:
		currentRoom.set_first_room_west_door(walls_tile_map)
		
	print(currentRoom.roomType)
	
	load_doors()
	
	for door in doors:
		if door.roomTo == roomFrom:
			coolDownDoor = door
			#Set player's position to this door.
			player.position = walls_tile_map.map_to_local(door.grid_position)
			door.area.monitoring = false
			$RoomCooldownTimer.start()

func load_doors():
	for door in doors:
		door.room_entered.connect(on_room_entered)
		var door_area = door.create()
		door_area.position = walls_tile_map.map_to_local(door.grid_position)
		add_child(door_area)


func _on_room_cooldown_timer_timeout():
	coolDownDoor.area.monitoring = true
