
extends Control

const SavingModuleGd         = preload("res://core/SavingModule.gd")

const ModuleExtensions       = ["gd"]
const NoModuleString    = "..."

var _previousSceneFile                  setget deleted
var _module : SavingModuleGd            setget setModule


signal readyForGame( module, playerUnitCreationData )
signal finished()


func deleted(_a):
	assert(false)


func _ready():
	var params = SceneSwitcher._sceneParams

	moduleSelected( get_node("ModuleSelection/FileName").text )
	get_node("Lobby").connect("unitNumberChanged", self, "onUnitNumberChanged")

	if params == null:
		return

	if params.has("isHost") and params["isHost"] == true:
		get_node("ModuleSelection/SelectModule").disabled = false


func _notification( what ):
	if what == NOTIFICATION_PREDELETE:
		pass


func _input( event ):
	if event.is_action_pressed("ui_cancel"):
		emit_signal("finished")
		accept_event()


func onLeaveGamePressed():
	emit_signal("finished")


func moduleSelected( moduleDataPath : String ):
	clear()
	if moduleDataPath == NoModuleString:
		return

	assert( moduleDataPath.get_extension() in ModuleExtensions )
	if File.new().open( moduleDataPath, File.READ ) != OK:
		Debug.error( self, "Module file %s can't be opened for reading" % moduleDataPath )
		return

	var module = null
	var dataResource = load( moduleDataPath )
	if SavingModuleGd.verify( dataResource ):
		var moduleData = dataResource.new()
		module = SavingModuleGd.new( moduleData, dataResource.resource_path )

	if not module:
		Debug.error( self, "Incorrect module data file %s" % moduleDataPath )
		return


	setModule( module )
	get_node("ModuleSelection/FileName").text = moduleDataPath
	get_node("Lobby").setMaxUnits( _module.getPlayerUnitMax() )


func onUnitNumberChanged( number : int ):
	assert( number >= 0 )
	get_node("Buttons/StartGame").disabled = ( number == 0 )


func clear():
	get_node("ModuleSelection/FileName").text = NoModuleString
	setModule( null )
	get_node("Lobby").clearUnits()


func onStartGamePressed():
	emit_signal("readyForGame", _module , $"Lobby"._unitsCreationData)


func setModule( module : SavingModuleGd ):
	_module = module
	get_node("Lobby").setModule( module )


