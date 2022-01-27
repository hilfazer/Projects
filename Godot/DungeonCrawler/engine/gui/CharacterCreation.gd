extends Panel

const UnitCreationDataGd    = preload("res://engine/units/UnitCreationData.gd")
const ModuleGd               = preload("res://engine/Module.gd")

signal madeCharacter( creationDatum )


var _module : ModuleGd
onready var _unitChoice = $"UnitChoice"


func initialize( module : ModuleGd ):
	assert( module )
	_module = module

	for unitPath in module.getUnitsForCreation():
		_unitChoice.add_item( unitPath )


func makeCharacter() -> UnitCreationDataGd:
	self.queue_free()

	var unitName : String = _unitChoice.get_item_text( _unitChoice.get_selected() )
	var unitFilename = _module.getUnitFilename( unitName )

	if unitFilename.empty():
		return null

	var unitNode__ = load( unitFilename ).instance()
	var unitTexture = unitNode__.getIcon()
	unitNode__.free()

	var creationDatum := UnitCreationDataGd.new(
		unitName,
		unitTexture
	)

	emit_signal( "madeCharacter", creationDatum )
	return creationDatum
