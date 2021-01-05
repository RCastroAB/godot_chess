
#include "engine.h"


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
