
var m_tank = null
var m_lastMotion

func _ready():
	set_process( true )


func _process(delta):
	processMovement()
	processFiring()


func assignToTank( tank ):
	m_tank = tank
	m_tank.add_child( self )
	m_lastMotion = m_tank.getMotion()
