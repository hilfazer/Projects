extends Control

const m_sequences = {
	1 : ["ui_up", "ui_up", "ui_up"],
	2 : ["ui_up", "ui_up"],         # it won't be detected by LongestSequenceDetector.gd
									# but it will be by SubsequenceDetector.gd
	3 : ["ui_down"],
	4 : ["ui_down", "ui_up", "ui_down"],
	5 : ["ui_right", "ui_right"],
	6 : ["ui_right", "ui_left"],
	8 : ["ui_up", "ui_up", "ui_up"],
	9 : [],
}

const m_actions = ["ui_up", "ui_up", "ui_down", "ui_select", "ui_right", "ui_left"]

var m_detector = null


func _enter_tree():
	$DetectorButtons.connect( \
		"detectorSelected", self, "setDetector")


func _input(event):
	if event is InputEventKey and event.pressed:
		print( "pressed key scancode ", event.scancode )


func setDetector( path ):
	yield( get_tree(), "idle_frame" )
	if m_detector:
		m_detector.free()

	var detector = load( path ).instance()
	add_child( detector )
	m_detector = detector

	m_detector.setConsumingInput( $"CheckBox".pressed )
	m_detector.connect("sequenceDetected", self, "onSequenceDetected")
	$"CheckBox".connect("toggled", m_detector, "setConsumingInput")

	$"AvailableSequences".clear()
	var discarded : Dictionary = m_detector.addSequences( m_sequences )
	for id in m_sequences:
		if id in discarded:
			print( discarded[id], " ", id, " ", m_sequences[id] )
		else:
			$"AvailableSequences".add_item( str(m_sequences[id]) )

	m_detector.addActions( m_actions )
	m_detector.removeActions( ["ui_select"] )


func onSequenceDetected( id : int ):
	$"PerformedSequences".add_item( str( m_sequences[id] ) )

