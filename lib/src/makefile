make: linux

all:
	make linux
	make clean
	make windows

linux: libai.so libengine.so

windows: libai.dll libengine.dll

libengine.dll: engine_win.o engine_interface_win.o
	x86_64-w64-mingw32-gcc -shared engine_interface_win.o engine_win.o -o ../bin/libengine.dll

libengine.so: engine.o engine_interface.o
	gcc -rdynamic -shared engine_interface.o engine.o -o ../bin/libengine.so

libai.dll: engine_win.o ai_win.o ai_interface_win.o
	x86_64-w64-mingw32-gcc -shared ai_win.o ai_interface_win.o engine_win.o -o ../bin/libai.dll

libai.so:  engine.o ai.o ai_interface.o
	gcc -rdynamic -shared ai_interface.o ai.o engine.o -o ../bin/libai.so

engine_interface_win.o: engine_interface.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine_interface.c -o engine_interface_win.o

engine_interface.o: engine_interface.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine_interface.c -o engine_interface.o

engine_win.o: engine.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine.c -o engine_win.o

engine.o: engine.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine.c -o engine.o

ai_win.o: ai.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai.c -o ai_win.o

ai.o: ai.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai.c -o ai.o

ai_interface_win.o: ai_interface.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai_interface.c -o ai_interface_win.o

ai_interface.o: ai_interface.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai_interface.c -o ai_interface.o




clean:
	rm *.o
