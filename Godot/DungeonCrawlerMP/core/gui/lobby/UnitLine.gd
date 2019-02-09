extends HBoxContainer


var m_lineIdx       setget deleted, getIdx
var m_ownerId = 0   setget deleted

signal acquired(ownerId)
signal released()
signal deletePressed( lineIdx )


func deleted(_a):
	assert(false)


func initialize( idx, peerId ):
	m_lineIdx = idx
	m_ownerId = peerId
	get_node("Owner").text = str(peerId)
	get_node("Delete").set_disabled( get_tree().get_network_unique_id() != peerId )


func acquire( playerId ):
	if m_ownerId != 0 or playerId == 0:
		return

	m_ownerId = playerId
	get_node("Owner").text = str(playerId)
#	get_node("Release").show()
	get_node("Acquire").hide()
	emit_signal("acquired", playerId)
	get_node("Delete").set_disabled(false)


func release( playerId ):
	if playerId != m_ownerId:
		return

	m_ownerId = 0
	get_node("Owner").text = "0"
	get_node("Acquire").show()
	get_node("Release").hide()
	emit_signal("released")
	get_node("Delete").set_disabled(true)


func setUnit( unitPath ):
	get_node("Name").text = unitPath
	# todo: set icon


func onDeletePressed():
	assert( get_tree().get_network_unique_id() == m_ownerId )
	emit_signal("deletePressed", get_index())


func getIdx():
	return m_lineIdx

