import 'dart:math';
import 'package:flutter/material.dart';
import '../models/grid.dart';
import '../models/cell.dart';
import '../logic/dijkstra.dart';
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
    player = grid.find(CellType.start)!;
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
    final cellSize = gridWidth / grid.cols;

    return Scaffold(
      appBar: AppBar(title: const Text('Energy Grid — Game')),
      body: GestureDetector(
        onPanEnd: (d) {
          final dx = d.velocity.pixelsPerSecond.dx;
          final dy = d.velocity.pixelsPerSecond.dy;
          if (dx.abs() > dy.abs()) {
            if (dx > 0)
              move(0, 1);
            else
              move(0, -1);
          } else {
            if (dy > 0)
              move(1, 0);
            else
              move(-1, 0);
          }
        },
        child: Column(
          children: [
            Text(
              'Total Cost: $totalCost',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              width: gridWidth,
              decoration: BoxDecoration(
                color: const Color(0xFF071E22),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: List.generate(grid.rows, (r) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(grid.cols, (c) {
                      final cell = grid.cells[r][c];
                      final isPlayer = (player.row == r && player.col == c);
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: cellSize - 8,
                        height: cellSize - 8,
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: _color(cell.type, isPlayer),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.black54),
                          boxShadow: isPlayer
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF00FFC6,
                                    ).withOpacity(0.3),
                                    blurRadius: 12,
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(child: _iconFor(cell, isPlayer)),
                      );
                    }),
                  );
                }),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Back'),
            ),
          ],
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
    switch (cell.type) {
      case CellType.start:
        return const Text(
          'S',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        );
      case CellType.goal:
        return const Text(
          'G',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        );
      case CellType.weighted:
        return const Icon(Icons.bolt, color: Colors.yellowAccent, size: 18);
      case CellType.wall:
        return const Icon(Icons.stop, color: Colors.white30, size: 18);
      case CellType.pathTaken:
        return const Icon(Icons.check, color: Colors.greenAccent, size: 16);
      default:
        return const SizedBox.shrink();
    }
  }

  Color _color(CellType type, bool isPlayer) {
    if (isPlayer) return const Color(0xFF00FFC6);
    switch (type) {
      case CellType.start:
        return const Color(0xFF00FFC6);
      case CellType.goal:
        return const Color(0xFFFF4D6D);
      case CellType.weighted:
        return const Color(0xFF6C5CE7);
      case CellType.wall:
        return const Color(0xFF0B1417);
      case CellType.pathTaken:
        return const Color(0xFF16A085);
      default:
        return const Color(0xFF0F2A34);
    }
  }
}
