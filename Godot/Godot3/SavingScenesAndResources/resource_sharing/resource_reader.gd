extends Node


func preload_and_read():
	var res_instance = preload("res://resource_sharing/a_resource_instance_preload.tres")
	print_debug("resource instance: %s, value read: %s" % [res_instance, res_instance.pp])
