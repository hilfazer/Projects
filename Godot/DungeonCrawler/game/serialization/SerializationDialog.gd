extends FileDialog

const SaveGameDirectory = "res://save"
const SaveFileExtension = "sav"


func _draw():
	set_current_dir(SaveGameDirectory)
	self.filters = ["*." + SaveFileExtension]
