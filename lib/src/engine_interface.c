#include <gdnative_api_struct.gen.h>
#include <string.h>
#include "engine.h"
#include <stdlib.h>
#include <stdio.h>

typedef struct user_data_struct {
	char data[256];
	Board *board;
} user_data_struct;

// GDNative supports a large collection of functions for calling back
// into the main Godot executable. In order for your module to have
// access to these functions, GDNative provides your application with
// a struct containing pointers to all these functions.
const godot_gdnative_core_api_struct *api = NULL;
const godot_gdnative_ext_nativescript_api_struct *nativescript_api = NULL;

// These are forward declarations for the functions we'll be implementing
// for our object. A constructor and destructor are both necessary.
GDCALLINGCONV void *engine_constructor(godot_object *p_instance, void *p_method_data);
GDCALLINGCONV void engine_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data);
godot_variant engine_get_data(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant engine_get_piece(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_get_board(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_print_moves(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_move_piece(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
godot_variant godot_get_moves(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args);
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
	create.create_func = &engine_constructor;

	godot_instance_destroy_func destroy = { NULL, NULL, NULL };
	destroy.destroy_func = &engine_destructor;

	// We first tell the engine which classes are implemented by calling this.
	// * The first parameter here is the handle pointer given to us.
	// * The second is the name of our object class.
	// * The third is the type of object in Godot that we 'inherit' from;
	//   this is not true inheritance but it's close enough.
	// * Finally, the fourth and fifth parameters are descriptions
	//   for our constructor and destructor, respectively.
	nativescript_api->godot_nativescript_register_class(p_handle, "Engine", "Reference", create, destroy);

	godot_instance_method get_data = { NULL, NULL, NULL };
	get_data.method = &engine_get_data;

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
	nativescript_api->godot_nativescript_register_method(p_handle, "Engine", "get_data", attributes, get_data);

	godot_instance_method get_piece = {NULL, NULL, NULL};
	get_piece.method = &engine_get_piece;

	nativescript_api->godot_nativescript_register_method(p_handle, "Engine", "get_piece", attributes, get_piece);

	godot_instance_method get_board = {NULL, NULL, NULL};
	get_board.method = &godot_get_board;
	nativescript_api->godot_nativescript_register_method(p_handle, "Engine", "get_board", attributes, get_board);

	godot_instance_method method_print_moves = {NULL, NULL, NULL};
	method_print_moves.method = &godot_print_moves;
	nativescript_api->godot_nativescript_register_method(p_handle, "Engine", "print_moves", attributes, method_print_moves);


	godot_instance_method method_move_piece = {NULL, NULL, NULL};
	method_move_piece.method = &godot_move_piece;
	nativescript_api->godot_nativescript_register_method(p_handle, "Engine", "move_piece", attributes, method_move_piece);


	godot_instance_method method_get_moves = {NULL, NULL, NULL};
	method_get_moves.method = &godot_get_moves;
	nativescript_api->godot_nativescript_register_method(p_handle, "Engine", "get_moves", attributes, method_get_moves);

}

// In our constructor, allocate memory for our structure and fill
// it with some data. Note that we use Godot's memory functions
// so the memory gets tracked and then return the pointer to
// our new structure. This pointer will act as our instance
// identifier in case multiple objects are instantiated.
GDCALLINGCONV void *engine_constructor(godot_object *p_instance, void *p_method_data) {
	user_data_struct *user_data = api->godot_alloc(sizeof(user_data_struct));
	do {
			user_data->board = (Board *) api->godot_alloc(sizeof(Board));
	} while(user_data->board == NULL);
	user_data->board->white = api->godot_alloc(sizeof(Player));
	user_data->board->black = api->godot_alloc(sizeof(Player));
	new_board(user_data->board);
	fill_board(user_data->board);
	return user_data;
}

// The destructor is called when Godot is done with our
// object and we free our instances' member data.
GDCALLINGCONV void engine_destructor(godot_object *p_instance, void *p_method_data, void *p_user_data) {
	user_data_struct *user_data = (user_data_struct *)p_user_data;
	free(user_data->board);
	api->godot_free(user_data);
}

// Data is always sent and returned as variants so in order to
// return our data, which is a string, we first need to convert
// our C string to a Godot string object, and then copy that
// string object into the variant we are returning.
godot_variant engine_get_data(godot_object *p_instance, void *p_method_data, void *p_user_data, int p_num_args, godot_variant **p_args) {
	godot_string data;
	godot_variant ret;
	user_data_struct *user_data = (user_data_struct *)p_user_data;

	api->godot_string_new(&data);
	api->godot_string_parse_utf8(&data, user_data->data);
	api->godot_variant_new_string(&ret, &data);
	api->godot_string_destroy(&data);
	return ret;
}

godot_variant engine_get_piece(godot_object *p_instance, void *p_method_data,
				void *p_user_data, int p_num_args, godot_variant **p_args){
	godot_variant ret;

	user_data_struct *user_data = (user_data_struct *)p_user_data;
	int x = api->godot_variant_as_int(p_args[0]);
	int y = api->godot_variant_as_int(p_args[1]);
	int piece = get_piece(user_data->board, x, y);
	api->godot_variant_new_int(&ret, piece);

	return ret;
}


godot_variant godot_get_board(godot_object *p_instance, void *p_method_data,
				void *p_user_data, int p_num_args, godot_variant **p_args){
	printf("there is an error\n");
	user_data_struct *user_data = (user_data_struct *)p_user_data;
	godot_dictionary dict;
	api->godot_dictionary_new(&dict);
	for (int i=0; i < user_data->board->white->piece_count; i++){
		printf("%d\n", i);
		Piece * p = user_data->board->white->pieces[i];
		godot_variant piecetype;
		godot_vector2 vec;
		api->godot_variant_new_int(&piecetype, p->piecetype);
		api->godot_vector2_new(&vec, p->x, p->y);
		godot_variant var_vec;
		api->godot_variant_new_vector2(&var_vec, &vec);
		api->godot_dictionary_set(&dict, &var_vec, &piecetype);
	}
	for (int i=0; i < user_data->board->black->piece_count; i++){
		Piece * p = user_data->board->black->pieces[i];
		godot_variant piecetype;
		godot_vector2 vec;
		api->godot_variant_new_int(&piecetype, p->piecetype);
		api->godot_vector2_new(&vec, p->x, p->y);
		godot_variant var_vec;
		api->godot_variant_new_vector2(&var_vec, &vec);
		api->godot_dictionary_set(&dict, &var_vec, &piecetype);
	}

	godot_variant var_dict;
	api->godot_variant_new_dictionary(&var_dict, &dict);
	return var_dict;
}

godot_variant godot_print_moves(godot_object *p_instance, void *p_method_data,
				void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *)p_user_data;
	proccess_moves(user_data->board, WHITE);
	print_moves(user_data->board);
	godot_variant ret;
	api->godot_variant_new_int(&ret, 1);
	return ret;
}


godot_variant godot_move_piece(godot_object *p_instance, void *p_method_data,
				void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *)p_user_data;
	proccess_moves(user_data->board, WHITE);
	int x,y,new_x, new_y;
	x = user_data->board->moves[0][0];
	y = user_data->board->moves[0][1];
	new_x = user_data->board->moves[0][2];
	new_y = user_data->board->moves[0][3];
	move_piece(user_data->board, WHITE, x, y, new_x, new_y);
	godot_variant ret;
	api->godot_variant_new_int(&ret, 1);
	return ret;
}



godot_variant godot_get_moves(godot_object *p_instance, void *p_method_data,
				void *p_user_data, int p_num_args, godot_variant **p_args){
	user_data_struct *user_data = (user_data_struct *)p_user_data;
	if (p_num_args < 1){
		godot_variant ret;
		api->godot_variant_new_int(&ret, 1);
		return ret;
	}
	enum Player p;
	p = api->godot_variant_as_int(p_args[0]);
	proccess_moves(user_data->board, p);

	godot_array array;
	api->godot_array_new(&array);
	for (int i=0; user_data->board->moves[i][0] != -1; i++){
		godot_pool_int_array move;
		api->godot_pool_int_array_new(&move);
		for (int j=0; j < 6; j++){
			godot_int coord = user_data->board->moves[i][j];

			api->godot_pool_int_array_push_back(&move, coord);
		}
		godot_variant var_move;
		api->godot_variant_new_pool_int_array(&var_move, &move);
		api->godot_array_push_back(&array, &var_move);
		api->godot_pool_int_array_destroy(&move);
	}

	godot_variant varray;
	api->godot_variant_new_array(&varray, &array);
	api->godot_array_destroy(&array);
	return varray;
}
