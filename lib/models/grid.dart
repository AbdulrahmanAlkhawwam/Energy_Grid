import 'dart:math';
import 'cell.dart';

class GridModel {
  final int rows;
  final int cols;
  late List<List<Cell>> cells;

  GridModel({required this.rows, required this.cols}) {
    cells = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => Cell(row: r, col: c, type: CellType.empty),
      ),
    );
  }

  void reset() {
    for (var row in cells) {
      for (var c in row) {
        c.type = CellType.empty;
      }
    }
  }

  Cell? find(CellType t) {
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (cells[r][c].type == t) return cells[r][c];
      }
    }
    return null;
  }

  List<Cell> neighbors(Cell cell) {
    final dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];
    final n = <Cell>[];
    for (var d in dirs) {
      final nr = cell.row + d[0];
      final nc = cell.col + d[1];
      if (nr >= 0 && nr < rows && nc >= 0 && nc < cols) {
        if (cells[nr][nc].type != CellType.wall) n.add(cells[nr][nc]);
      }
    }
    return n;
  }
}
