import 'dart:math';
import 'package:energy_grid/logic/grid_randomizer.dart';
import 'package:energy_grid/style/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';

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
  String? selectedLevel;
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

  void resetToDefault() {
    setState(() {
      rows = 4;
      cols = 4;
      grid = GridModel(rows: rows, cols: cols);
    });
  }

  void getNextAvalible() {
    final Cell cell = grid.cells
        .firstWhere((rows) => rows.any((cell) => cell.type == CellType.start))
        .first;

    if (grid.cells[cell.col][cell.row + 1].type == CellType.empty) {
      print("cell column ${cell.col}, cell row ${cell.row + 1}");
    }
    if (grid.cells[cell.col + 1][cell.row].type == CellType.empty) {
      print("cell column ${cell.col + 1}, cell row ${cell.row}");
    }
    if (grid.cells[cell.col - 1][cell.row].type == CellType.empty) {
      print("cell column ${cell.col - 1}, cell row ${cell.row}");
    }
    if (grid.cells[cell.col][cell.row - 1].type == CellType.empty) {
      print("cell column ${cell.col}, cell row ${cell.row - 1}");
    }
  }

  void gridRandom(int level) {
    setState(() {
      GridRandomizer.randomizeWithLevel(grid, level);
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

  void updateRows(double value) {
    setState(() {
      rows = value.toInt();
      grid = GridModel(rows: rows, cols: cols);
    });
  }

  void updateCols(double value) {
    setState(() {
      cols = value.toInt();
      grid = GridModel(rows: rows, cols: cols);
    });
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = min(MediaQuery.of(context).size.width - 40, 700.0);
    final cellSize = gridWidth / cols;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Energy Grid'.toUpperCase(),
          style: TextStyle(fontWeight: FontWeight.w100),
        ),
        centerTitle: true,
        backgroundColor: GridColors.background,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          bottom: 24.0 + MediaQuery.of(context).padding.bottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobileLayout = constraints.maxWidth < 600;

            return isMobileLayout
                ? Column(
                    children: [
                      _buildGrid(gridWidth, cellSize),
                      const SizedBox(height: 20),
                      _buildSettings(),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildGrid(gridWidth, cellSize)),
                      const SizedBox(width: 20),
                      Expanded(child: _buildSettings()),
                    ],
                  );
          },
        ),
      ),
    );
  }

  Widget _buildSettings() {
    ///  levels = ["Easy", "Medium", "Hard", "Extreme"];

    return Column(
      children: [
        Row(
          spacing: 16,
          children: [
            Expanded(
              child: SpinBox(
                min: 4,
                max: 10,
                value: rows.toDouble(),
                decimals: 0,
                step: 1,
                onChanged: updateRows,
                decoration: const InputDecoration(labelText: "Rows"),
              ),
            ),
            Expanded(
              child: SpinBox(
                min: 4,
                max: 10,
                value: cols.toDouble(),
                decimals: 0,
                step: 1,
                onChanged: updateCols,
                decoration: const InputDecoration(labelText: "Cols"),
              ),
            ),

            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(GridColors.wall),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),

                minimumSize: WidgetStateProperty.all<Size>(const Size(24, 56)),
              ),
              onPressed: resetToDefault,
              child: const Icon(Icons.restart_alt_outlined, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 16.0),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  color: GridColors.container,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: DropdownButton<String>(
                  value: selectedLevel,
                  hint: const Text("Select Difficulty Level"),
                  isExpanded: true,
                  underline: const SizedBox(),
                  items: ["Easy", "Medium", "Hard", "Extreme"].map((level) {
                    return DropdownMenuItem(value: level, child: Text(level));
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() {
                      selectedLevel = value;
                      final levelIndex =
                          ["Easy", "Medium", "Hard", "Extreme"].indexOf(value) +
                          1;
                      gridRandom(levelIndex);
                    });
                  },
                ),
              ),
            ),

            const SizedBox(width: 16),

            FilledButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(GridColors.empty),
                foregroundColor: WidgetStateProperty.all(Colors.white),

                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                minimumSize: WidgetStateProperty.all<Size>(const Size(24, 56)),
              ),
              onPressed: () {
                if (selectedLevel == null) return;

                final levelIndex =
                    [
                      "Easy",
                      "Medium",
                      "Hard",
                      "Extreme",
                    ].indexOf(selectedLevel!) +
                    1;

                gridRandom(levelIndex);
              },
              child: const Icon(Icons.shuffle, size: 22),
            ),
          ],
        ),

        const SizedBox(height: 16.0),

        // ----------------------------------------------------
        FilledButton(
          onPressed: startGame,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(GridColors.start),
            foregroundColor: WidgetStateProperty.all(GridColors.background),

            minimumSize: WidgetStateProperty.all<Size>(
              const Size.fromHeight(56),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          child: Text(
            'Start Game'.toUpperCase(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        FilledButton(
          onPressed: getNextAvalible,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(GridColors.start),
            foregroundColor: WidgetStateProperty.all(GridColors.background),

            minimumSize: WidgetStateProperty.all<Size>(
              const Size.fromHeight(56),
            ),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
            ),
          ),
          child: Text(
            'get next cell'.toUpperCase(),
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
          ),
        ),
        // Wrap(
        //   spacing: 16,
        //   runSpacing: 8,
        //   children: [
        //     FilledButton(onPressed: startGame, child: const Text('Start')),

        //     ElevatedButton(
        //       onPressed: () => setState(() => mode = EditMode.setStart),
        //       child: const Text('Set Start'),
        //     ),
        //     ElevatedButton(
        //       onPressed: () => setState(() => mode = EditMode.setGoal),
        //       child: const Text('Set Goal'),
        //     ),
        //     ElevatedButton(
        //       onPressed: () => setState(() => mode = EditMode.setWall),
        //       child: const Text('Set Wall'),
        //     ),
        //     ElevatedButton(
        //       onPressed: () => setState(() => mode = EditMode.setWeighted),
        //       child: const Text('Set Weighted'),
        //     ),
        //   ],
        // ),
      ],
    );
  }

  Widget _buildGrid(double gridWidth, double cellSize) {
    return Expanded(
      child: Container(
        width: gridWidth,
        padding: EdgeInsets.all(
          cols * rows > 100
              ? 2
              : cols * rows > 35
              ? 4
              : 6,
        ),
        decoration: BoxDecoration(
          color: GridColors.container,
          borderRadius: BorderRadius.circular(
            cols * rows > 100
                ? 4
                : cols * rows > 35
                ? 8
                : 16,
          ),
        ),
        child: Column(
          children: List.generate(rows, (r) {
            return Expanded(
              child: Row(
                children: List.generate(cols, (c) {
                  final cell = grid.cells[r][c];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          if (cell.type == CellType.start) {
                            // إذا نقرت على الـ Start نفسها → إلغاؤها
                            cell.type = CellType.empty;
                          } else if (!grid.cells.any(
                            (c) => c.any((c) => c.type == CellType.start),
                          )) {
                            // تعيين Start إذا لم يكن موجود
                            cell.type = CellType.start;
                          } else if (!grid.cells.any(
                                (c) => c.any((c) => c.type == CellType.goal),
                              ) ||
                              cell.type == CellType.goal) {
                            // تعيين Goal إذا لم يكن موجود أو تغيير الخلية الحالية Goal
                            final prevGoal = grid.find(CellType.goal);
                            if (prevGoal != null && prevGoal != cell)
                              prevGoal.type = CellType.empty;
                            cell.type = CellType.goal;
                          }
                        });
                      },
                      onDoubleTap: () {
                        setState(() {
                          if (cell.type == CellType.empty) {
                            cell.type = CellType.weighted;
                          }
                        });
                      },
                      onLongPress: () {
                        setState(() {
                          if (cell.type == CellType.empty) {
                            cell.type = CellType.wall;
                          }
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.all(
                          cols * rows > 100
                              ? 2
                              : cols * rows > 35
                              ? 3
                              : 4,
                        ),
                        decoration: BoxDecoration(
                          color: _color(cell.type),
                          borderRadius: BorderRadius.circular(
                            cols * rows > 100
                                ? 2
                                : cols * rows > 35
                                ? 4
                                : 6,
                          ),
                        ),
                        child: Center(
                          child: Icon(
                            cell.type == CellType.weighted
                                ? Icons.bolt
                                : cell.type == CellType.start
                                ? Icons.play_arrow
                                : cell.type == CellType.goal
                                ? Icons.flag
                                : cell.type == CellType.wall
                                ? Icons.landscape
                                : null,
                            color: cell.type == CellType.weighted
                                ? Colors.amber
                                : cell.type == CellType.start
                                ? Colors.tealAccent
                                : cell.type == CellType.goal
                                ? Colors.orangeAccent
                                : Colors.indigo,
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }),
        ),
      ),
    );
  }

  Color _color(CellType t) {
    switch (t) {
      case CellType.start:
        return GridColors.start;
      case CellType.goal:
        return GridColors.goal;
      case CellType.weighted:
        return GridColors.weighted;
      case CellType.wall:
        return GridColors.wall;
      default:
        return GridColors.background;
    }
  }
}
