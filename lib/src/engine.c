#include "engine.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

void new_board(Board *board){


  board->white.color = 0;
  board->white.piece_count = 16;
  board->white.checked = 0;

  board->black.color = 1;
  board->black.piece_count = 16;
  board->black.checked = 0;

  for (int i=0; i <8; i++){
    for (int j=0; j<8; j++){
      board->grid[i][j] = 0;
    }
  }


}

void free_board(Board *board){
  free(board);
}

enum Piece get_piece(Board *board, int x, int y){
  return board->grid[x][y];
}
