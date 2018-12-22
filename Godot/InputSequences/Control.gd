extends Control


const m_sequences = { 
	1 : ["ui_up", "ui_up", "ui_up"],
	2 : ["ui_up", "ui_up"],          # it won't be detected since it's a subsequence of first item
	3 : ["ui_down"],
	4 : ["ui_down", "ui_up", "ui_down"],
	5 : ["ui_right", "ui_right"],
	8 : ["ui_up", "ui_up", "ui_up"],
	9 : [],
}

const m_actions = ["ui_up", "ui_up", "ui_down", "ui_select", "ui_right", "ui_left"]


func _ready():
	var detector = $"SequenceDetector"
	detector.setConsumingInput( $"CheckBox".pressed )
	detector.connect("sequenceDetected", self, "onSequenceDetected")
	
	for id in m_sequences:
		var added = detector.addSequence( id, m_sequences[id] )
		if typeof( added ) == TYPE_INT and added == OK:
			$"AvailableSequences".add_item( str(m_sequences[id]) )
		else:
			print( added )

	if detector.has_method("addAction"):
		for action in m_actions:
			detector.addAction( action )
		detector.removeAction("ui_select")
		

func _input(event):
	if event is InputEventKey and event.pressed:
		print( "pressed key scancode ", event.scancode )


func onSequenceDetected( id : int ):
	$"PerformedSequences".add_item( str( m_sequences[id] ) )
	
	