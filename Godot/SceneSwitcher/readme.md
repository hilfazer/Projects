# Scene Switcher

SceneSwitcher.gd is an autoload script that handles changing scenes.
It supports passing parameters and connecting to new scene's signals.

It's supposed to be used instead of following SceneTree's functions:
* change_scene( path )            - use **switchScene**( path, params ) instead
* change_scene_to( packed_scene ) - use **switchSceneTo**( packedScene, params ) instead
* reload_current_scene()          - use **reloadCurrentScene**() instead


**sceneInstanced**( scene ) signal is emitted after new scene gets instanced and before it's added to SceneTree. It can be used to connect to new scene's signals.

**sceneSetAsCurrent**() signal is emitted when a scene created by switchScene() or switchSceneTo() becomes current_scene.

**getParams**() returns parameters passed to new scene. They can be accessed already in _init(). BE AWARE it will prevent parameters from being retrieved again and subsequent calls to getParams() will return null. It will be explained later.

**reloadCurrentScene**() reloads current scene or returns ERR_CANT_CREATE if current scene has no filename.

**switchScene**( null ) will remove current scene.

It works on SceneTree's current_scene. It destroys previous current scene, unless new scene fails to create, and sets newly instantiated scene as new current.
New scene will become current between its **_enter_tree**() and **_ready**() calls. Couldn't find a way to make it sooner.


Scene's parameters are locked after call of getParams() to allow creation of scenes that will not accidentaly read parameters not intended for them. For example in this code:
```
	var sceneNode = load("res://SceneThatCallsGetParams.scn").instance()
	var packedScene = PackedScene.new()
	packedScene.pack( sceneNode )
	SceneSwitcher.switchSceneTo( packedScene, "a parameter" )
```
Node created in first line will not get parameters created for a scene previously set by switchScene()/switchSceneTo(). 
