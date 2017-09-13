extends HBoxContainer


var m_lineIdx
var m_owner = 0

signal acquired(ownerId)
signal released()


func initialize( idx, peerId ):
	m_lineIdx = idx
	get_node("Acquire").connect("pressed", self, "acquire", [peerId])
	get_node("Release").connect("pressed", self, "release", [peerId])


func acquire( playerId ):
	if m_owner != 0 or playerId == 0:
		return
	
	m_owner = playerId
	get_node("Owner").text = str(playerId)
	get_node("Release").show()
	get_node("Acquire").hide()
	emit_signal("acquired", playerId)


func release( playerId ):
	if playerId != m_owner:
		return
		
	m_owner = 0
	get_node("Owner").text = "0"
	get_node("Acquire").show()
	get_node("Release").hide()
	emit_signal("released")


func setUnit( unitPath ):
	get_node("Name").text = unitPath
	# todo: set icon
