import 'package:flutter/material.dart';
import 'control_button.dart';
import '../../models/models.dart';


/// A widget containing camera control buttons
class CameraControls extends StatelessWidget {
  const CameraControls({
    super.key,
    required this.currentZoomLevel,
    required this.isFrontCamera,
    required this.activeSlider,
    required this.onZoomChanged,
    required this.onSliderToggled,
    required this.isLandscape,
  });

  final double currentZoomLevel;
  final bool isFrontCamera;
  final SliderType activeSlider;
  final ValueChanged<double> onZoomChanged;
  final ValueChanged<SliderType> onSliderToggled;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: isLandscape ? 16 : 32,
          right: isLandscape ? 8 : 16,
          child: Column(
            children: [
              if (!isFrontCamera)
                ControlButton(
                  content: '${currentZoomLevel.toStringAsFixed(1)}x',
                  onPressed: () => onZoomChanged(
                    currentZoomLevel < 0.75
                        ? 1.0
                        : currentZoomLevel < 2.0
                        ? 3.0
                        : 0.5,
                  ),
                ),
              SizedBox(height: isLandscape ? 8 : 12),
              ControlButton(
                content: Icons.layers,
                onPressed: () => onSliderToggled(SliderType.numItems),
              ),
              SizedBox(height: isLandscape ? 8 : 12),
              ControlButton(
                content: Icons.adjust,
                onPressed: () => onSliderToggled(SliderType.confidence),
              ),
              SizedBox(height: isLandscape ? 8 : 12),
              ControlButton(
                content: 'assets/iou.png',
                onPressed: () => onSliderToggled(SliderType.iou),
              ),
              SizedBox(height: isLandscape ? 16 : 40),
            ],
          ),
        ),

      ],
    );
  }
}