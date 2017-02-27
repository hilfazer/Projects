extends "res://units/Agent.gd"

const TankGd = preload("res://units/tank.gd")

var m_motion = TankGd.MOTION.DOWN


func _process(delta):
	pass

func processMovement():
	m_tank.setMotion( m_motion )
	
	
func processFiring():
	pass
