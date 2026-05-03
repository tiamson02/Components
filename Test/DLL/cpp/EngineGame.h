#ifndef ENGINEGAME_H
#define ENGINEGAME_H

#include <cstddef>
#include <windows.h>  // For HMODULE, etc.

#ifdef ENGINEGAME_EXPORTS
#define ENGINEGAME_API __declspec(dllexport)
#else
#define ENGINEGAME_API __declspec(dllimport)
#endif

// Forward declarations for external classes
class PhysicsWorld;
class NetworkDevice;
class LuaState;

class Entity {
public:
    char name[64];
    bool isLocal;
    float position[3];
    float velocity[3];

    Entity() : isLocal(false) {
        name[0] = '\0';
        position[0] = position[1] = position[2] = 0.0f;
        velocity[0] = velocity[1] = velocity[2] = 0.0f;
    }
};

class ENGINEGAME_API EngineGame {
public:
    EngineGame();
    virtual ~EngineGame();

    virtual void ShowMenu();
    virtual void HideMenu();
    virtual void SwitchConsole();
    virtual void SwitchMenu(bool open);
    virtual void SwitchMapSelect(bool open);
    virtual void SwitchMagicBoard(bool open);

    virtual void ShowMPStats();
    virtual void HideMPStats();

    virtual void Initialize();
    virtual void Close();
    virtual void Tick(bool paused, float frameTime);

    virtual Entity* CreatePlayer(const char* playerName, bool isLocal);
    virtual void UpdateViewFromPlayer();

    // Internal state (reconstructed from disassembly)
    PhysicsWorld* physicsWorld;
    NetworkDevice* networkDevice;
    LuaState* luaState;
    Entity* playerEntity;
    bool isPaused;
    float deltaTime;
};

extern "C" ENGINEGAME_API EngineGame* (*OurGame)();
extern "C" ENGINEGAME_API EngineGame* CreateEngineGame();

// Global engine instance (from disassembly: GEngine)
extern ENGINEGAME_API EngineGame* GEngine;

#endif // ENGINEGAME_H
