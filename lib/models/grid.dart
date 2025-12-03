import 'cell.dart';

class GridModel {
  final int rows;
  final int cols;

  late List<Cell> cells;

  GridModel({required this.rows, required this.cols}) {
    cells = List.generate(rows * cols, (i) {
      final r = i ~/ cols;
      final c = i % cols;
      return Cell(row: r, col: c, type: CellType.empty, index: i);
    });
  }

  /// تحويل (row, col) → index
  int indexOf(int row, int col) => row * cols + col;

  /// جلب خلية عبر row + col
  Cell get(int row, int col) => cells[indexOf(row, col)];

  /// جلب خلية عبر index
  Cell getByIndex(int i) => cells[i];

  /// إعادة تعيين كل الخلايا
  void reset() {
    for (final c in cells) {
      c.type = CellType.empty;
    }
  }

  /// إيجاد خلية حسب النوع (Start – Goal)
  Cell? find(CellType t) {
    for (final c in cells) {
      if (c.type == t) return c;
    }
    return null;
  }

  bool inBounds(int r, int c) {
    return r >= 0 && c >= 0 && r < rows && c < cols;
  }

  /// إرجاع الجيران لأربع اتجاهات
  List<Cell> neighbors(Cell cell) {
    const dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];

    final result = <Cell>[];

    for (final d in dirs) {
      final nr = cell.row + d[0];
      final nc = cell.col + d[1];

      // خارج الحدود؟
      if (nr < 0 || nr >= rows || nc < 0 || nc >= cols) continue;

      final n = get(nr, nc);

      // جدار → لا يمكن المرور
      if (n.type == CellType.wall) continue;

      result.add(n);
    }

    return result;
  }
}
