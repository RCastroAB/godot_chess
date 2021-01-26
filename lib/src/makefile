make: linux

all: linux windows html


html: libai.wasm libengine.wasm

linux: libai.so libengine.so

windows: libai.dll libengine.dll

libengine.dll: engine_win.o engine_interface_win.o
	x86_64-w64-mingw32-gcc -shared engine_interface_win.o engine_win.o -o ../bin/libengine.dll

libengine.wasm: engine_em.o engine_interface_em.o
	emcc engine_interface_em.o engine_em.o -s SIDE_MODULE=1 -o ../bin/libengine.wasm

libengine.so: engine.o engine_interface.o
	gcc -rdynamic -shared engine_interface.o engine.o -o ../bin/libengine.so

libai.dll: engine_win.o ai_win.o ai_interface_win.o
	x86_64-w64-mingw32-gcc -shared ai_win.o ai_interface_win.o engine_win.o -o ../bin/libai.dll

libai.wasm:  engine_em.o ai_em.o ai_interface_em.o
	emcc  ai_interface_em.o ai_em.o engine_em.o -s SIDE_MODULE=1 -o ../bin/libai.wasm

libai.so:  engine.o ai.o ai_interface.o
	gcc -rdynamic -shared ai_interface.o ai.o engine.o -o ../bin/libai.so

engine_interface_win.o: engine_interface.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine_interface.c -o engine_interface_win.o

engine_interface_em.o: engine_interface.c
	emcc -std=c11 -fPIC -O2 -s SIDE_MODULE=1 -c -I../godot_headers engine_interface.c -o engine_interface_em.o

engine_interface.o: engine_interface.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine_interface.c -o engine_interface.o

engine_win.o: engine.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine.c -o engine_win.o

engine_em.o: engine.c
	emcc -std=c11 -fPIC -O2 -s SIDE_MODULE=1 -c -I../godot_headers engine.c -o engine_em.o

engine.o: engine.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine.c -o engine.o

ai_win.o: ai.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai.c -o ai_win.o

ai_em.o: ai.c
	emcc -std=c11 -fPIC -O2 -s SIDE_MODULE=1 -c -I../godot_headers ai.c -o ai_em.o

ai.o: ai.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai.c -o ai.o

ai_interface_win.o: ai_interface.c
	x86_64-w64-mingw32-gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai_interface.c -o ai_interface_win.o


ai_interface_em.o: ai_interface.c
	emcc -std=c11 -fPIC -O2 -s SIDE_MODULE=1 -c -I../godot_headers ai_interface.c -o ai_interface_em.o


ai_interface.o: ai_interface.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai_interface.c -o ai_interface.o




clean:
	rm *.o
