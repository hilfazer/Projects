extends Control

const DEFAULT_SCENE = "res://level.tscn"
const SAVED_SCENE = "user://level.tscn"


func save_scene() -> void:
  var packed_scene = PackedScene.new()
  packed_scene.pack(get_node("mynode"))
# warning-ignore:return_value_discarded
  ResourceSaver.save(SAVED_SCENE, packed_scene)


func load_scene() -> void:
  var scene_exists := File.new().file_exists(SAVED_SCENE)
  var packed_scene := load(SAVED_SCENE if scene_exists else DEFAULT_SCENE) as PackedScene
  var scene := packed_scene.instance()
  scene.name = "mynode"
  add_child(scene)
