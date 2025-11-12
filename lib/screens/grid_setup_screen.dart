import 'dart:math';
import 'package:flutter/material.dart';
import '../logic/dijkstra.dart';
import '../models/grid.dart';
import '../models/cell.dart';
import 'game_screen.dart';

enum EditMode { setStart, setGoal, setWeighted, setWall, setEmpty }

class GridSetupScreen extends StatefulWidget {
  const GridSetupScreen({super.key});

  @override
  State<GridSetupScreen> createState() => _GridSetupScreenState();
}

class _GridSetupScreenState extends State<GridSetupScreen> {
  int rows = 4;
  int cols = 4;
  late GridModel grid;
  EditMode mode = EditMode.setStart;

  @override
  void initState() {
    super.initState();
    grid = GridModel(rows: rows, cols: cols);
  }

  void rebuild() => setState(() => grid = GridModel(rows: rows, cols: cols));

  void clearGrid() {
    setState(() {
      grid.reset();
    });
  }

  void startGame() {
    print(dijkstraMinCost(grid).toString());
    if (dijkstraMinCost(grid) <= 0 || dijkstraMinCost(grid) >= 100000) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("we can't solve this grid ")));
      return;
    }
    if (grid.find(CellType.start) == null || grid.find(CellType.goal) == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('select start and Goal cell')));
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(gridModel: grid)),
    );
  }

  void setCell(int r, int c) {
    setState(() {
      switch (mode) {
        case EditMode.setStart:
          final prev = grid.find(CellType.start);
          if (prev != null) prev.type = CellType.empty;
          grid.cells[r][c].type = CellType.start;
          break;
        case EditMode.setGoal:
          final prev = grid.find(CellType.goal);
          if (prev != null) prev.type = CellType.empty;
          grid.cells[r][c].type = CellType.goal;
          break;
        case EditMode.setWeighted:
          grid.cells[r][c].type = CellType.weighted;
          break;
        case EditMode.setWall:
          grid.cells[r][c].type = CellType.wall;
          break;
        case EditMode.setEmpty:
          grid.cells[r][c].type = CellType.empty;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = min(MediaQuery.of(context).size.width - 40, 700.0);
    final cellSize = gridWidth / cols;
    return Scaffold(
      appBar: AppBar(title: const Text('Energy Grid'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 10,
              children: [
                FilledButton(
                  onPressed: clearGrid,
                  child: const Icon(Icons.clear),
                ),
                ElevatedButton(
                  onPressed: startGame,
                  child: const Text('Start Manual Solve'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => mode = EditMode.setStart),
                  child: const Text('Set Start'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => mode = EditMode.setGoal),
                  child: const Text('Set Goal'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => mode = EditMode.setWall),
                  child: const Text('Set wall'),
                ),
                ElevatedButton(
                  onPressed: () => setState(() => mode = EditMode.setWeighted),
                  child: const Text('Set weighted'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              width: gridWidth,
              decoration: BoxDecoration(
                color: const Color(0xFF071E22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: List.generate(rows, (r) {
                  return Row(
                    children: List.generate(cols, (c) {
                      final cell = grid.cells[r][c];
                      return GestureDetector(
                        onTap: () => setCell(r, c),
                        child: Container(
                          width: cellSize - 4,
                          height: cellSize - 4,
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: _color(cell.type),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              cell.type == CellType.start
                                  ? 'S'
                                  : cell.type == CellType.goal
                                  ? 'G'
                                  : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _color(CellType t) {
    switch (t) {
      case CellType.start:
        return const Color(0xFF00FFC6);
      case CellType.goal:
        return const Color(0xFFFF4D6D);
      case CellType.weighted:
        return const Color(0xFF6C5CE7);
      case CellType.wall:
        return const Color(0xFF0B1417);
      default:
        return const Color(0xFF0F2A34);
    }
  }
}
