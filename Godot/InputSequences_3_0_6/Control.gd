extends Control


const m_sequences = {
	1 : ["ui_up", "ui_up", "ui_up"],
	2 : ["ui_up", "ui_up"],
	3 : ["ui_down"],
	4 : ["ui_down", "ui_up", "ui_down"],
	5 : ["ui_right", "ui_right"],
	6 : ["ui_right", "ui_left"],
	8 : ["ui_up", "ui_up", "ui_up"],
	9 : [],
}

const m_actions = ["ui_up", "ui_up", "ui_down", "ui_select", "ui_right", "ui_left"]


func _ready():
	var detector = $"SequenceDetector"
	detector.setConsumingInput( $"CheckBox".pressed )
	detector.connect("sequenceDetected", self, "onSequenceDetected")
	$"CheckBox".connect("toggled", detector, "setConsumingInput")


	var discarded = detector.addSequences( m_sequences )
	for id in m_sequences:
		if id in discarded:
			print( discarded[id], " ", id, " ", m_sequences[id] )
		else:
			$"AvailableSequences".add_item( str(m_sequences[id]) )

	detector.addActions( m_actions )
	detector.removeActions( ["ui_select"] )


func _input(event):
	if event is InputEventKey and event.pressed:
		print( "pressed key scancode ", event.scancode )


func onSequenceDetected( id ):
	$"PerformedSequences".add_item( str( m_sequences[id] ) )

