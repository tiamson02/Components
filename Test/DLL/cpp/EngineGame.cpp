// EngineGame.cpp - Implementation of EngineGame class for Painkiller (2005) DLL
// Reconstructed from reverse-engineered disassembly with intentionally incomplete behavior.

// cl /EHsc /std:c++17 /c EngineGame.cpp DllMain.cpp Painkiller.cpp && link /DLL DllMain.obj EngineGame.obj /out:ENGINE.dll && link Painkiller.obj user32.lib gdi32.lib ws2_32.lib d3d9.lib /out:Painkiller.exe

#define ENGINEGAME_EXPORTS

#include "EngineGame.h"
#include <iostream>
#include <cstring>
#include <windows.h>

// Stub classes for external dependencies
class PhysicsWorld {
public:
    void Step(float dt) {
        std::cout << "[PhysicsWorld] Step(" << dt << ")" << std::endl;
    }
    void WarmUp() {
        std::cout << "[PhysicsWorld] WarmUp" << std::endl;
    }
};

class NetworkDevice {
public:
    void PostTick() {
        std::cout << "[NetworkDevice] PostTick" << std::endl;
    }
};

class LuaState {
public:
    void Sync() {
        std::cout << "[LuaState] Sync" << std::endl;
    }
};

// Global engine instance exported from DLL
ENGINEGAME_API EngineGame* GEngine = nullptr;

extern "C" ENGINEGAME_API EngineGame* CreateEngineGame() {
    GEngine = new EngineGame();
    return GEngine;
}

EngineGame::EngineGame()
    : physicsWorld(nullptr)
    , networkDevice(nullptr)
    , luaState(nullptr)
    , playerEntity(nullptr)
    , isPaused(false)
    , deltaTime(0.0f)
{
    std::cout << "[EngineGame] ctor" << std::endl;
    physicsWorld = new PhysicsWorld();
    networkDevice = new NetworkDevice();
    luaState = new LuaState();
}

EngineGame::~EngineGame() {
    std::cout << "[EngineGame] dtor" << std::endl;
    delete physicsWorld;
    delete networkDevice;
    delete luaState;
    delete playerEntity;
}

void EngineGame::ShowMenu() {
    std::cout << "[EngineGame] ShowMenu" << std::endl;
}

void EngineGame::HideMenu() {
    std::cout << "[EngineGame] HideMenu" << std::endl;
}

void EngineGame::SwitchConsole() {
    std::cout << "[EngineGame] SwitchConsole" << std::endl;
}

void EngineGame::SwitchMenu(bool open) {
    std::cout << "[EngineGame] SwitchMenu(" << open << ")" << std::endl;
    if (open) {
        ShowMenu();
    } else {
        HideMenu();
    }
}

void EngineGame::SwitchMapSelect(bool open) {
    std::cout << "[EngineGame] SwitchMapSelect(" << open << ")" << std::endl;
}

void EngineGame::SwitchMagicBoard(bool open) {
    std::cout << "[EngineGame] SwitchMagicBoard(" << open << ")" << std::endl;
}

void EngineGame::ShowMPStats() {
    std::cout << "[EngineGame] ShowMPStats" << std::endl;
}

void EngineGame::HideMPStats() {
    std::cout << "[EngineGame] HideMPStats" << std::endl;
}

void EngineGame::Initialize() {
    std::cout << "[EngineGame] Initialize" << std::endl;
    if (physicsWorld) {
        physicsWorld->WarmUp();
        // TODO: вставить фикс ZeroVelocity после PHYSICS.WarmUp
    }
}

void EngineGame::Close() {
    std::cout << "[EngineGame] Close" << std::endl;
}

void EngineGame::Tick(bool paused, float frameTime) {
    std::cout << "[EngineGame] Tick paused=" << paused << " dt=" << frameTime << std::endl;
    deltaTime = frameTime;
    isPaused = paused;

    if (paused) {
        return;
    }

    MSG msg;
    while (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }

    if (physicsWorld) {
        physicsWorld->WarmUp();
        physicsWorld->Step(frameTime);
    }

    if (playerEntity) {
        std::cout << "[EngineGame] Updating entities with dt=" << frameTime << std::endl;
        playerEntity->velocity[1] -= 9.8f * frameTime;
        for (int i = 0; i < 3; ++i) {
            playerEntity->position[i] += playerEntity->velocity[i] * frameTime;
        }
        if (playerEntity->position[1] < 0.0f) {
            playerEntity->position[1] = 0.0f;
            playerEntity->velocity[1] = 0.0f;
        }
    }

    if (luaState) {
        luaState->Sync();
    }

    if (networkDevice) {
        networkDevice->PostTick();
    }
}

Entity* EngineGame::CreatePlayer(const char* playerName, bool isLocal) {
    playerEntity = new Entity();
    std::strncpy(playerEntity->name, playerName ? playerName : "NoName", sizeof(playerEntity->name) - 1);
    playerEntity->name[sizeof(playerEntity->name) - 1] = '\0';
    playerEntity->isLocal = isLocal;
    playerEntity->position[0] = playerEntity->position[1] = playerEntity->position[2] = 0.0f;
    playerEntity->velocity[0] = playerEntity->velocity[1] = playerEntity->velocity[2] = 0.0f;
    std::cout << "[EngineGame] CreatePlayer(name='" << playerEntity->name << "', local=" << isLocal << ")" << std::endl;
    return playerEntity;
}

void EngineGame::UpdateViewFromPlayer() {
    std::cout << "[EngineGame] UpdateViewFromPlayer" << std::endl;
    if (playerEntity) {
        float cameraPos[3] = {
            playerEntity->position[0],
            playerEntity->position[1] + 1.8f,
            playerEntity->position[2] - 4.0f
        };
        std::cout << "[EngineGame] Camera at (" << cameraPos[0] << ", " << cameraPos[1] << ", " << cameraPos[2] << ")" << std::endl;
    }
}
