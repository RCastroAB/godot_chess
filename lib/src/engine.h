
enum PieceType {NONE=0, PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING};
enum Player {WHITE, BLACK};

typedef struct piece {
  int x;
  int y;
  enum PieceType piecetype;
  int color;
} Piece;

typedef struct player {
  int piece_count;
  int checked;
  Piece *pieces[16];
} Player;


typedef struct board {
  Player *white;
  Player *black;
  Piece grid[8][8];
  int moves[150][2];
} Board;


void new_board(Board *board);

void fill_board();

enum PieceType get_piece(Board *board, int x, int y);
