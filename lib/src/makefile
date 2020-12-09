make: engine.o engine_interface.o
	gcc -rdynamic -shared engine_interface.o engine.o -o ../bin/libengine.so


engine_interface.o: engine_interface.c
	gcc -std=c11 -fPIC -c -I../godot_headers engine_interface.c -o engine_interface.o


engine.o: engine.c
	gcc -std=c11 -fPIC -c -I../godot_headers engine.c -o engine.o
