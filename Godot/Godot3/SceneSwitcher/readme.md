# Scene Switcher

SceneSwitcher.tscn is a scene that handles changing scenes. It's meant to be autoloaded.
It supports passing parameters, transition animations and connecting to new scene's signals.

It's supposed to be used instead of following SceneTree's functions:
* change_scene( path )            - use **switch_scene**( path, params, meta ) instead
* change_scene_to( packed_scene ) - use **switch_scene_to**( packed_scene, params, meta ) instead
* reload_current_scene()          - use **reload_current_scene**() instead

**params** is an optional value with parameters for the new scene.
**meta** is an optional metadata key for adding parameters as a metadata. It needs to be String.

## Functions

**switch_scene_interactive**( path, params, meta ) is like **switch_scene** but will emit a signal with percentage of the progress.

**switch_scene_to_instance**( node, params, meta ) will switch scene to **node** (assuming it is a scene).

**get_params**( node : Node ) returns parameters passed to new scene. **node** is a scene that is supposed to receive the parameters.

**reload_current_scene**() reloads current scene or returns ERR_CANT_CREATE if current scene has no filename.


**clear_scene**() removes current scene.


## Signals

**scene_instanced**( scene ) signal is emitted after new scene gets instanced and before it's added to SceneTree. It can be used to connect to new scene's signals. Note that it will not fire if you use *switch_scene_to_instance*().

**scene_set_as_current**() signal is emitted when a scene created by *switch_scene*(), *switch_scene_to*() or *switch_scene_to_instance*() becomes current_scene.

**progress_changed**( progress ) signal is emitter when the scene is being loaded through **switch_scene_interactive**() method.

**faded_in**() and **faded_out**() signals are emitted when fade in/out animations are finished.



## Animations

Default animations played by SceneSwitcher do nothing and have minimum duration. Create a scene that inherits from SceneSwitcher.tscn and modify **"fade in"** and **"fade out"** animations.

**play_animations** variable controls whether animations should play or not.


## Other stuff

It works on SceneTree's current_scene. It destroys previous current scene, unless new scene fails to create, and sets newly instantiated scene as new current.
New scene will become current between its **_enter_tree**() and **_ready**() calls. I Couldn't find a way to make it sooner.

**get_params**() will print a warning in case parameters are available through metadata.

Warning: return values of **switch_scene\*** methods do not correspond to return values of engine's methods.
