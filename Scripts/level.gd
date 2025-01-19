class_name Level
extends Node2D

#@onready var player_spawnpoint = %PlayerSpawnpoint

# Called when the node enters the scene tree for the first time.
func _init(playerScene, spawnpoint):
	var player = playerScene.instantiate()
	add_child(player)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
