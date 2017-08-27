extends Node


func _OnSelectPressed():
	get_node("ChooseModuleDialog/FileDialog").show()


func _OnSavePressed():
	get_node("SaveGameDialog/FileDialog").show()
	

func OnFileDialogFileSelected( path ):
	pass # replace with function body
