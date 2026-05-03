#pragma once
#pragma pack(push, 1)

#include <windows.h>
#include <math.h>

struct Vector
{
    float x, y, z;
};

struct Quaternion
{
    float x, y, z, w;
};

class World;
class Entity;
class PhysicsObject;
class Ragdoll;
class PhysicsWorld;

extern void* GEngine;   // 0x14FEBE68

#define GEngine ((void*)0x14FEBE68)

// ====================== PhysicsObject ======================
class PhysicsObject
{
public:
    void* vftable;                    // +0x00
    DWORD field_04;                   // +0x04
    DWORD field_08;                   // +0x08
    DWORD field_0C;                   // +0x0C
    BYTE  field_10;                   // +0x10
    BYTE  pad_11[3];
    int   worldIndex;                 // +0x14
    float scale;                      // +0x18
    float field_1C;                   // +0x1C
    float field_20;                   // +0x20
    float maxVisibilityDist;          // +0x24
    float field_28;                   // +0x28
    float fovCone1;                   // +0x2C
    float fovCone2;                   // +0x30
    float field_34;                   // +0x34
    float field_38;                   // +0x38
    float field_3C;                   // +0x3C
    float field_40;                   // +0x40
    void* field_44;                   // +0x44
    float field_48;                   // +0x48
    float field_4C;                   // +0x4C
    float field_50;                   // +0x50
    float field_54;                   // +0x54
    void* field_58;                   // +0x58

    float* pPlayerData;               // +0x5C

    float field_60;                   // +0x60
    float field_64;                   // +0x64
    float field_68;                   // +0x68
    float field_6C;                   // +0x6C
    BYTE  field_70;                   // +0x70
    BYTE  field_71;                   // +0x71
    BYTE  field_72;                   // +0x72
    BYTE  pad_73;
    DWORD flags;                      // +0x74
    BYTE  extraFlags;                 // +0x75
    BYTE  pad_76[2];

    void* pInternalStruct;            // +0x7C

    // Методы
    void ZeroVelocity();
    void SetPawnHeadPos(const Vector& pos);
    Vector GetPawnHeadPos() const;
    bool IsPlayer();
};

// ====================== Entity ======================
class Entity
{
public:
    DWORD flags;                      // +0x18
    char pad_1C[0x94];
    PhysicsObject* pPhysics;          // +0xAC
    char pad_B0[0x70C];
    Ragdoll* pRagdoll;                // +0x7B8

    void CreatePhysicsObject(ULONG type, float radius, int param3, bool param4);
};

// ====================== Остальное ======================
class World
{
public:
    Entity* CreateEntity(const char* name, int type, float a3, float a4, void* a5);
    void AddEntity(Entity* entity);
};

class Ragdoll
{
public:
    ~Ragdoll();
};

class EngineGame
{
public:
    Entity* CreatePlayer(const char* playerName, bool bKeepOldRagdoll);
};