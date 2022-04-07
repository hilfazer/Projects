extends KinematicBody2D

const SPEED = 100
var direction := Vector2.DOWN


func _ready():
# warning-ignore:return_value_discarded
	$"Timer".connect("timeout", self, "_change_direction")
	$"Timer".start()


func _physics_process(delta):
# warning-ignore:return_value_discarded
	move_and_collide(direction * delta * SPEED)


func _change_direction():
	direction = Vector2.DOWN if direction == Vector2.UP else Vector2.UP
