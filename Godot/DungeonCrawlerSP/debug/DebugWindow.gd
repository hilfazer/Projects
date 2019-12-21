extends CanvasLayer


func _process( _delta ):
	$'FpsLabel'.text = str(Engine.get_frames_per_second())


func _on_PrintSceneTree_pressed():
	$"/root".print_tree_pretty()


func _on_PrintStrayNodes_pressed():
	$"/root".print_stray_nodes()
