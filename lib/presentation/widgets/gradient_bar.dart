import 'package:flutter/material.dart';

class RipenessScaleOverlay extends StatelessWidget {
  const RipenessScaleOverlay({
    super.key,
    required this.isLandscape,
  });

  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: isLandscape ? 16 : 32,
          left: isLandscape ? 8 : 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Rotated Gradient Scale (Vertical)
              // quarterTurns: 3 = -90 degrees (Left becomes Bottom)
              RotatedBox(
                quarterTurns: 3,
                child: const GradientScale(
                  width: 200, // This is the visual height
                  height: 20, // This is the visual thickness
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Ripeness",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                ),
              ),

              // Matches the bottom spacing used in CameraControls for alignment
              SizedBox(height: isLandscape ? 16 : 40),
            ],
          ),
        ),
      ],
    );
  }
}


class GradientScale extends StatelessWidget {
  final double width;
  final double height;

  const GradientScale({
    super.key,
    this.width = 200,
    this.height = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        // Optional: Add a border or rounded corners
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        gradient: const LinearGradient(
          // Define the direction (Left to Right)
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          // Define the colors: Green -> Yellow -> Red
          colors: [
            Colors.green,
            Colors.yellow,
            Colors.red,
          ],
          // Optional: Adjust stops to control where colors shift
          // stops: [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}