extends FileDialog

const ModulesDirectory = "res://data"
const ModuleFileExtension = "gd"


func _draw():
	set_current_dir(ModulesDirectory)
	self.filters = PoolStringArray( ["*." + ModuleFileExtension] )
