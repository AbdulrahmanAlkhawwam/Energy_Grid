import '../models/grid.dart';
import '../models/cell.dart';

class BFS {
  static List<Cell> solve(GridModel grid) {
    final start = grid.find(CellType.start);
    final goal = grid.find(CellType.goal);
    int visitedCount = 0;
    int generatedCount = 0;
    if (start == null || goal == null) return [];

    final queue = <Cell>[start];
    final visited = <String, Cell>{};
    visited['${start.row},${start.col}'] = start;

    final parent = <String, Cell?>{};
    parent['${start.row},${start.col}'] = null;

    const dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1],
    ];

    while (queue.isNotEmpty) {
      final current = queue.removeAt(0);
      visitedCount++;
      print(current.index);
      if (current == goal) {
        print("BFS Visited: $visitedCount");
        print("BFS Generated: $generatedCount");
        return _reconstructPath(parent, goal);
      }

      for (var d in dirs) {
        final nr = current.row + d[0];
        final nc = current.col + d[1];

        if (!grid.inBounds(nr, nc)) continue;

        final next = grid.get(nr, nc);
        if (next.type == CellType.wall) continue;

        final key = '$nr,$nc';
        if (!visited.containsKey(key)) {
          visited[key] = next;
          parent[key] = current;
          queue.add(next);
          generatedCount++;
        }
      }
    }
    print("BFS FAILED");
    print("BFS Visited: $visitedCount");
    print("BFS Generated: $generatedCount");
    return [];
  }

  static List<Cell> _reconstructPath(Map<String, Cell?> parent, Cell goal) {
    final path = <Cell>[];
    Cell? current = goal;

    while (current != null) {
      path.add(current);
      current = parent['${current.row},${current.col}'];
    }

    return path.reversed.toList();
  }
}
