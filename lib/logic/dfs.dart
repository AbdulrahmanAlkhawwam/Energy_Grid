import '../models/grid.dart';
import '../models/cell.dart';

class DFS {
  static List<Cell> solve(GridModel grid) {
    final start = grid.find(CellType.start);
    final goal = grid.find(CellType.goal);
    if (start == null || goal == null) return [];

    final visited = <String, bool>{};
    final parent = <String, Cell?>{};
    parent['${start.row},${start.col}'] = null;

    bool dfs(Cell current) {
      final key = '${current.row},${current.col}';
      visited[key] = true;

      if (current == goal) return true;

      const dirs = [
        [1, 0],
        [-1, 0],
        [0, 1],
        [0, -1],
      ];

      for (var d in dirs) {
        final nr = current.row + d[0];
        final nc = current.col + d[1];

        if (!grid.inBounds(nr, nc)) continue;

        final next = grid.get(nr, nc);
        if (next.type == CellType.wall) continue;

        final nextKey = '$nr,$nc';

        if (!visited.containsKey(nextKey)) {
          parent[nextKey] = current;

          if (dfs(next)) return true;
        }
      }

      return false;
    }

    dfs(start);
    return _reconstructPath(parent, goal);
  }

  // List<Cell> dfs(GridModel grid) {
  //   final stack = <List<Cell>>[];
  //   final start = grid.getStart();
  //   final goal = grid.getGoal();
  //
  //   int visitedCount = 0;
  //   int generatedCount = 0;
  //
  //   stack.add([start]);
  //   final visited = <String>{start.id};
  //
  //   while (stack.isNotEmpty) {
  //     final path = stack.removeLast();
  //     final cell = path.last;
  //
  //     visitedCount++;
  //
  //     if (cell.id == goal.id) {
  //       print("DFS Visited: $visitedCount");
  //       print("DFS Generated: $generatedCount");
  //       return path;
  //     }
  //
  //     for (var next in grid.getNeighbors(cell)) {
  //       if (!visited.contains(next.id)) {
  //         visited.add(next.id);
  //         final newPath = [...path, next];
  //         stack.add(newPath);
  //         generatedCount++;
  //       }
  //     }
  //   }
  //
  //   print("DFS FAILED");
  //   print("DFS Visited: $visitedCount");
  //   print("DFS Generated: $generatedCount");
  //   return [];
  // }

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
