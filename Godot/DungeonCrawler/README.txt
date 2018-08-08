In this project i'm exploring mostly 3 things:
- networked gameplay using high level networking API in Godot 3.0 alpha
- saving and loading game state
- GUI


After playing some Divinity: Original Sin i've got some ideas and decided to redo this project.
Loading game will assign players units to the host.


Notable scripts/scenes:
* Connector.gd - Connects components of the system with signals and slots. AutoLoad.
* MainMenu.tscn - Starting scene of the project.
* NewGame.tscn - Scene where new game is hosted, players join the lobby and create their characters.
* GameScene.tscn - Main node for live gaming session. Created by Connector.gd.
* Module.gd - An interface for modules. Modules are supposed to be something like Modules in NWN.
* LevelBase.tscn - Base scene for levels. Level contains tilemap, units and player spawn points.
* Network.gd - AutoLoad to handle hosting/joining game and registering connected clients.
* DebugWindow.tscn - Scene where all debug info will go. Press F4 to open/close. This window goes to background if you switch scenes, it can be fixed by hiding and showing it again.


Tileset i use:
http://opengameart.org/content/dungeon-crawl-32x32-tiles
http://code.google.com/p/crawl-tiles/

Console plugin i use:
https://github.com/QuentinCaffeino/godot-console
Console is opened/closed with tilde (`)
