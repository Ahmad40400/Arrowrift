final Stopwatch gameClock = Stopwatch()..start();

enum ArrowDirection { up, right, down, left }

extension ArrowDirectionX on ArrowDirection {
  int get dx => const [0, 1, 0, -1][index];
  int get dy => const [-1, 0, 1, 0][index];
}

class GridCell {
  final int x;
  final int y;
  const GridCell(this.x, this.y);
}

class ArrowModel {
  final int id;
  final List<GridCell> cells;
  final ArrowDirection direction;

  bool isExiting = false;
  int exitStartMs = -1;
  int exitDurationMs = 500;
  double exitTravelCells = 0;

  int shakeStartMs = -1;

  ArrowModel({required this.id, required this.cells, required this.direction});

  GridCell get head => cells.last;
  int get length => cells.length;
}
