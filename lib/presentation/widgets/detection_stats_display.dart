// Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

import 'package:flutter/material.dart';

/// A widget that displays detection statistics (count and FPS)
class DetectionStatsDisplay extends StatelessWidget {
  const DetectionStatsDisplay({
    super.key,
    required this.detectionCount,
    required this.currentFps,
  });

  final int detectionCount;
  final double currentFps;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        // 1. Add padding so the text doesn't touch the edges of the background
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        // 2. Add the background decoration
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6), // Semi-transparent black
          borderRadius: BorderRadius.circular(20), // Pill shape
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Shrinks container to fit content
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Objects: $detectionCount',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18, // Increased size
              ),
            ),
            // const SizedBox(width: 20),
            // Text(
            //   'FPS: ${currentFps.toStringAsFixed(1)}',
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 18, // Increased size
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}
