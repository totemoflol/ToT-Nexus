# ToT Nexus Assets

This folder contains the metadata used for game artwork in the launcher.

Game icons are loaded from Roblox's official thumbnails API at runtime so the launcher can use the current approved icon without bundling stale copies. The loader requests the 512x512 experience icon using each registered game's UniverseId, then falls back to the legacy place-icon endpoint.

See `games.json` for the registered artwork sources and IDs.
