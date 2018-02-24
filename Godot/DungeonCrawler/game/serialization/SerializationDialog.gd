extends "SerializationBase.gd"

# TODO: stop input from propagating


func _draw():
	set_current_dir(SaveGameDirectory)
	self.filters = ["*." + SaveFileExtension]
