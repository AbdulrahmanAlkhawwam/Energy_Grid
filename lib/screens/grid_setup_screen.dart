import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:energy_grid/logic/grid_randomizer.dart';
// import 'package:energy_grid/logic/dijkstra.dart';
import 'package:energy_grid/models/grid.dart';
import 'package:energy_grid/models/cell.dart';
import 'package:energy_grid/style/colors.dart';
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
  String? selectedLevel;
  late GridModel grid;
  EditMode mode = EditMode.setStart;

  final List<String> levels = ["Easy", "Medium", "Hard", "Extreme"];

  @override
  void initState() {
    super.initState();
    grid = GridModel(rows: rows, cols: cols);
  }

  void rebuildGrid() =>
      setState(() => grid = GridModel(rows: rows, cols: cols));

  void resetGrid() => setState(() => grid.reset());

  void resetToDefault() {
    setState(() {
      rows = 4;
      cols = 4;
      grid = GridModel(rows: rows, cols: cols);
    });
  }

  void updateRows(double value) => setState(() {
    rows = value.toInt();
    grid = GridModel(rows: rows, cols: cols);
  });

  void updateCols(double value) => setState(() {
    cols = value.toInt();
    grid = GridModel(rows: rows, cols: cols);
  });

  void setCell(int r, int c) {
    setState(() {
      switch (mode) {
        case EditMode.setStart:
          final prev = grid.find(CellType.start);
          if (prev != null) prev.type = CellType.empty;
          grid.get(r, c).type = CellType.start;
          break;
        case EditMode.setGoal:
          final prev = grid.find(CellType.goal);
          if (prev != null) prev.type = CellType.empty;
          grid.get(r, c).type = CellType.goal;
          break;
        case EditMode.setWeighted:
          grid.get(r, c).type = CellType.weighted;
          break;
        case EditMode.setWall:
          grid.get(r, c).type = CellType.wall;
          break;
        case EditMode.setEmpty:
          grid.get(r, c).type = CellType.empty;
          break;
      }
    });
  }

  void gridRandom(int level) =>
      setState(() => GridRandomizer.randomizeWithLevel(grid, level));

  void startGame() {
    final minCost = 1 /*dijkstraMinCost(grid)*/;
    if (minCost <= 0 || minCost >= 100000) {
      _showSnack("We can't solve this grid");
      return;
    }
    if (grid.find(CellType.start) == null || grid.find(CellType.goal) == null) {
      _showSnack("Select start and goal cell");
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(gridModel: grid)),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildRowsBox() {
    return SpinBox(
      min: 4,
      max: 10,
      value: rows.toDouble(),
      step: 1,
      onChanged: updateRows,
      decoration: const InputDecoration(labelText: "Rows"),
    );
  }

  Widget _buildColsBox() {
    return SpinBox(
      min: 4,
      max: 10,
      value: cols.toDouble(),
      step: 1,
      onChanged: updateCols,
      decoration: const InputDecoration(labelText: "Cols"),
    );
  }

  Widget _buildLevelDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: selectedLevel,
      hint: const Text("Select Difficulty Level"),
      isExpanded: true,
      items: levels
          .map((level) => DropdownMenuItem(value: level, child: Text(level)))
          .toList(),
      onChanged: (value) {
        if (value == null) return;
        setState(() {
          selectedLevel = value;
          final levelIndex = levels.indexOf(value) + 1;
          gridRandom(levelIndex);
        });
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: GridColors.container,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Widget _buildStartButton() {
    return FilledButton(
      onPressed: startGame,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(GridColors.start),
        foregroundColor: WidgetStateProperty.all(GridColors.background),
        minimumSize: WidgetStateProperty.all(const Size.fromHeight(56)),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      child: const Text(
        'Start Game',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
    );
  }

  Widget _buildSettings() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildRowsBox()),
            const SizedBox(width: 12),
            Expanded(child: _buildColsBox()),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: resetToDefault,
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(GridColors.wall),
                foregroundColor: MaterialStateProperty.all(Colors.white),
                minimumSize: MaterialStateProperty.all(const Size(24, 56)),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              child: const Icon(Icons.restart_alt_outlined, size: 22),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildLevelDropdown()),
            if (selectedLevel != null) ...[
              const SizedBox(width: 12),
              FilledButton(
                onPressed: () {
                  if (selectedLevel == null) return;
                  final levelIndex = levels.indexOf(selectedLevel!) + 1;
                  gridRandom(levelIndex);
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(GridColors.empty),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                  minimumSize: MaterialStateProperty.all(const Size(56, 56)),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                child: const Icon(Icons.shuffle, size: 22),
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        _buildStartButton(),
      ],
    );
  }

  Widget _buildGrid(double width, double cellSize) {
    return Expanded(
      child: Container(
        width: width,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: GridColors.container,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: List.generate(rows, (r) {
            return Expanded(
              child: Row(
                children: List.generate(cols, (c) {
                  final cell = grid.get(r, c);
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setCell(r, c),
                      onDoubleTap: () {
                        if (cell.type == CellType.empty) {
                          setCell(r, c);
                          cell.type = CellType.weighted;
                        }
                      },
                      onLongPress: () {
                        if (cell.type == CellType.empty) {
                          setCell(r, c);
                          cell.type = CellType.wall;
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _cellColor(cell.type),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Icon(
                            _cellIcon(cell.type),
                            color: _cellIconColor(cell.type),
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

  Color _cellColor(CellType t) {
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

  IconData? _cellIcon(CellType t) {
    switch (t) {
      case CellType.start:
        return Icons.play_arrow;
      case CellType.goal:
        return Icons.flag;
      case CellType.weighted:
        return Icons.bolt;
      case CellType.wall:
        return Icons.landscape;
      default:
        return null;
    }
  }

  Color _cellIconColor(CellType t) {
    switch (t) {
      case CellType.start:
        return Colors.tealAccent;
      case CellType.goal:
        return Colors.orangeAccent;
      case CellType.weighted:
        return Colors.amber;
      case CellType.wall:
        return Colors.indigo;
      default:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final gridWidth = min(MediaQuery.of(context).size.width - 40, 700.0);
    final cellSize = gridWidth / cols;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Energy Grid',
          style: TextStyle(fontWeight: FontWeight.w300),
        ),
        centerTitle: true,
        backgroundColor: GridColors.background,
      ),
      body: Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          bottom: 24 + MediaQuery.of(context).padding.bottom,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return isMobile
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
}
