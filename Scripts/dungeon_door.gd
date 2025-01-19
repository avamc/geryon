class_name DungeonDoor
extends Node2D

#maybe make an enum? idk i don't like enums.
#@export var doorScene:PackedScene
var room_direction:String
var roomTo:Room
var grid_position
signal area_entered(area)
var area:Area2D
var collider:CollisionShape2D
var shape:RectangleShape2D

signal room_entered(room)

func _init(_direction, _roomTo, _position):
	room_direction = _direction
	roomTo = _roomTo
	grid_position = _position
	#set door's local position here too?
	
func create():
	#instantiate the door. 
	area = Area2D.new()
	collider = CollisionShape2D.new()
	shape = RectangleShape2D.new()
	collider.shape = shape
	area.add_child(collider)
	area.area_entered.connect(on_area_entered)
	return area
	#create an area2d and collider where the door is.
	#return the scene so that it can be added as a child from calling script.
	
func on_area_entered(area):
	room_entered.emit(roomTo, room_direction)

func cooldown_start():
	area.monitoring = false
	
func cooldown_end():
	area.monitoring = true
	
func delete():
	area.queue_free()
