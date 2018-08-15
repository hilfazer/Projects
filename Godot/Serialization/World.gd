extends Node

const SerializerGd = preload("res://Serializer.gd")
const Node2DScn = preload("res://Node2D.tscn")

const SaveFilename = "res://save/file.save"

var m_serializer = SerializerGd.new()


func _ready():
	m_serializer.saveBranch( $Parent.name, m_serializer.serialize( $Parent ) )
	m_serializer.saveBranch( $NoSceneNoSerialize.name, m_serializer.serialize( $NoSceneNoSerialize ) )
	m_serializer.saveToFile( SaveFilename )
	m_serializer.loadFromFile( SaveFilename )
	pass


func serialize():
	return {
		"SCENE" : filename
	}
