#include <gdnative_api_struct.gen.h>
#include <stdio.h>
#include "engine.h"
#include "ai.h"
#include <stdlib.h>

typedef struct user_data_struct {
	Board *boardcopy;
	enum Player color;
} user_data_struct;

// GDNative supports a large collection of functions for calling back
// into the main Godot executable. In order for your module to have
// access to these functions, GDNative provides your application with
// a struct containing pointers to all these functions.
const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

// These are forward declarations for the functions we'll be implementing
// for our object. A constructor and destructor are both necessary.
GDCALLINGCONV void *ai_constructor(godot_object *p_instance, void *p_method_data);
GDCALLINGCONV void ai_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data);
// godot_variant simple_get_data(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_init_board(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_print_board(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_move_oponent(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_set_moves(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_get_move(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);

// `gdnative_init` is a function that initializes our dynamic library.
// Godot will give it a pointer to a structure that contains various bits of
// information we may find useful among which the pointers to our API structures.
void GDN_EXPORT godot_gdnative_init(godot_gdnative_init_options *p_options) {
	api = p_options->api_struct;

	// Find NativeScript extensions.
	for (int i = 0; i < api->num_extensions; i++) {
		switch (api->extensions[i]->type) {
			case GDNATIVE_EXT_NATIVESCRIPT: {
				nativescript_api = (godot_gdnative_ext_nativescript_api_struct *)api->extensions[i];
			}; break;
			default:
				break;
		};
	};
}

// `gdnative_terminate` which is called before the library is unloaded.
// Godot will unload the library when no object uses it anymore.
void GDN_EXPORT godot_gdnative_terminate(godot_gdnative_terminate_options *p_options) {
	api = NULL;
	nativescript_api = NULL;
}

// `nativescript_init` is the most important function. Godot calls
// this function as part of loading a GDNative library and communicates
// back to the engine what objects we make available.
void GDN_EXPORT godot_nativescript_init(void *p_handle) {
	godot_instance_create_func create = { NULL, NULL, NULL };
	create.create_func = &ai_constructor;

	godot_instance_destroy_func destroy = { NULL, NULL, NULL };
	destroy.destroy_func = &ai_destructor;

	// We first tell the engine which classes are implemented by calling this.
	// * The first parameter here is the handle pointer given to us.
	// * The second is the name of our object class.
	// * The third is the type of object in Godot that we 'inherit' from;
	//   this is not true inheritance but it's close enough.
	// * Finally, the fourth and fifth parameters are descriptions
	//   for our constructor and destructor, respectively.
	nativescript_api->godot_nativescript_register_class(p_handle, "AI", "Reference", create, destroy);

	// godot_instance_method get_data = { NULL, NULL, NULL };
	// get_data.method = &simple_get_data;

	godot_method_attributes attributes = { GODOT_METHOD_RPC_MODE_DISABLED };

	// We then tell Godot about our methods by calling this for each
	// method of our class. In our case, this is just `get_data`.
	// * Our first parameter is yet again our handle pointer.
	// * The second is again the name of the object class we're registering.
	// * The third is the name of our function as it will be known to GDScript.
	// * The fourth is our attributes setting (see godot_method_rpc_mode enum in
	//   `godot_headers/nativescript/godot_nativescript.h` for possible values).
	// * The fifth and final parameter is a description of which function
	//   to call when the method gets called.
	// nativescript_api->godot_nativescript_register_method(p_handle, "AI", "get_data", attributes, get_data);

	godot_instance_method method_init_board = { NULL, NULL, NULL };
	method_init_board.method = &godot_init_board;
	nativescript_api->godot_nativescript_register_method(p_handle, "AI", "init_board", attributes, method_init_board);

	godot_instance_method method_print_board = { NULL, NULL, NULL };
	method_print_board.method = &godot_print_board;
	nativescript_api->godot_nativescript_register_method(p_handle, "AI", "print_board", attributes, method_print_board);


	godot_instance_method method_move_oponent = { NULL, NULL, NULL };
	method_move_oponent.method = &godot_move_oponent;
	nativescript_api->godot_nativescript_register_method(p_handle, "AI", "move_oponent", attributes, method_move_oponent);

	godot_instance_method method_set_moves = { NULL, NULL, NULL };
	method_set_moves.method = &godot_set_moves;
	nativescript_api->godot_nativescript_register_method(p_handle, "AI", "set_moves", attributes, method_set_moves);

	godot_instance_method method_get_move = { NULL, NULL, NULL };
	method_get_move.method = &godot_get_move;
	nativescript_api->godot_nativescript_register_method(p_handle, "AI", "get_move", attributes, method_get_move);

}

// In our constructor, allocate memory for our structure and fill
// it with some data. Note that we use Godot's memory functions
// so the memory gets tracked and then return the pointer to
// our new structure. This pointer will act as our instance
// identifier in case multiple objects are instantiated.
GDCALLINGCONV void *ai_constructor(godot_object *p_instance, void *p_method_data) {
	user_data_struct *user_data = api->godot_alloc(sizeof(user_data_struct));
	user_data->boardcopy = api->godot_alloc(sizeof(Board));
	user_data->boardcopy->white = api->godot_alloc(sizeof(Player));
	user_data->boardcopy->black = api->godot_alloc(sizeof(Player));
	srand(1);
	return user_data;
}

// The destructor is called when Godot is done with our
// object and we free our instances' member data.
GDCALLINGCONV void ai_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
	user_data_struct *user_data = (user_data_struct *)p_user_data;
	api->godot_free(user_data->boardcopy->black);
	api->godot_free(user_data->boardcopy->white);
	api->godot_free(user_data->boardcopy);
	api->godot_free(user_data);
}

// Data is always sent and returned as variants so in order to
// return our data, which is a string, we first need to convert
// our C string to a Godot string object, and then copy that
// string object into the variant we are returning.
// godot_variant simple_get_data(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args) {
// 	user_data_struct *user_data = (user_data_struct *)p_user_data;
// }

godot_variant godot_init_board(godot_object *p_instance, void *p_method_data,
	void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *) p_user_data;
	new_board(user_data->boardcopy);
	fill_board(user_data->boardcopy);

}

godot_variant godot_print_board(godot_object *p_instance, void *p_method_data,
	void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *) p_user_data;
	for (int i=0; i < 8; i++){
		for (int j=0; j<8; j++){
			printf("%d ", user_data->boardcopy->grid[j][i].piecetype);
		}
		printf("\n");
	}
}


godot_variant godot_move_oponent(godot_object *p_instance, void *p_method_data,
	void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *) p_user_data;
	int x, y, new_x, new_y, attx, atty;
	x = api->godot_variant_as_int(p_args[0]);
	y = api->godot_variant_as_int(p_args[1]);
	new_x = api->godot_variant_as_int(p_args[2]);
	new_y = api->godot_variant_as_int(p_args[3]);
	attx = api->godot_variant_as_int(p_args[4]);
	atty = api->godot_variant_as_int(p_args[5]);

	enum Player oponent = user_data->color == WHITE ? BLACK : WHITE;
	force_move_piece(user_data->boardcopy, oponent, x, y, new_x, new_y, attx, atty);
}


godot_variant godot_set_moves(godot_object *p_instance, void *p_method_data,
	void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *) p_user_data;
	godot_variant var_move_array, var_move;
	var_move_array = *p_args[0];
	godot_array move_array = api->godot_variant_as_array(&var_move_array);
	int count = 0;
	while(api->godot_array_size(&move_array)){
		var_move = api->godot_array_pop_front(&move_array);
		godot_pool_int_array move = api->godot_variant_as_pool_int_array(&var_move);
		for (int i=0; i<6; i++){
			user_data->boardcopy->moves[count][i] = api->godot_pool_int_array_get(&move, i);
		}
		api->godot_variant_destroy(&var_move);
		api->godot_pool_int_array_destroy(&move);
		count++;
	}
	user_data->boardcopy->num_moves = count;

}


godot_variant godot_get_move(godot_object *p_instance, void *p_method_data,
	void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *) p_user_data;

	int r = get_move(user_data->boardcopy, user_data->color);

	int *move = user_data->boardcopy->moves[r];
	godot_pool_int_array move_array;
	api->godot_pool_int_array_new(&move_array);
	for (int i=0; i<6; i++){
		api->godot_pool_int_array_push_back(&move_array, move[i]);
	}
	godot_variant var_move_array;
	api->godot_variant_new_pool_int_array(&var_move_array, &move_array);

	return var_move_array;
}
