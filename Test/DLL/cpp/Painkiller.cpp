// Painkiller.cpp - Reconstructed EXE source for Painkiller (2005)
// This file is reverse-engineered from disassembly and DLL exports.
// It is intentionally incomplete and preserves missing checks and holes.

#include "EngineGame.h"
#include <windows.h>
#include <iostream>
#include <string>
#include <vector>
#include <memory>
#include <thread>
#include <chrono>
#include <cstring>

#pragma comment(lib, "user32.lib")
#pragma comment(lib, "gdi32.lib")
#pragma comment(lib, "ws2_32.lib")
#pragma comment(lib, "d3d9.lib")

// Used external libraries in the original build:
//  - Lua 5.0.2 (lua502.dll / lua.dll)
//  - Havok Physics 2.x (Havok DLLs such as hkd.dll / hkp.dll)
//  - DirectX 9 (d3d9.dll and D3DX9 helper DLLs)
//  - zlib 1.2.1 (zlib1.dll)
//  - Info-ZIP 1.00 (zip.dll / infzip.dll)
//  - Qhull (qhull.dll)
//  - GameSpy (gamespy.dll)
//  - Winsock 1.1 / 2.0 (wsock32.dll / ws2_32.dll)

static const char* kExeTitle = "Painkiller Reconstructed";
static const char* kEngineDllName = "ENGINE.DLL";

struct ScriptEngine {
    EngineGame* engine;
    ScriptEngine(EngineGame* game) : engine(game) {}

    void Execute(const std::string& command) {
        std::cout << "[ScriptEngine] Execute: " << command << std::endl;

        if (command.find("Game:OnPlay(true)") != std::string::npos) {
            engine->Tick(false, 1.0f / 30.0f);
            return;
        }

        if (command.find("Game:OnPlay()") != std::string::npos) {
            engine->Tick(false, 1.0f / 60.0f);
            return;
        }

        if (command.find("Game:NewLevel") != std::string::npos) {
            engine->CreatePlayer("NoName", true);
            engine->SwitchMapSelect(true);
            return;
        }

        if (command.find("SwitchMenu") != std::string::npos) {
            engine->SwitchMenu(command.find("true") != std::string::npos);
            return;
        }

        if (command.find("SwitchMapSelect") != std::string::npos) {
            engine->SwitchMapSelect(command.find("true") != std::string::npos);
            return;
        }

        if (command.find("SwitchMagicBoard") != std::string::npos) {
            engine->SwitchMagicBoard(command.find("true") != std::string::npos);
            return;
        }

        if (command.find("ShowMenu") != std::string::npos) {
            engine->ShowMenu();
            return;
        }

        if (command.find("HideMenu") != std::string::npos) {
            engine->HideMenu();
            return;
        }

        std::cout << "[ScriptEngine] Unknown command: " << command << std::endl;
    }
};

static HWND CreateGameWindow(HINSTANCE instance) {
    WNDCLASSA wc = {};
    wc.lpfnWndProc = DefWindowProcA;
    wc.hInstance = instance;
    wc.lpszClassName = "PainkillerWindowClass";
    RegisterClassA(&wc);
    return CreateWindowA(wc.lpszClassName, kExeTitle, WS_OVERLAPPEDWINDOW,
                         CW_USEDEFAULT, CW_USEDEFAULT, 1024, 768,
                         nullptr, nullptr, instance, nullptr);
}

static bool StartNetwork() {
    WSADATA wsa = {};
    if (WSAStartup(MAKEWORD(2, 0), &wsa) != 0) {
        return false;
    }
    return true;
}

static void ShutdownNetwork() {
    WSACleanup();
}

static EngineGame* LoadEngine() {
    HMODULE module = LoadLibraryA(kEngineDllName);
    if (!module) {
        std::cout << "[Painkiller] Failed to load " << kEngineDllName << std::endl;
        return nullptr;
    }

    auto createGame = reinterpret_cast<EngineGame* (*)()>(GetProcAddress(module, "CreateEngineGame"));
    if (!createGame) {
        std::cout << "[Painkiller] Failed to locate CreateEngineGame export" << std::endl;
        return nullptr;
    }

    return createGame();
}

static void RunGameLoop(EngineGame* engine, ScriptEngine& script) {
    MSG msg = {};
    while (msg.message != WM_QUIT) {
        while (PeekMessageA(&msg, nullptr, 0, 0, PM_REMOVE)) {
            TranslateMessage(&msg);
            DispatchMessageA(&msg);
        }

        engine->Tick(false, 1.0f / 60.0f);
        engine->UpdateViewFromPlayer();

        // Simulated script triggers from disassembly strings
        static int counter = 0;
        if (++counter == 60) {
            script.Execute("Game:OnPlay(true)");
        }
        if (counter == 120) {
            script.Execute("Game:NewLevel('NoName')");
        }
        if (counter == 180) {
            script.Execute("Game:SwitchMenu(true)");
        }

        std::this_thread::sleep_for(std::chrono::milliseconds(16));
    }
}

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE, LPSTR, int) {
    std::cout << "[Painkiller] Starting reconstructed EXE" << std::endl;

    if (!StartNetwork()) {
        std::cout << "[Painkiller] Network startup failed" << std::endl;
    }

    HWND window = CreateGameWindow(hInstance);
    if (!window) {
        std::cout << "[Painkiller] Window creation failed" << std::endl;
    }

    EngineGame* engine = LoadEngine();
    if (!engine) {
        std::cout << "[Painkiller] Falling back to local EngineGame implementation" << std::endl;
        engine = new EngineGame();
    }

    engine->Initialize();

    ScriptEngine script(engine);
    script.Execute("Game:OnPlay()");
    script.Execute("Game:NewLevel('NoName')");

    engine->ShowMenu();
    engine->SwitchConsole();

    RunGameLoop(engine, script);

    engine->Close();
    delete engine;
    ShutdownNetwork();

    std::cout << "[Painkiller] Shutdown complete" << std::endl;
    return 0;
}
