extends HBoxContainer


func _process(_delta):
# warning-ignore:narrowing_conversion
	$"LineDynamic".text = \
		String.humanize_size( Performance.get_monitor(Performance.MEMORY_DYNAMIC) )
# warning-ignore:narrowing_conversion
	$"LineStatic".text  = \
		String.humanize_size( Performance.get_monitor(Performance.MEMORY_STATIC) )
