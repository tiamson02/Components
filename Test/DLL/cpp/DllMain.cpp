// DllMain.cpp - DLL entry point for EngineGame DLL

#define ENGINEGAME_EXPORTS
#include <windows.h>
#include "EngineGame.h"

// Forward declaration
EngineGame* CreateEngineGame();

// Global variable from disassembly: ?OurGame@@3P6APAVEngineGame@@XZA
extern "C" ENGINEGAME_API EngineGame* (*OurGame)() = nullptr;

// DLL entry point
BOOL APIENTRY DllMain(HMODULE hModule, DWORD ul_reason_for_call, LPVOID lpReserved) {
    switch (ul_reason_for_call) {
    case DLL_PROCESS_ATTACH:
        // Initialize OurGame pointer
        OurGame = CreateEngineGame;
        break;
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        // Cleanup if needed
        if (GEngine) {
            delete GEngine;
            GEngine = nullptr;
        }
        break;
    }
    return TRUE;
}