extends Spatial


onready var playerAgent : NavigationAgent = $"Player3D".nav_agent


func _ready():



	pass


func _process(_delta):
	$"HUD/LabelPath".text = str(playerAgent.get_nav_path())
	$"HUD/LabelReachable".text = str(playerAgent.is_target_reachable())
