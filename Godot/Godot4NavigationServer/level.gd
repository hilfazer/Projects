extends Control

var navAgent : NavigationAgent2D
@onready var player : Node2D = $"NavigationRegion2D/Player"


func _ready():
	navAgent = $"NavigationRegion2D/Player".getNavAgent()
	var map_rid = $"NavigationRegion2D".get_world_2d().get_rid()
	var agent_rid = navAgent.get_rid()
	NavigationServer2D.agent_set_map(agent_rid, map_rid)
	
	navAgent.path_changed.connect(update)
	navAgent.path_changed.connect(func(): print("path updated"))
	
	
func _process(delta):
	if navAgent == null:
		return
		
	$"VBoxContainer/LabelFinal".text = "Final: " + str(navAgent.get_final_location())
	$"VBoxContainer/LabelNext".text = "Next: " + str(navAgent.get_next_location())
	$"VBoxContainer/LabelFinished".text = "Finished: " + str(navAgent.is_navigation_finished())
	$"VBoxContainer/LabelPath".text = "Path: " + str(navAgent.get_nav_path())
	$"VBoxContainer/LabelPlayerPos".text = "Position: " + str(player.global_position)


func _draw():
	drawPath(navAgent.get_nav_path())


func drawPath(path : PackedVector2Array) -> void:
	for segment in path:
		draw_circle(segment, 4, Color.DARK_RED)
		
	for i in range(0, path.size()-1):
		draw_line(path[i], path[i+1], Color.BROWN, 2.0)
