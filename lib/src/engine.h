#include "common.h"

void new_board(Board *board);

void fill_board(Board *board);

enum PieceType get_piece(Board *board, int x, int y);

void proccess_moves(Board *board, enum Player player);

void print_moves(Board *board);

int move_piece(Board *board, enum Player player, int x, int y, int new_x, int new_y);
int force_move_piece(Board *board, enum Player player, int x, int y, int new_x, int new_y, int attx, int atty);

int check_check(Board *board, enum Player color);
int check_mate(Board *board, enum Player color);


Board *copy_board(Board *board);


Player *get_player(Board *board, enum Player player);
