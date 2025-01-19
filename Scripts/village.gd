extends Node2D

@export var playerScene:PackedScene
@export var dungeonRoom:PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	var player = playerScene.instantiate()
	add_child(player)
	player.position = $PlayerSpawnpoint.position
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_dungeon_entrance_area_entered(area):
	print("door entered")
	dungeonRoom.instantiate()
	get_tree().change_scene_to_file("res://Scenes/dungeon_start_room.tscn")
