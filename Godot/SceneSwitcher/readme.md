# Scene Switcher

SceneSwitcher.gd is an autoload script that handles changing scenes.
It supports passing parameters and connecting to new scene's signals.

It's supposed to be used instead of following SceneTree's functions:
* change_scene( path )            - use **switchScene**( path, params, meta ) instead
* change_scene_to( packed_scene ) - use **switchSceneTo**( packedScene, params, meta ) instead
* reload_current_scene()          - use **reloadCurrentScene**() instead

Additionally it supports switching to already instanced Node:
* switchSceneToInstance( node, params, meta )

**params** is an optional value with parameters for the new scene.
**meta** is an optional metadata key for adding parameters as a metadata.

### Signals

**sceneInstanced**( scene ) signal is emitted after new scene gets instanced and before it's added to SceneTree. It can be used to connect to new scene's signals. Note that it will not fire if you use *switchSceneToInstance*()

**sceneSetAsCurrent**() signal is emitted when a scene created by *switchScene*(), *switchSceneTo*() or *switchSceneToInstance*() becomes current_scene.

### Functions

**getParams**( node : Node ) returns parameters passed to new scene. *node* is a scene that is supposed to receive the parameters.

**reloadCurrentScene**() reloads current scene or returns ERR_CANT_CREATE if current scene has no filename.

Hint: calling **switchScene**( null ) will remove current scene.

#### Other stuff

It works on SceneTree's current_scene. It destroys previous current scene, unless new scene fails to create, and sets newly instantiated scene as new current.
New scene will become current between its **_enter_tree**() and **_ready**() calls. I Couldn't find a way to make it sooner.
**getParams**() will print a warning in case parameters are available through metadata.
