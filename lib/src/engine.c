#include "engine.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>


void new_board(Board *board){


  // board->white.color = 0;
  board->white->piece_count = 0;
  board->white->checked = 0;

  // board->black.color = 1;
  board->black->piece_count = 0;
  board->black->checked = 0;

  for (int i=0; i <8; i++){
    for (int j=0; j<8; j++){
      board->grid[i][j].piecetype = NONE;
      board->grid[i][j].x = i;
      board->grid[i][j].y = j;
    }
  }

}



void fill_board(Board *board){
  enum PieceType preset[] = {ROOK, KNIGHT, KING, QUEEN, BISHOP, KNIGHT, ROOK};

  for (int i=0; i <8; i++){
    board->grid[i][1].piecetype = PAWN;
    board->black->pieces[i] = &(board->grid[i][1]);

    board->grid[i][6].piecetype = PAWN;
    board->white->pieces[i] = &(board->grid[i][6]);
  }


  for (int i=0; i<8; i++){
    board->grid[i][0].piecetype = preset[i];
    board->black->pieces[8+i] = &(board->grid[i][0]);

    board->grid[i][7].piecetype = preset[i];
    board->white->pieces[8+i] = &(board->grid[i][7]);
  }
  board->black->piece_count = 16;
  board->white->piece_count = 16;

}


enum PieceType get_piece(Board *board, int x, int y){
  return board->grid[x][y].piecetype;
}

int add_pawn_moves(Board *board, Piece *piece, int index){
  
}


int add_moves(Board *board, Piece *piece, int index){
  switch (piece->piecetype){
    case PAWN:
      break;
    case NONE:
      break;
  }
}


void proccess_moves(Board *board, enum Player player){
  int index = 0;
  if (player == WHITE){
    for (int i=0; i<board->white->piece_count; i++){
      index += add_moves(board, board->white->pieces[i], index);
    }
  } else {

  }
}
