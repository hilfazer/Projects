extends FileDialog

const ModulesDirectory = "res://modules"
const ModuleFileExtension = "gd"


func _draw():
	set_current_dir(ModulesDirectory)
	self.filters = PoolStringArray( ["*." + ModuleFileExtension] )
