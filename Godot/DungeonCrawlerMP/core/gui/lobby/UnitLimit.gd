extends Label


const UnitCountPrefix = "Units : "

var m_maxUnits = 0
var m_currentUnits = 0


func _ready():
	refreshText()


func setMaximum( maximum ):
	m_maxUnits = maximum
	refreshText()


func setCurrent( current ):
	m_currentUnits = current
	refreshText()


func refreshText():
	self.text = ( UnitCountPrefix + str(m_currentUnits) + "/" + str(m_maxUnits) )
