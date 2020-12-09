
enum Piece {PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING};


typedef struct player {
  int color;
  int piece_count;
  int checked;
} Player;


typedef struct board {
  Player white;
  Player black;
  enum Piece grid[8][8];
} Board;



void new_board(Board *board);

void free_board();

enum Piece get_piece(Board *board, int x, int y);
