import '../models/grid.dart';
import '../models/cell.dart';

class BFS {
  static List<Cell> solve(GridModel grid) {
    final start = grid.find(CellType.start);
    final goal = grid.find(CellType.goal);
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
      print(current.index);
      if (current == goal) {
        return _reconstructPath(parent, goal);
      }

      for (var d in dirs) {
        final nr = current.row + d[0];
        final nc = current.col + d[1];

        if (!grid.inBounds(nr, nc)) continue;

        final next = grid.get(nr, nc);
        if (next.type == CellType.wall) continue; // can't pass wall

        final key = '$nr,$nc';
        if (!visited.containsKey(key)) {
          visited[key] = next;
          parent[key] = current;
          queue.add(next);
        }
      }
    }

    return [];
  }

  // List<Cell> bfs(GridModel grid) {
  //   final queue = Queue<List<Cell>>();
  //   final start = grid.getStart();
  //   final goal = grid.getGoal();
  //
  //   int visitedCount = 0;
  //   int generatedCount = 0;
  //
  //   queue.add([start]);
  //   final visited = <String>{start.id};
  //
  //   while (queue.isNotEmpty) {
  //     final path = queue.removeFirst();
  //     final cell = path.last;
  //
  //     visitedCount++;
  //
  //     if (cell.id == goal.id) {
  //       print("BFS Visited: $visitedCount");
  //       print("BFS Generated: $generatedCount");
  //       return path;
  //     }
  //
  //     for (var next in grid.getNeighbors(cell)) {
  //       if (!visited.contains(next.id)) {
  //         visited.add(next.id);
  //         final newPath = [...path, next];
  //         queue.add(newPath);
  //         generatedCount++;
  //       }
  //     }
  //   }
  //
  //   print("BFS FAILED");
  //   print("BFS Visited: $visitedCount");
  //   print("BFS Generated: $generatedCount");
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
