#include "engine.h"
#include "ai.h"
#include <stdlib.h>

void set_moves(Board *board, int **moves){
  for (int i=0; 1; i++){
    if (moves[i][0] == -1)
      break;
    board->moves[i][0] = moves[i][0];
    board->moves[i][1] = moves[i][1];
    board->moves[i][2] = moves[i][2];
    board->moves[i][3] = moves[i][3];
    board->moves[i][4] = moves[i][4];
    board->moves[i][5] = moves[i][5];
  }
}


float evaluate_player(Player *p){
  float value = 0;
  for(int i=0; i<p->piece_count; i++){
    switch (p->pieces[i]->piecetype){
      case KING:
        value += 10;
        break;
      case QUEEN:
        value += 5;
        break;
      case KNIGHT:
        value += 3;
        break;
      case BISHOP:
        value += 3;
        break;
      case ROOK:
        value += 4;
        break;
      case PAWN:
        value += 1;
        break;
      default:
        break;
    }
  }
  return value;
}

float evaluate_board(Board *board, enum Player color){
  enum Player opponent = color == WHITE ? BLACK : WHITE;
  float value = 0;
  if (check_check(board, opponent)){
    if (check_mate(board, opponent)){
      return 100.0;
    } else {
      value += 10.0;
    }
  } else if (check_check(board, color)){
    if (check_mate(board, color)){
      return -100.0;
    } else {
      value += -10.0;
    }
  }
  Player *player = get_player(board, color);
  Player *enemy = get_player(board, opponent);
  value += evaluate_player(player);
  value -= evaluate_player(enemy);
  return value;
}

Board *get_child(Board *board, int i, enum Player color){
  Board *copy = copy_board(board);
  copy->moves[0][0] = board->moves[i][0];
  copy->moves[0][1] = board->moves[i][1];
  copy->moves[0][2] = board->moves[i][2];
  copy->moves[0][3] = board->moves[i][3];
  copy->moves[0][4] = board->moves[i][4];
  copy->moves[0][5] = board->moves[i][5];


  move_piece(copy, color, copy->moves[0][0], copy->moves[0][1], copy->moves[0][2], copy->moves[0][3]);

  return copy;
}






int get_move(Board *board, enum Player color){
  float max_value = -999999;
  int best_move = rand() % board->num_moves;
  for (int i=0; i < board->num_moves; i++){
    Board *child = get_child(board, i, color);
    float value = evaluate_board(child, color);
    if (value > max_value){
      max_value = value;
      best_move = i;
    }
  }
  return best_move;
}
