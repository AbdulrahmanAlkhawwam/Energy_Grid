import '../models/grid.dart';
import '../models/cell.dart';
import 'simple_priority_queue.dart';

class _Node {
  final int r, c, cost;
  _Node(this.r, this.c, this.cost);
}

int dijkstraMinCost(GridModel g) {
  final start = g.find(CellType.start);
  final goal = g.find(CellType.goal);
  if (start == null || goal == null) return 1000000;

  final dist = List.generate(g.rows, (_) => List.filled(g.cols, 1 << 30));
  final visited = List.generate(g.rows, (_) => List.filled(g.cols, false));
  final pq = SimplePriorityQueue<_Node>((a, b) => a.cost - b.cost);

  dist[start.row][start.col] = 0;
  pq.add(_Node(start.row, start.col, 0));

  while (pq.isNotEmpty) {
    final cur = pq.removeFirst();
    if (visited[cur.r][cur.c]) continue;
    visited[cur.r][cur.c] = true;
    if (cur.r == goal.row && cur.c == goal.col) break;
    for (var n in g.neighbors(g.cells[cur.r][cur.c])) {
      final nc = cur.cost + n.cost();
      if (nc < dist[n.row][n.col]) {
        dist[n.row][n.col] = nc;
        pq.add(_Node(n.row, n.col, nc));
      }
    }
  }
  return dist[goal.row][goal.col];
}
