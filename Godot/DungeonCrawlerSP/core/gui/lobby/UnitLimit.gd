extends Label


const UnitCountPrefix = "Units : "

var _maxUnits = 0
var _currentUnits = 0


func _ready():
	refreshText()


func setMaximum( maximum ):
	_maxUnits = maximum
	refreshText()


func setCurrent( current ):
	_currentUnits = current
	refreshText()


func refreshText():
	self.text = ( UnitCountPrefix + str(_currentUnits) + "/" + str(_maxUnits) )
