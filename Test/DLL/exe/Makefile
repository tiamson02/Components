# Makefile for compiling Painkiller reconstructed source

CC = cl
CFLAGS = /EHsc /std:c++17
LDFLAGS_EXE = /link user32.lib gdi32.lib ws2_32.lib d3d9.lib
LDFLAGS_DLL = /link /DLL

all: ENGINE.dll Painkiller.exe

ENGINE.dll: DllMain.obj EngineGame.obj
	$(CC) $(LDFLAGS_DLL) DllMain.obj EngineGame.obj /out:ENGINE.dll

Painkiller.exe: Painkiller.obj
	$(CC) Painkiller.obj $(LDFLAGS_EXE) /out:Painkiller.exe

DllMain.obj: DllMain.cpp EngineGame.h
	$(CC) $(CFLAGS) /c DllMain.cpp

EngineGame.obj: EngineGame.cpp EngineGame.h
	$(CC) $(CFLAGS) /c EngineGame.cpp

Painkiller.obj: Painkiller.cpp EngineGame.h
	$(CC) $(CFLAGS) /c Painkiller.cpp

clean:
	del *.obj *.dll *.exe *.lib *.exp