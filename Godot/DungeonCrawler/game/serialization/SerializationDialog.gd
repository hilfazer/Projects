extends FileDialog

const SerializationBaseGd = preload("SerializationBase.gd")


func _draw():
	set_current_dir(SerializationBaseGd.SaveGameDirectory)
	self.filters = ["*." + SerializationBaseGd.SaveFileExtension]
