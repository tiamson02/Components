// EngineGame::CreatePlayer
// Signature: Entity* __thiscall EngineGame::CreatePlayer(const char* playerName, bool bKeepOldRagdoll)
Entity* __thiscall EngineGame::CreatePlayer(EngineGame* this, const char* playerName, bool bKeepOldRagdoll)
{
    World* pWorld = *(World**)((char*)GEngine + 0xE8);

    // Создаём entity
    Entity* pEntity = pWorld->CreateEntity(playerName, 4, 0.0f, 0.3f, (void*)0x102AE778);

    if (pEntity == nullptr)
    {
        MessageBoxA(nullptr, "Cannot create player entity!!!", "Error", MB_ICONERROR | 0x40000);
        return nullptr;
    }

    // Удаляем старый ragdoll, если нужно
    if (!bKeepOldRagdoll)
    {
        Ragdoll* pRagdoll = *(Ragdoll**)((char*)pEntity + 0x7B8);
        if (pRagdoll != nullptr)
        {
            pRagdoll->~Ragdoll();
            free(pRagdoll);
            *(Ragdoll**)((char*)pEntity + 0x7B8) = nullptr;
        }
    }

    // Установка начальной ориентации (sin/cos)
    float angle = 0.0f;                    // в этой версии угол = 0 (возможно yaw)
    float sinVal = sinf(angle);
    float cosVal = cosf(angle);

    // Подготовка вектора
    Vector3 vec = { 0.0f, 100.0f, 0.0f };   // local_1c

    // Вызов виртуальной функции по vtable (offset 0x58)
    void (__thiscall *pVF)(Entity*, Vector3*) = *(void (__thiscall **)(Entity*, Vector3*))(*(DWORD*)pEntity + 0x58);
    pVF(pEntity, &vec);

    // Добавляем в мир
    pWorld->AddEntity(pEntity);

    // Установка флагов
    *(DWORD*)((char*)pEntity + 0x18) |= 0x260;

    // Создаём физику
    pEntity->CreatePhysicsObject(100, -1, 1.0f, true);

    // Обнуляем скорость
    PhysicsObject* pPhys = *(PhysicsObject**)((char*)pEntity + 0xAC);
    if (pPhys)
        pPhys->ZeroVelocity();

    // Установка позиции головы (для камеры)
    if (*(DWORD*)((char*)GEngine + 0xF0) != 0)
    {
        DWORD ptr = *(DWORD*)(*(DWORD*)((char*)GEngine + 0xF0) + 0x5D6BF8);
        if (ptr != 0)
        {
            Vector3 headPos;
            headPos.x = *(float*)(ptr + 0x20) + *(float*)(ptr + 0x2C);
            headPos.y = *(float*)(ptr + 0x24) + *(float*)(ptr + 0x30);
            headPos.z = *(float*)(ptr + 0x28) + *(float*)(ptr + 0x34);

            pPhys->SetPawnHeadPos(&headPos);
        }
    }

    return pEntity;
}