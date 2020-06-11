extends HBoxContainer


func _process(_delta):
	$"LineDynamic".text = \
		String.humanize_size( Performance.get_monitor(Performance.MEMORY_DYNAMIC) )
	$"LineStatic".text  = \
		String.humanize_size( Performance.get_monitor(Performance.MEMORY_STATIC) )
