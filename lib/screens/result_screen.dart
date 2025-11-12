import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final bool successOptimal;
  final int playerCost;
  final int optimalCost;
  const ResultScreen({
    super.key,
    required this.successOptimal,
    required this.playerCost,
    required this.optimalCost,
  });

  @override
  Widget build(BuildContext context) {
    final color = successOptimal ? Colors.green : Colors.redAccent;
    return Scaffold(
      backgroundColor: color,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              successOptimal ? 'Perfect Path!' : 'Not Optimal',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your cost: $playerCost',
              style: const TextStyle(color: Colors.white),
            ),
            Text(
              'Optimal: $optimalCost',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
