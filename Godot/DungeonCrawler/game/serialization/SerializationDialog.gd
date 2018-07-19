extends "SerializationBase.gd"


func _draw():
	set_current_dir(SaveGameDirectory)
	self.filters = ["*." + SaveFileExtension]
