extends NavigationMeshInstance


func _ready():
	await get_tree().create_timer(10.0).timeout
	var ramp = load("res://Ramp.tscn").instance()
	$"RampPosition".add_child(ramp)
	print("Start baking navigation mesh")
	bake_navigation_mesh()


func _on_NavigationMeshInstance2_navigation_mesh_changed():
	print("Navigation mesh changed")
