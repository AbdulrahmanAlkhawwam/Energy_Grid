import 'dart:math';
import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/cell.dart';
import '../logic/dijkstra.dart';
import '../style/colors.dart';
import 'result_screen.dart';

class GameScreen extends StatefulWidget {
  final GridModel gridModel;
  const GameScreen({super.key, required this.gridModel});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GridModel grid;
  late Cell player;
  int totalCost = 0;

  @override
  void initState() {
    super.initState();
    grid = widget.gridModel;

    // Safe fallback in case find(start) returns null.
    player = grid.find(CellType.start) ?? grid.cells[0][0];
  }

  void move(int dr, int dc) {
    final nr = player.row + dr, nc = player.col + dc;
    if (nr < 0 || nc < 0 || nr >= grid.rows || nc >= grid.cols) return;

    final target = grid.cells[nr][nc];
    if (target.type == CellType.wall) return;

    setState(() {
      if (player.type != CellType.start && player.type != CellType.goal) {
        player.type = CellType.pathTaken;
      }
      player = target;
      totalCost += target.cost();
    });

    if (target.type == CellType.goal) endGame();
  }

  void endGame() {
    final optimal = dijkstraMinCost(grid);
    final win = totalCost <= optimal;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultScreen(
          successOptimal: win,
          playerCost: totalCost,
          optimalCost: optimal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final gridWidth = min(size.width - 40, 700.0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Energy Grid'),
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),

        // ❌ BUG: Expanded inside GestureDetector
        // ✔ FIX: Remove Expanded, use Container directly
        child: GestureDetector(
          onPanEnd: (d) {
            final dx = d.velocity.pixelsPerSecond.dx;
            final dy = d.velocity.pixelsPerSecond.dy;
            if (dx.abs() > dy.abs()) {
              move(0, dx > 0 ? 1 : -1);
            } else {
              move(dy > 0 ? 1 : -1, 0);
            }
          },

          child: Container(
            width: gridWidth,
            padding: EdgeInsets.all(
              grid.cols * grid.rows > 100
                  ? 2
                  : grid.cols * grid.rows > 35
                  ? 4
                  : 6,
            ),
            decoration: BoxDecoration(
              color: GridColors.container,
              borderRadius: BorderRadius.circular(
                grid.cols * grid.rows > 100
                    ? 4
                    : grid.cols * grid.rows > 35
                    ? 8
                    : 16,
              ),
            ),

            child: Column(
              children: List.generate(grid.rows, (r) {
                return Expanded(
                  child: Row(
                    children: List.generate(grid.cols, (c) {
                      final cell = grid.cells[r][c];
                      final isPlayer = player.row == r && player.col == c;

                      return Expanded(
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: _color(cell.type, isPlayer),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(child: _iconFor(cell, isPlayer)),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _iconFor(Cell cell, bool isPlayer) {
    if (isPlayer) {
      return const Text(
        'S',
        style: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      );
    }

    return {
          CellType.start: const Text(
            'S',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          CellType.goal: const Text(
            'G',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          CellType.weighted: const Icon(
            Icons.bolt,
            color: Colors.yellowAccent,
            size: 18,
          ),
          CellType.wall: const Icon(
            Icons.stop,
            color: Colors.white30,
            size: 18,
          ),
          CellType.pathTaken: const Icon(
            Icons.check,
            color: Colors.greenAccent,
            size: 16,
          ),
          CellType.empty: const SizedBox.shrink(),
        }[cell.type] ??
        const SizedBox.shrink();
  }

  Color _color(CellType t, bool isPlayer) {
    if ((isPlayer && t != CellType.start && t != CellType.goal) ||
        t == CellType.pathTaken) {
      return GridColors.player;
    }

    return {
          CellType.start: GridColors.start,
          CellType.goal: GridColors.goal,
          CellType.weighted: GridColors.weighted,
          CellType.wall: GridColors.wall,
          CellType.pathTaken: GridColors.player,
          CellType.empty: GridColors.background,
        }[t] ??
        GridColors.background;
  }
}
