import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo_streaming_config.dart';
import '../controllers/camera_inference_controller.dart';
import 'custom_yolo_view.dart';

/// Main content widget that handles the camera view and loading states
class CameraInferenceContent extends StatelessWidget {
  const CameraInferenceContent({super.key, required this.controller});

  final CameraInferenceController controller;

  @override
  Widget build(BuildContext context) {
    if (controller.modelPath != null) {
      return CustomYOLOView(
        key: const ValueKey('yolo_view_static'),
        controller: controller.yoloController,
        modelPath: controller.modelPath!,
        task: controller.selectedModel.task,
        streamingConfig: const YOLOStreamingConfig(
          maxFPS: 30,
          inferenceFrequency: null,
          includeDetections: true,
          includeOBB: false,
          includeClassifications: false,
          includeMasks: false, // Disable masks for performance
          includeOriginalImage: false, // Save bandwidth
        ),
        // onPerformanceMetrics: (metrics) =>
        //     controller.onPerformanceMetrics(metrics.fps),
        onZoomChanged: controller.onZoomChanged,
        onResult: controller.onDetectionResults,
        // onStreamingData: controller.onStreamingData,
        showOverlays: true,
      );
    } else {
      return const Center(
        child: Text('No model loaded', style: TextStyle(color: Colors.white)),
      );
    }
  }
}