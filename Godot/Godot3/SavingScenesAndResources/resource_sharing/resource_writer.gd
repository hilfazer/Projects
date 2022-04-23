extends Reference


func preload_and_write():
	var res_instance = preload("res://resource_sharing/a_resource_instance_preload.tres")
	res_instance.pp = "shared"
	print_debug("resource instance: %s, value written: %s" % [res_instance, res_instance.pp])


func load_and_write():
	var res_instance = load("res://resource_sharing/a_resource_instance_load.tres")
	res_instance.pp = "shared"
	print_debug("resource instance: %s, value written: %s" % [res_instance, res_instance.pp])
