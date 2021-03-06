extends Label


func setMessage( message : String ):
	self.text = message

	if has_node("resetMessage"):
		$"resetMessage".start()
	else:
		var timer = Timer.new()
		timer.name = "resetMessage"
		timer.connect("timeout", self, "set_text", [""])
		timer.connect("timeout", timer, "queue_free")
		timer.wait_time = 3
		add_child( timer )
		timer.start()

