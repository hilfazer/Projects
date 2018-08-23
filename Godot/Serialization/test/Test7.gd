# adding and removing

extends Node

const SerializerGd = preload("res://Serializer.gd")


func _ready():
	var serializer = SerializerGd.new()
	serializer.add( ['1', 7.5] )
	
	if serializer.getKeys() != ['1']:
		print("serializer.getKeys() != ['1']")
	
	if serializer.getValue('1') != 7.5:
		print("serializer.getValue('1') != 7.5")
	
	if serializer.getValue('g') != null:
		print("serializer.getValue('g') != null")
	
	serializer.add( ['1', null] )
	
	if serializer.getKeys() != []:
		print("serializer.getKeys() != []")
		
	serializer.add(['4', "foo"])
	serializer.add(['4', "bar"])
	
	if serializer.getKeys() != ['4']:
		print("serializer.getKeys() != ['4']")
		
	
	if serializer.getValue('4') != "bar":
		print("serializer.getValue('4') != 'bar'")
		
	serializer.remove('4')
	
	if serializer.getKeys() != []:
		print("serializer.getKeys() != []")
