extends FileDialog


const SaveGameDirectory = "res://save"
const SaveFileExtension = "sav"


func prepare():
	set_current_dir(SaveGameDirectory)
	self.filters = ["*." + SaveFileExtension]
