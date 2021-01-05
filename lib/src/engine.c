#include "engine.h"
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

#define set_move_noattack(board, x, y, new_x, new_y, index) \
if (0 <= new_x && new_x <= 7 && 0 <= new_y  && new_y <= 7){ \
  if (board->grid[new_x][new_y].piecetype == NONE){ \
    if (!check_setup(board, piece, new_x, new_y, -1, -1)){ \
      board->moves[index][0] = x; \
      board->moves[index][1] = y; \
      board->moves[index][2] = new_x; \
      board->moves[index][3] = new_y; \
      board->moves[index][4] = -1; \
      board->moves[index][5] = -1; \
      index++; \
    } \
  } \
}

#define set_move_basicattack(board, x, y, new_x, new_y, index, color) \
if (0 <= new_x && new_x <= 7 && 0 <= new_y  && new_y <= 7){ \
  if (board->grid[new_x][new_y].piecetype != NONE && board->grid[new_x][new_y].color != color){ \
    if (!check_setup(board, piece, new_x, new_y, new_x, new_y)){ \
      board->moves[index][0] = x; \
      board->moves[index][1] = y; \
      board->moves[index][2] = new_x; \
      board->moves[index][3] = new_y; \
      board->moves[index][4] = new_x; \
      board->moves[index][5] = new_y; \
      index++; \
    } \
  } \
}


#define set_move_moveattack(board, x, y, new_x, new_y, index, color) \
if (0 <= new_x && new_x <= 7 && 0 <= new_y  && new_y <= 7){ \
  if (board->grid[new_x][new_y].piecetype == NONE || board->grid[new_x][new_y].color != color){ \
    if (!check_setup(board, piece, new_x, new_y, new_x, new_y)){ \
      board->moves[index][0] = x; \
      board->moves[index][1] = y; \
      board->moves[index][2] = new_x; \
      board->moves[index][3] = new_y; \
      board->moves[index][4] = new_x; \
      board->moves[index][5] = new_y; \
      index++; \
    } \
  } \
}


#define check_valid_pos(x, y) \
((0 <= x && x < 8) && (0 <= y && y < 8))


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
      board->grid[i][j].id = 0;
    }
  }

}



void fill_board(Board *board){
  enum PieceType preset[] = {ROOK, KNIGHT, BISHOP, KING, QUEEN, BISHOP, KNIGHT, ROOK};
  int id = 1;
  for (int i=0; i <8; i++){
    board->grid[i][1].piecetype = PAWN;
    board->grid[i][1].color = BLACK;
    board->grid[i][1].id = id++;
    board->black->pieces[i] = &(board->grid[i][1]);

    board->grid[i][6].piecetype = PAWN;
    board->grid[i][6].color = WHITE;
    board->grid[i][6].id = id++;
    board->white->pieces[i] = &(board->grid[i][6]);
  }


  for (int i=0; i<8; i++){
    board->grid[i][0].piecetype = preset[i];
    board->grid[i][0].color = BLACK;
    board->grid[i][0].id = id++;
    board->black->pieces[8+i] = &(board->grid[i][0]);


    board->grid[i][7].piecetype = preset[i];
    board->grid[i][7].color = WHITE;
    board->grid[i][7].id = id++;
    board->white->pieces[8+i] = &(board->grid[i][7]);
  }
  board->black->piece_count = 16;
  board->white->piece_count = 16;

}


enum PieceType get_piece(Board *board, int x, int y){
  return board->grid[x][y].piecetype;
}



Board *copy_board(Board *board){
  Board *copy = calloc(sizeof(Board), 1);
  for (int i=0; i<8; i++){
    for (int j=0; j<8; j++){
      copy->grid[i][j] = board->grid[i][j];
    }
  }
  copy->white = calloc(sizeof(Player), 1);
  copy->white->piece_count = board->white->piece_count;
  for (int i=0; i<board->white->piece_count; i++){
    int x, y;
    x = board->white->pieces[i]->x;
    y = board->white->pieces[i]->y;
    copy->white->pieces[i] = &(copy->grid[x][y]);
  }
  copy->black = calloc(sizeof(Player), 1);
  copy->black->piece_count = board->black->piece_count;
  for (int i=0; i<board->black->piece_count; i++){
    int x, y;
    x = board->black->pieces[i]->x;
    y = board->black->pieces[i]->y;
    copy->black->pieces[i] = &(copy->grid[x][y]);
  }
  return copy;
}

int check_setup(Board *board, Piece *piece, int x, int y, int attx, int atty){
  enum Player color = piece->color;
  Board *copy = copy_board(board);
  copy->moves[0][0] = piece->x;
  copy->moves[0][1] = piece->y;
  copy->moves[0][2] = x;
  copy->moves[0][3] = y;
  copy->moves[0][4] = attx;
  copy->moves[0][5] = atty;


  move_piece(copy, piece->color, piece->x, piece->y, x, y);

  return check_check(copy, color);
}

int add_pawn_moves(Board *board, Piece *piece, int index){
  int x = piece->x;
  int y = piece->y;
  enum Player color = piece->color;
  if (color == WHITE){
    if (board->grid[x][y-1].piecetype == NONE){
      set_move_noattack(board, x, y, x, y-1, index);
      if (y==6){
        set_move_noattack(board, x, y, x, y-2, index);
      }
    }
  } else {
    if (board->grid[x][y+1].piecetype == NONE){
      set_move_noattack(board, x, y, x, y+1, index);
      if (y==1){
        set_move_noattack(board, x, y, x, y+2, index);
      }
    }
  }

  if (color== WHITE){
    set_move_basicattack(board, x, y, x+1, y-1, index, color);
    set_move_basicattack(board, x, y, x-1, y-1, index, color);
  } else {
    set_move_basicattack(board, x, y, x+1, y+1, index, color);
    set_move_basicattack(board, x, y, x-1, y+1, index, color);
  }
  return index;
}

int add_rook_moves(Board *board, Piece *piece, int index){
  int directions[4][2] = {
    {1,0},
    {-1,0},
    {0,1},
    {0,-1}
  };
  int x = piece->x;
  int y = piece->y;
  enum Player color = piece->color;
  for (int i=0; i <4; i++){
    for (int steps =1;1;steps++){
      int new_x = x +(directions[i][0]*steps);
      int new_y = y +(directions[i][1]*steps);
      if (0 > new_x || new_x > 7 || 0 > new_y  || new_y > 7)
        break;
      set_move_moveattack(board, x, y, new_x, new_y, index, color);
      if (board->grid[new_x][new_y].piecetype != NONE)
        break;
    }
  }
  return index;
}


int add_knight_moves(Board *board, Piece *piece, int index){
  int directions[8][2] = {
    {1, 2},
    {1, -2},
    {-1, 2},
    {-1, -2},
    {2, -1},
    {-2, 1},
    {-2, -1},
    {2, 1},
  };
  int x = piece->x;
  int y = piece->y;
  enum Player color = piece->color;
  for (int i=0; i<8; i++){
    int new_x = x + directions[i][0];
    int new_y = y + directions[i][1];
    set_move_moveattack(board, x, y, new_x, new_y, index, color);
  }
  return index;
}



int add_bishop_moves(Board *board, Piece *piece, int index){
  int directions[4][2] = {
    {1,1},
    {-1,1},
    {1,-1},
    {-1,-1}
  };
  int x = piece->x;
  int y = piece->y;
  enum Player color = piece->color;
  for (int i=0; i <4; i++){
    for (int steps =1;1;steps++){
      int new_x = x +(directions[i][0]*steps);
      int new_y = y +(directions[i][1]*steps);
      if (0 > new_x || new_x > 7 || 0 > new_y  || new_y > 7)
        break;
      set_move_moveattack(board, x, y, new_x, new_y, index, color);
      if (board->grid[new_x][new_y].piecetype != NONE)
        break;
    }
  }
  return index;
}


int add_king_moves(Board *board, Piece *piece, int index){
  int directions[8][2] = {
    {0,1},
    {0,-1},
    {1,0},
    {1,1},
    {1,-1},
    {-1,0},
    {-1,1},
    {-1,-1},
  };
  int x = piece->x;
  int y = piece->y;
  enum Player color = piece->color;
  for (int i=0; i<8; i++){
    int new_x = x + directions[i][0];
    int new_y = y + directions[i][1];
    if (check_valid_pos(new_x, new_y)){
      set_move_moveattack(board, x, y, new_x, new_y, index, color);
    }
  }
  return index;
}


int add_queen_moves(Board *board, Piece *piece, int index){
  int directions[8][2] = {
    {0,1},
    {0,-1},
    {1,0},
    {1,1},
    {1,-1},
    {-1,0},
    {-1,1},
    {-1,-1},
  };
  int x = piece->x;
  int y = piece->y;
  enum Player color = piece->color;
  for (int i=0; i <8; i++){
    for (int steps =1;1;steps++){
      int new_x = x +(directions[i][0]*steps);
      int new_y = y +(directions[i][1]*steps);
      if (0 > new_x || new_x > 7 || 0 > new_y  || new_y > 7)
        break;
      // if (!check_setup(board, piece, new_x, new_y, new_x, new_y)){
        set_move_moveattack(board, x, y, new_x, new_y, index, color);
      // }
      if (board->grid[new_x][new_y].piecetype != NONE)
        break;
    }
  }
  return index;
}




int add_moves(Board *board, Piece *piece, int index){
  switch (piece->piecetype){
    case PAWN:
      return add_pawn_moves(board, piece, index);
      break;
    case ROOK:
      return add_rook_moves(board, piece, index);
      break;
    case KNIGHT:
      return add_knight_moves(board, piece, index);
      break;
    case BISHOP:
      return add_bishop_moves(board, piece, index);
      break;
    case KING:
      return add_king_moves(board, piece, index);
      break;
    case QUEEN:
      return add_queen_moves(board, piece, index);
      break;
    default:
      break;
  }
  return index;
}


void proccess_moves(Board *board, enum Player player){
  int index = 0;
  if (player == WHITE){
    for (int i=0; i<board->white->piece_count; i++){
      index = add_moves(board, board->white->pieces[i], index);
    }
  } else {
    for (int i=0; i<board->black->piece_count; i++){
      index = add_moves(board, board->black->pieces[i], index);
    }
  }
  board->moves[index][0] = -1;
}

void print_moves(Board *board){
  int i = 0;
  printf("moves:\n");
  while (board->moves[i][0] != -1){
    printf("%d,%d -> %d, %d\n", board->moves[i][0], board->moves[i][1],
      board->moves[i][2], board->moves[i][3]);
    i++;
  }
}


void attack_piece(Board *board, enum Player player, int attx, int atty){
  board->grid[attx][atty].piecetype = NONE;
  board->grid[attx][atty].color = EMPTY;
  enum Player enemy = player == WHITE ? BLACK : WHITE;

  if (enemy == WHITE){
    // find piece to remove
    int i, found =0;
    for (i=0; i < board->white->piece_count; i++){
      if (board->white->pieces[i]->x == attx && board->white->pieces[i]->y == atty){
        found = 1;
        break;
      }
    }
    if (!found)
      return;
    for(i=i+1; i < board->white->piece_count; i++){
      board->white->pieces[i-1] = board->white->pieces[i];
    }
    board->white->piece_count--;
  } else {
    int i, found=0;
    for (i=0; i < board->black->piece_count; i++){
      if (board->black->pieces[i]->x == attx && board->black->pieces[i]->y == atty){
        found = 1;

        break;
      }
    }
    if (!found)
      return;
    for(i=i+1; i < board->black->piece_count; i++){
      board->black->pieces[i-1] = board->black->pieces[i];
    }
    board->black->piece_count--;
  }
}

Player *get_player(Board *board, enum Player player){
  return player== WHITE ? board->white : board->black;
}

int move_piece(Board *board, enum Player player, int x, int y, int new_x, int new_y){
  int i;

  // OPTIM: include the index of the move in the interface for quicker access
  for (i=0; 1; i++){
    if (board->moves[i][0] == -1){
      return 0;
    }
    if (board->moves[i][0] == x && board->moves[i][1] == y &&
      board->moves[i][2] == new_x && board->moves[i][3] == new_y){
      break;
    }
  }
  if (board->moves[i][4] != -1){
    attack_piece(board, player, board->moves[i][4], board->moves[i][5]);
  }
  board->grid[new_x][new_y] = board->grid[x][y];
  board->grid[new_x][new_y].x = new_x;
  board->grid[new_x][new_y].y = new_y;
  board->grid[x][y].piecetype = NONE;
  board->grid[x][y].color = EMPTY;
  Player *p = get_player(board, player);
  for (i=0; i<p->piece_count; i++){
    if (p->pieces[i]->x == x && p->pieces[i]->y == y){
      p->pieces[i] = &(board->grid[new_x][new_y]);
      break;
    }
  }

  return 1;
}

int force_move_piece(Board *board, enum Player player, int x, int y, int new_x, int new_y, int attx, int atty ){
  if (attx != -1){
    attack_piece(board, player, attx, atty);
  }
  board->grid[new_x][new_y] = board->grid[x][y];
  board->grid[new_x][new_y].x = new_x;
  board->grid[new_x][new_y].y = new_y;
  board->grid[x][y].piecetype = NONE;
  board->grid[x][y].color = EMPTY;
  Player *p = get_player(board, player);
  for (int i=0; i<p->piece_count; i++){
    if (p->pieces[i]->x == x && p->pieces[i]->y == y){
      p->pieces[i] = &(board->grid[new_x][new_y]);
      break;
    }
  }

  return 1;
}


int check_check(Board *board, enum Player color){
  Player *player;
  enum Player enemy;
  if (color == WHITE){
    enemy = BLACK;
    player = board->white;
  } else {
    enemy = WHITE;
    player = board->black;
  }
  Piece *king;
  for (int i=0; i<player->piece_count; i++){
    if (player->pieces[i]->piecetype == KING){
      king = player->pieces[i];
      break;
    }
  }

  int x = king->x;
  int y = king->y;
  printf("%d, %d\n", x, y);

  //CHECK KNIGHTS
  int knight_moves[8][2] = {
    {2,1},
    {2,-1},
    {-2,1},
    {-2,-1},
    {1,2},
    {-1,2},
    {-1,-2},
    {1,-2},
  };
  for (int i=0; i<8; i++){
    int new_x = x+knight_moves[i][0], new_y = y+knight_moves[i][1];
    if (check_valid_pos(new_x, new_y)){
      if (board->grid[new_x][new_y].piecetype == KNIGHT && board->grid[new_x][new_y].color == enemy){
        printf("KNIGHT CHECK\n");
        return 1;
      }
    }
  }

  //CHECK PAWN
  if (enemy == BLACK){
    int new_x, new_y;
    new_x = x+1, new_y = y-1;
    if (check_valid_pos(new_x, new_y)){
      if (board->grid[new_x][new_y].piecetype == PAWN && board->grid[new_x][new_y].color == enemy){
        printf("PAWN CHECK\n");
        return 1;
      }
    }
    new_x = x-1, new_y = y-1;
    if (check_valid_pos(new_x, new_y)){
      if (board->grid[new_x][new_y].piecetype == PAWN && board->grid[new_x][new_y].color == enemy){
        printf("PAWN CHECK\n");
        return 1;
      }
    }
  } else {
    int new_x, new_y;
    new_x = x+1, new_y = y+1;
    if (check_valid_pos(new_x, new_y)){
      if (board->grid[new_x][new_y].piecetype == PAWN && board->grid[new_x][new_y].color == enemy){
        printf("PAWN CHECK\n");
        return 1;
      }
    }
    new_x = x-1, new_y = y+1;
    if (check_valid_pos(new_x, new_y)){
      if (board->grid[new_x][new_y].piecetype == PAWN && board->grid[new_x][new_y].color == enemy){
        printf("PAWN CHECK\n");
        return 1;
      }
    }
  }

  //CHECK ROOK/QUEEN
  int rook_moves[4][2] = {
    {0,1},
    {1,0},
    {-1,0},
    {0,-1}
  };
  for (int i=0; i<8; i++){
    int new_x =x, new_y = y;
    for (int j=0; check_valid_pos(new_x, new_y); j++){
      new_x = new_x+rook_moves[i][0], new_y = new_y+rook_moves[i][1];
      if (check_valid_pos(new_x, new_y)){
        if ((board->grid[new_x][new_y].piecetype == ROOK || board->grid[new_x][new_y].piecetype == QUEEN) && board->grid[new_x][new_y].color == enemy){
          printf("ROOK CHECK %d\n", enemy);
          return 1;
        } else if (board->grid[new_x][new_y].piecetype != NONE ){
          break;
        }
      } else {
        break;
      }
    }
  }

  int bishop_moves[4][2] = {
    {1,1},
    {1,-1},
    {-1,1},
    {-1,-1}
  };
  for (int i=0; i<8; i++){
    int new_x =x, new_y = y;
    for (int j=0; check_valid_pos(new_x, new_y); j++){
      new_x = new_x+bishop_moves[i][0], new_y = new_y+bishop_moves[i][1];
      if (check_valid_pos(new_x, new_y)){
        if ((board->grid[new_x][new_y].piecetype == BISHOP || board->grid[new_x][new_y].piecetype == QUEEN) && board->grid[new_x][new_y].color == enemy){
          printf("BISHOP CHECK %d\n", enemy);
          return 1;
        } else if (board->grid[new_x][new_y].piecetype != NONE ){
          break;
        }
      } else {
        break;
      }
    }
  }



  return 0;
}

int check_mate(Board *board, enum Player color){
  if (check_check(board, color)){
    proccess_moves(board, color);
    return board->moves[0][0] == -1;
  } else {
    return 0;
  }
}
