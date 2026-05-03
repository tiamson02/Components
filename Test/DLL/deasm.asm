
/* public: void __thiscall PhysicsObject::SetPawnHeadPos(class Vector const &) */

void __thiscall PhysicsObject::SetPawnHeadPos(PhysicsObject *this,Vector *param_1)

{
  int iVar1;
  int iVar2;
  float *pfVar3;
  undefined4 local_20;
  float local_1c;
  undefined4 local_18;
  undefined4 local_14;
  
                    /* 0x18bd20  2434  ?SetPawnHeadPos@PhysicsObject@@QAEXABVVector@@@Z */
  if (**(int **)(this + 0x7c) != 0) {
    local_20 = *(undefined4 *)param_1;
    local_14 = 0;
    local_1c = *(float *)(param_1 + 4) - *(float *)(this + 0x20) * 0.90000004;
    local_18 = *(undefined4 *)(param_1 + 8);
    iVar1 = **(int **)(this + 0x7c);
    iVar2 = FUN_101fb760(iVar1);
    if (((char)iVar2 == '\0') && (*(int *)(iVar1 + 0x10) != 0)) {
      FUN_101fb770(iVar1);
    }
    if (((*(byte *)(iVar1 + 0xc) & 1) == 0) || (*(int *)(iVar1 + 0x44) == 0)) {
      (**(code **)(**(int **)(iVar1 + 8) + 0x40))(&local_20);
    }
    if (*(int *)(this + 0x5c) != 0) {
      *(undefined4 *)(*(int *)(this + 0x5c) + 0x54) = local_20;
      *(float *)(*(int *)(this + 0x5c) + 0x58) = local_1c;
      *(undefined4 *)(*(int *)(this + 0x5c) + 0x5c) = local_18;
      pfVar3 = (float *)GetPivotOffset(this);
      iVar1 = *(int *)(this + 0x5c);
      *(float *)(iVar1 + 0x54) = *(float *)(iVar1 + 0x54) + *pfVar3;
      *(float *)(iVar1 + 0x58) = pfVar3[1] + *(float *)(iVar1 + 0x58);
      *(float *)(iVar1 + 0x5c) = pfVar3[2] + *(float *)(iVar1 + 0x5c);
      if (*(void **)(*(int *)(this + 0x5c) + 0x90) != (void *)0x0) {
        FUN_1019fb00(*(void **)(*(int *)(this + 0x5c) + 0x90),&local_20);
      }
    }
  }
  return;
}

