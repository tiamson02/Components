#include "PainEngineStubs.h"

// ==================== PhysicsObject::ZeroVelocity ====================
void __thiscall PhysicsObject::ZeroVelocity()
{
    if (*(int**)(this + 0x7C) && **(int**)(this + 0x7C))
    {
        Vector zero = { 0.0f, 0.0f, 0.0f };
        int internal = **(int**)(this + 0x7C);
        // вызов виртуальной функции обнуления скорости
        (*(void (__thiscall **)(int, Vector*))(*(int**)(internal + 8) + 0x50 * 4 / 4))(internal, &zero);
    }
}

// ==================== PhysicsObject::SetPawnHeadPos ====================
void __thiscall PhysicsObject::SetPawnHeadPos(const Vector& pos)
{
    if (*(int**)(this + 0x7C) && **(int**)(this + 0x7C))
    {
        Vector head;
        head.x = pos.x;
        head.y = pos.y - *(float*)(this + 0x20) * 0.90000004f;
        head.z = pos.z;

        int internal = **(int**)(this + 0x7C);
        (*(void (__thiscall **)(int, Vector*))(*(int**)(internal + 8) + 0x40 * 4 / 4))(internal, &head);

        if (*(int*)(this + 0x5C))
        {
            // запись в pPlayerData
            *(Vector*)(*(int*)(this + 0x5C) + 0x54) = head;
        }
    }
}

// ==================== PhysicsObject::GetPawnHeadPos ====================
Vector __thiscall PhysicsObject::GetPawnHeadPos() const
{
    Vector result = { 0.0f, 0.0f, 0.0f };
    if (*(int**)(this + 0x7C) && **(int**)(this + 0x7C))
    {
        int internal = **(int**)(this + 0x7C);
        int data = *(int*)(internal + 8);
        result.x = *(float*)(data + 0xB0);
        result.y = *(float*)(this + 0x20) * 0.90000004f + *(float*)(data + 0xB4);
        result.z = *(float*)(data + 0xB8);
    }
    return result;
}

// ==================== PhysicsObject::IsPlayer ====================
bool __thiscall PhysicsObject::IsPlayer()
{
    return *(float**)(this + 0x5C) != nullptr;
}

// ==================== EngineGame::CreatePlayer ====================
Entity* __thiscall EngineGame::CreatePlayer(const char* playerName, bool bKeepOldRagdoll)
{
    World* pWorld = *(World**)((char*)GEngine + 0xE8);

    Entity* pEntity = pWorld->CreateEntity(playerName, 4, 0.0f, 0.3f, (void*)0x102AE778);

    if (!pEntity)
    {
        MessageBoxA(nullptr, "Cannot create player entity!!!", "Error", MB_ICONERROR | 0x40000);
        return nullptr;
    }

    if (!bKeepOldRagdoll && pEntity->pRagdoll)
    {
        pEntity->pRagdoll->~Ragdoll();
        free(pEntity->pRagdoll);
        pEntity->pRagdoll = nullptr;
    }

    Vector spawnPos{ 0.0f, 100.0f, 0.0f };

    void** vtable = *(void***)pEntity;
    void (__thiscall *vf58)(Entity*, Vector*) = (void (__thiscall *)(Entity*, Vector*))vtable[0x58 / 4];
    vf58(pEntity, &spawnPos);

    pWorld->AddEntity(pEntity);

    pEntity->flags |= 0x260;

    pEntity->CreatePhysicsObject(100, -1, 1.0f, true);

    if (pEntity->pPhysics)
        pEntity->pPhysics->ZeroVelocity();

    // SetPawnHeadPos (пример использования)
    // pEntity->pPhysics->SetPawnHeadPos(someHeadPos);

    return pEntity;
}