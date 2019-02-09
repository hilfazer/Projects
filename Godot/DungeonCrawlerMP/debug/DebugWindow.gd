extends CanvasLayer


func _on_PrintSceneTree_pressed():
	$"/root".print_tree_pretty()


func _on_PrintStrayNodes_pressed():
	$"/root".print_stray_nodes()
