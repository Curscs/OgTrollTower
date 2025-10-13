# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a Roblox game codebase called "Classic-Troll-Tower" built using the Nevermore Engine framework. The project follows a service-oriented architecture with client-server separation and uses the Binder pattern for component management.

## Development Commands

### Setup and Installation
```bash
# Install dependencies
npm install

# Install toolchain tools (after installing Aftman)
aftman install
```

### Building and Development
```bash
# Serve the project to Roblox Studio (primary development command)
rojo serve

# Alternative serve command if using custom Rojo
rojo serve default.project.json
```

### Code Quality
```bash
# Lint code with Selene
selene src/

# Format code with StyLua
stylua src/

# Format specific files
stylua src/path/to/file.lua
```

## Architecture Overview

### Core Architecture Patterns

**Service-Oriented Architecture**: The project uses Nevermore's ServiceBag pattern where both client and server initialize services through dedicated Init services.

**Binder Pattern**: Game components use the Binder system to automatically manage instances with specific tags. Binders handle lifecycle events (BinderAdded, BinderRemoving, BinderRemoved).

**Client-Server Structure**: Clear separation between client and server code with shared modules for common functionality.

### Key Architectural Components

#### Bootstrap System
- **ServerMain.server.lua**: Initializes ServiceBag, loads InitService and BinderInitService
- **ClientMain.client.lua**: Similar client-side bootstrap that loads InitServiceClient and BinderInitServiceClient
- Both use Nevermore's loader system for module resolution

#### Service Management
- **InitService** (Server): Automatically discovers and initializes services in the Features folder
- **InitServiceClient** (Client): Initializes client services, controllers, and caches; manages UI reference systems
- **BinderInitService/BinderInitServiceClient**: Automatically discovers and initializes Binder classes

#### Feature Structure
```
src/modules/
├── Client/Features/     # Client-specific game features
├── Server/Features/     # Server-specific game features  
├── Shared/             # Code shared between client and server
│   ├── Configs/        # Configuration files
│   ├── Modules/        # Utility modules
│   ├── RefBuilders/    # Reference builders for game objects
│   └── Types/          # Type definitions
```

#### Game Features
- **Obby System**: Platformer/obstacle course mechanics with various part types (disappearing, pushing, hidable parts)
- **Gifts System**: Timed reward system with claim mechanics
- **Wheel System**: Spinning wheel reward mechanics
- **Damage System**: Health/damage management
- **Tools System**: In-game tool distribution

### Key Systems

#### Binder System
Components are bound to instances using CollectionService tags. Binders automatically:
- Create component objects when tagged instances are added
- Handle component lifecycle (Added, Removing, Removed events)
- Manage component cleanup

Example binder components:
- `ActionButtonBinder`: Interactive buttons in the game world
- `DisappearingPartBinder`: Parts that disappear when touched
- `ToolGiverBinder`: Areas that give tools to players

#### Reference System
Uses RefBuilders to create strongly-typed references to game objects:
- **GameRefs**: Core game object references  
- **UIRefs**: User interface references
- Specific UI reference systems (WheelUIRefs, HUDButtonsUIRefs, etc.)

#### Remote System
Uses Nevermore's Remoting system for client-server communication with RemoteGate for error handling.

## Development Guidelines

### Code Style
- Uses strict Luau language mode
- StyLua formatting with "Input" call parentheses style
- Selene linting with Roblox standard, allows mixed tables and if_same_then_else

### Service Naming Conventions
- Server services: `*Service.lua`
- Client services: `*ServiceClient.lua` or `*Controller.lua` 
- Binders: `*Binder.lua` (server) or `*BinderClient.lua` (client)

### Module Structure
All modules follow consistent structure:
- Class comment with `@class` annotation
- Roblox Services imports
- Nevermore loader integration
- Type definitions with exported Module type
- ServiceBag integration for dependency injection

### Adding New Features
1. Create service files in appropriate Client/Server Features folder
2. Services are auto-discovered by InitService if name contains "service"
3. Controllers are auto-discovered by InitServiceClient if name contains "service", "controller", or "cache"
4. Binders are auto-discovered if name contains "binder"

### Toolchain
- **Rojo**: Syncs code to Roblox Studio
- **Aftman**: Manages development tools
- **Selene**: Lua linting
- **StyLua**: Code formatting  
- **Luau LSP**: Language server for IDE support
- **Nevermore packages**: Managed via npm

The project structure enables rapid feature development through automatic service discovery and the component-based Binder system for game world interactions.