
enum PieceType {NONE=0, PAWN, ROOK, KNIGHT, BISHOP, QUEEN, KING};
enum Player {EMPTY, WHITE, BLACK};

typedef struct piece {
  int x;
  int y;
  enum PieceType piecetype;
  enum Player color;
  int id;
} Piece;

typedef struct player {
  int piece_count;
  int checked;
  Piece *pieces[16];
  Piece *king;
} Player;


typedef struct board {
  Player *white;
  Player *black;
  Piece grid[8][8];
  int moves[150][6];
} Board;


void new_board(Board *board);

void fill_board(Board *board);

enum PieceType get_piece(Board *board, int x, int y);

void proccess_moves(Board *board, enum Player player);

void print_moves(Board *board);

int move_piece(Board *board, enum Player player, int x, int y, int new_x, int new_y);
int force_move_piece(Board *board, enum Player player, int x, int y, int new_x, int new_y, int attx, int atty);

int check_check(Board *board, enum Player color);
int check_mate(Board *board, enum Player color);
