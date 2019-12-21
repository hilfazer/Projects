extends Label

func _process( _delta ):
	set_text(str(Engine.get_frames_per_second()))
