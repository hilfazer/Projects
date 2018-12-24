A script that handles switching scenes.
It allows passing parameters.
It works on SceneTree's current_scene. It destroys previous current scene, if any, and sets newly instantiated scene as new current.

Add SceneSwitcher.gd to autoloads.
Change your scene with switchScene( targetScenePath, params ) function. 'params' is a variable of arbitrary type. It can be accessed in new scene with getParams() function.
sceneInstanced( scene ) signal is emitted right after new scene gets instanced, before it's added to SceneTree.
