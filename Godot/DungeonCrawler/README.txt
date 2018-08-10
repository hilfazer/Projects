This project works with unofficial Godot 3.1 build.

In this project i'm exploring mostly 3 things:
- networked gameplay using high level networking API
- saving and loading game state
- GUI

Loading game will assign players units to the host.


Notable scripts/scenes:
* Connector.gd - Connects components of the system with signals and slots. AutoLoad.
* MainMenu.tscn - Starting scene of the project.
* NewGameScene.tscn - Scene where new game is hosted, players join the lobby and create their characters.
* GameScene.tscn - Main node for live gaming session. Created by Connector.gd.
* GameMenu.tscn - menu available when game is in progress.
* PlayerManager.gd - Creates player units and agents, and assigns units to agents.
* Module.gd - Contains information about levels, how are they connected and how many player units can be used in campaign.
* LevelBase.tscn - Base scene for levels. Level contains tilemap, units and player spawn points.
* Network.gd - AutoLoad to handle hosting/joining game and registering connected clients.
* DebugWindow.tscn - Scene where all debug info will go. Press F4 to open/close. This window goes to background if you switch scenes, it can be fixed by hiding and showing it again.


Tileset i use:
http://opengameart.org/content/dungeon-crawl-32x32-tiles
http://code.google.com/p/crawl-tiles/

Console plugin i use:
https://github.com/QuentinCaffeino/godot-console
Console is opened/closed with tilde (`)
