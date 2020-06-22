extends FileDialog

const SaveGameDirectory = "res://save"
const SaveFileExtension = "tres"


func _draw():
	set_current_dir(SaveGameDirectory)
	self.filters = PoolStringArray( ["*." + SaveFileExtension] )
