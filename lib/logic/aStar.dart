import 'package:collection/collection.dart';

import '../models/grid.dart';
import '../models/cell.dart';
import 'dart:collection';

class AStar {
  static List<Cell> solve(GridModel grid) {
    final start = grid.find(CellType.start);
    final goal = grid.find(CellType.goal);
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
      print(current.index);

      if (current == goal) {
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
        }
      }
    }

    return [];
  }

  static int _manhattan(Cell a, Cell b) {
    return (a.row - b.row).abs() + (a.col - b.col).abs();
  }

  // List<Cell> aStar(GridModel grid) {
  //   final start = grid.getStart();
  //   final goal = grid.getGoal();
  //
  //   int visitedCount = 0;
  //   int generatedCount = 0;
  //
  //   final openSet = PriorityQueue<AStarNode>((a, b) => a.f.compareTo(b.f));
  //   openSet.add(AStarNode(start, g: 0, h: start.distanceTo(goal)));
  //
  //   final cameFrom = <String, Cell?>{};
  //   final gScore = <String, double>{start.id: 0};
  //   final closedSet = <String>{};
  //
  //   while (openSet.isNotEmpty) {
  //     final current = openSet.removeFirst();
  //     visitedCount++;
  //
  //     if (current.cell.id == goal.id) {
  //       final path = reconstructPath(cameFrom, current.cell);
  //       print("A* Visited: $visitedCount");
  //       print("A* Generated: $generatedCount");
  //       return path;
  //     }
  //
  //     closedSet.add(current.cell.id);
  //
  //     for (var next in grid.getNeighbors(current.cell)) {
  //       if (closedSet.contains(next.id)) continue;
  //
  //       final tentativeG = current.g + 1;
  //
  //       if (!gScore.containsKey(next.id) || tentativeG < gScore[next.id]!) {
  //         cameFrom[next.id] = current.cell;
  //         gScore[next.id] = tentativeG;
  //
  //         final node = AStarNode(
  //           next,
  //           g: tentativeG,
  //           h: next.distanceTo(goal),
  //         );
  //
  //         openSet.add(node);
  //         generatedCount++;
  //       }
  //     }
  //   }
  //
  //   print("A* FAILED");
  //   print("A* Visited: $visitedCount");
  //   print("A* Generated: $generatedCount");
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

class _Node {
  final Cell cell;
  final int f;

  _Node(this.cell, this.f);
}

