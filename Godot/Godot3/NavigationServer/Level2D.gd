extends Node


func _process(_delta):
	$"LabelPath".text = "Path: " + str($"Navigation2D/Player".nav_agent.get_nav_path())
	$"LabelNextTarget".text = "Next: " + str($"Navigation2D/Player".nav_agent.get_next_location())
	$"LabelTargetLoc".text = "Target: " + str($"Navigation2D/Player".nav_agent.get_target_location())
	$"LabelFinalLoc".text = "Final: " + str($"Navigation2D/Player".nav_agent.get_target_location())
	$"LabelFinished".text = "Finished: " + str($"Navigation2D/Player".nav_agent.is_navigation_finished())
