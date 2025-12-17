import 'package:collection/collection.dart';

import '../models/grid.dart';
import '../models/cell.dart';

class UCS {
  static List<Cell> solve(GridModel grid) {
    final start = grid.find(CellType.start);
    final goal = grid.find(CellType.goal);
    int visitedCount = 0;
    int generatedCount = 0;
    if (start == null || goal == null) return [];

    final open = PriorityQueue<_Node>((a, b) => a.f.compareTo(b.f));
    final gScore = <String, int>{};
    final parent = <String, Cell?>{};

    String key(Cell c) => '${c.row},${c.col}';

    gScore[key(start)] = 0;
    parent[key(start)] = null;
    open.add(_Node(start, 0));

    const dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];

    while (open.isNotEmpty) {
      final current = open.removeFirst().cell;
      visitedCount++;
      print(current.index);

      if (current == goal) {
        print("ucs Visited: $visitedCount");
        print("ucs Generated: $generatedCount");
        return _reconstructPath(parent, goal);
      }

      for (var d in dirs) {
        final nr = current.row + d[0];
        final nc = current.col + d[1];

        if (!grid.inBounds(nr, nc)) continue;

        final next = grid.get(nr, nc);
        if (next.type == CellType.wall) continue;

        final kCurr = key(current);
        final kNext = key(next);

        final tentative = gScore[kCurr]! + next.cost();

        if (tentative < (gScore[kNext] ?? 999999999)) {
          gScore[kNext] = tentative;
          parent[kNext] = current;
          final h = _manhattan(next, goal);
          final f = tentative + h;

          open.add(_Node(next, f));
          generatedCount++;
        }
      }
    }
    print("ucs FAILED");
    print("ucs Visited: $visitedCount");
    print("ucs Generated: $generatedCount");
    return [];
  }

  static int _manhattan(Cell a, Cell b) {
    return (a.row - b.row).abs() + (a.col - b.col).abs();
  }

  static List<Cell> _reconstructPath(Map<String, Cell?> parent, Cell goal) {
    final path = <Cell>[];
    Cell? current = goal;

    while (current != null) {
      path.add(current);
      print('${current.row},${current.col}');
      current = parent['${current.row},${current.col}'];
    }

    return path.reversed.toList();
  }
}

class _Node {
  final Cell cell;
  final int f;

  _Node(this.cell, this.f);
}
