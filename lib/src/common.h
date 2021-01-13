#ifndef COMMON_H
#define COMMON_H


enum PieceType {NONE=0, PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING};
enum Player {EMPTY, WHITE, BLACK};

typedef struct piece {
  int x;
  int y;
  enum PieceType piecetype;
  enum Player color;
  int id;
  int moved;
} Piece;

typedef struct player {
  int piece_count;
  int checked;
  Piece *pieces[16];
  Piece *king;
} Player;


typedef struct board {
  int num_moves;
  Player *white;
  Player *black;
  Piece grid[8][8];
  int moves[150][6];
} Board;

#endif
