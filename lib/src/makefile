make: libai libengine


libengine: engine.o engine_interface.o ai.o ai_interface.o
	gcc -rdynamic -shared engine_interface.o engine.o -o ../bin/libengine.so

libai:  engine.o ai.o ai_interface.o
	gcc -rdynamic -shared ai_interface.o ai.o engine.o -o ../bin/libai.so

engine_interface.o: engine_interface.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine_interface.c -o engine_interface.o


engine.o: engine.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers engine.c -o engine.o

ai.o: ai.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai.c -o ai.o

ai_interface.o: ai_interface.c
	gcc -std=c11 -fPIC -O2 -c -I../godot_headers ai_interface.c -o ai_interface.o


clean:
	rm *.o
