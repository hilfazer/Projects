extends Panel

const UnitCreationDatumGd    = preload("res://core/UnitCreationDatum.gd")
const ModuleGd               = preload("res://core/Module.gd")

signal madeCharacter( creationDatum )


var _module : ModuleGd


func initialize( module : ModuleGd ):
	assert( module )
	_module = module

	for unitPath in module.getUnitsForCreation():
		$"UnitChoice".add_item( unitPath )


func makeCharacter():
	self.queue_free()

	var unitName : String = $"UnitChoice".get_item_text( $"UnitChoice".get_selected() )
	var unitFilename = _module.getUnitFilename( unitName )

	if unitFilename.empty():
		return

	var unitNode__ = load( unitFilename ).instance()
	var unitTexture = unitNode__.getIcon()
	unitNode__.free()

	var creationDatum := UnitCreationDatumGd.new(
		unitName,
		unitTexture
	)

	emit_signal( "madeCharacter", creationDatum )
