enum CellType { empty, weighted, wall, start, goal, pathTaken }

class Cell {
  CellType type;
  int row, col;
  int index;
  Cell({
    required this.row,
    required this.col,
    this.type = CellType.empty,
    required this.index,
  });

  int cost() {
    switch (type) {
      case CellType.weighted:
        return 5;
      case CellType.empty:
      case CellType.start:
      case CellType.goal:
      case CellType.pathTaken:
        return 1;
      case CellType.wall:
        return 1000000;
    }
  }

  Cell copyWith({CellType? type}) {
    return Cell(row: row, col: col, type: type ?? this.type, index: index);
  }
}
