import 'dart:math';
import '../models/grid.dart';
import '../models/cell.dart';

class GridRandomizer {
  /// Main function: randomize the grid with difficulty level
  static void randomizeWithLevel(GridModel grid, int level) {
    final rows = grid.rows;
    final cols = grid.cols;
    final cells = grid.cells;
    final rnd = Random();

    // --- difficulty probabilities ---
    double baseWallProb;
    double baseWeightProb;

    switch (level) {
      case 1:
        baseWallProb = 0.06;
        baseWeightProb = 0.06;
        break;
      case 2:
        baseWallProb = 0.12;
        baseWeightProb = 0.18;
        break;
      case 3:
        baseWallProb = 0.22;
        baseWeightProb = 0.24;
        break;
      case 4:
        baseWallProb = 0.36;
        baseWeightProb = 0.30;
        break;
      default:
        baseWallProb = 0.12;
        baseWeightProb = 0.18;
    }

    // --- fill all as wall first ---
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        cells[r][c].type = CellType.wall;
      }
    }

    // --- pick Start & Goal with minimum distance depending on level ---
    int startR = rnd.nextInt(rows);
    int startC = rnd.nextInt(cols);
    int goalR, goalC;

    final gridScale = rows + cols;
    final minDistances = [
      0,
      (gridScale / 6).round(),
      (gridScale / 4).round(),
      (gridScale / 3).round(),
      (gridScale / 2).round(),
    ];

    final minDist = minDistances[level.clamp(1, 4)];

    int attempts = 0;
    do {
      goalR = rnd.nextInt(rows);
      goalC = rnd.nextInt(cols);
      attempts++;
      if (attempts > 200) break;
    } while ((startR == goalR && startC == goalC) ||
        ((startR - goalR).abs() + (startC - goalC).abs()) < minDist);

    cells[startR][startC].type = CellType.start;
    cells[goalR][goalC].type = CellType.goal;

    // --- carve main path ---
    List<Point<int>> path = _carvePath(
      rows,
      cols,
      startR,
      startC,
      goalR,
      goalC,
      level,
    );
    for (final p in path) {
      if (cells[p.x][p.y].type != CellType.start &&
          cells[p.x][p.y].type != CellType.goal) {
        cells[p.x][p.y].type = CellType.empty;
      }
    }

    // --- compute distance to path ---
    final dist = _computeDistToPath(rows, cols, path);

    // --- fill other cells based on level + distance ---
    bool placedWeighted = false;

    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (cells[r][c].type == CellType.start ||
            cells[r][c].type == CellType.goal ||
            path.any((p) => p.x == r && p.y == c)) {
          continue;
        }

        double wallProb = baseWallProb;
        double weightProb = baseWeightProb;

        int d = dist[r][c];

        if (d == 1) {
          if (level >= 3) {
            wallProb += 0.20;
            weightProb += 0.10;
          } else {
            wallProb -= 0.10;
            weightProb -= 0.05;
          }
        }

        final p = rnd.nextDouble();
        if (p < wallProb) {
          cells[r][c].type = CellType.wall;
        } else if (p < wallProb + weightProb) {
          cells[r][c].type = CellType.weighted;
          placedWeighted = true;
        } else {
          cells[r][c].type = CellType.empty;
        }
      }
    }

    // ensure at least one weighted
    if (!placedWeighted) {
      outer:
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          if (cells[r][c].type == CellType.empty) {
            cells[r][c].type = CellType.weighted;
            break outer;
          }
        }
      }
    }
  }

  // -------------------------------------------------------------------------
  // ---------------------- Helper Functions ---------------------------------
  // -------------------------------------------------------------------------

  static List<Point<int>> _carvePath(
    int rows,
    int cols,
    int sr,
    int sc,
    int gr,
    int gc,
    int level,
  ) {
    final rnd = Random();

    final bias = (0.85 - 0.15 * (level - 1)).clamp(
      0.2,
      0.85,
    ); // higher level -> longer path
    final extraLength = ((rows + cols) * (0.10 * (level - 1))).round();
    final manhattan = (sr - gr).abs() + (sc - gc).abs();
    final targetLength = manhattan + extraLength;

    int cr = sr, cc = sc;
    final visited = List.generate(rows, (_) => List<bool>.filled(cols, false));
    visited[cr][cc] = true;

    List<Point<int>> path = [Point(cr, cc)];

    int safety = 0;
    while ((cr != gr || cc != gc) || path.length < targetLength) {
      safety++;
      if (safety > rows * cols * 10) break;

      final neighbors = <Point<int>>[];

      if (cr > 0 && !visited[cr - 1][cc]) neighbors.add(Point(cr - 1, cc));
      if (cr < rows - 1 && !visited[cr + 1][cc])
        neighbors.add(Point(cr + 1, cc));
      if (cc > 0 && !visited[cr][cc - 1]) neighbors.add(Point(cr, cc - 1));
      if (cc < cols - 1 && !visited[cr][cc + 1])
        neighbors.add(Point(cr, cc + 1));

      if (neighbors.isEmpty) {
        if (path.length <= 1) break;
        final last = path.removeLast();
        cr = last.x;
        cc = last.y;
        continue;
      }

      neighbors.sort((a, b) {
        final da = (a.x - gr).abs() + (a.y - gc).abs();
        final db = (b.x - gr).abs() + (b.y - gc).abs();
        return da.compareTo(db);
      });

      Point<int> pick;
      if (rnd.nextDouble() < bias) {
        final half = (neighbors.length / 2).ceil();
        pick = neighbors[rnd.nextInt(half)];
      } else {
        pick = neighbors[rnd.nextInt(neighbors.length)];
      }

      cr = pick.x;
      cc = pick.y;
      visited[cr][cc] = true;
      path.add(pick);

      if (cr == gr && cc == gc && path.length >= targetLength) break;
    }

    // if goal not reached, connect directly
    if (!path.any((p) => p.x == gr && p.y == gc)) {
      cr = path.last.x;
      cc = path.last.y;
      while (cr != gr || cc != gc) {
        if (cr < gr)
          cr++;
        else if (cr > gr)
          cr--;
        else if (cc < gc)
          cc++;
        else if (cc > gc)
          cc--;
        path.add(Point(cr, cc));
      }
    }

    return path;
  }

  static List<List<int>> _computeDistToPath(
    int rows,
    int cols,
    List<Point<int>> path,
  ) {
    final dist = List.generate(rows, (_) => List<int>.filled(cols, 99999));
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        for (final p in path) {
          final d = (p.x - r).abs() + (p.y - c).abs();
          if (d < dist[r][c]) dist[r][c] = d;
          if (d == 0) break;
        }
      }
    }
    return dist;
  }
}
