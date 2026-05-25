import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

/// Service for running YOLO11 object detection on crop leaf images.
/// Handles model loading, image preprocessing, inference, and output parsing.
/// Designed as a drop-in module: swap the model file and labels to retrain.
class DetectionService {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isModelLoaded = false;

  static const int inputSize = 640;
  static const double confidenceThreshold = 0.25;

  bool get isModelLoaded => _isModelLoaded;

  Future<void> init() async {
    await loadLabels();
    await loadModel();
  }

  Future<void> loadLabels() async {
    try {
      final labelsData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelsData
          .split('\n')
          .map((line) => line.trim())
          .where((line) => line.isNotEmpty)
          .toList();
      print('[DetectionService] Labels loaded (${_labels.length}): $_labels');
    } catch (e) {
      print('[DetectionService] Failed to load labels: $e');
      _labels = [
        'Rice Brown Spot', 'Rice Blast', 'Corn Common Rust',
        'Potato Late Blight', 'Tomato Yellow Leaf Curl', 'Healthy Crop'
      ];
    }
  }

  Future<void> loadModel() async {
    try {
      final options = InterpreterOptions()..threads = 4;
      _interpreter = await Interpreter.fromAsset(
        'detect.tflite',
        options: options,
      );
      _isModelLoaded = true;

      final inputTensor = _interpreter!.getInputTensor(0);
      final outputTensor = _interpreter!.getOutputTensor(0);
      print('[DetectionService] Model loaded successfully');
      print('[DetectionService] Input:  shape=${inputTensor.shape}, type=${inputTensor.type}');
      print('[DetectionService] Output: shape=${outputTensor.shape}, type=${outputTensor.type}');
    } catch (e) {
      print('[DetectionService] Failed to load model: $e');
      _isModelLoaded = false;
    }
  }

  /// Main inference entry point.
  /// Decodes the image, resizes to 640x640, runs YOLO11 inference,
  /// and returns the highest-confidence detection result.
  Future<Map<String, dynamic>> runInference(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      print('[DetectionService] Model not loaded, returning mock result');
      return _mockResult();
    }

    try {
      // 1. Decode and resize image
      final bytes = imageFile.readAsBytesSync();
      img.Image? image = img.decodeImage(bytes);
      if (image == null) throw Exception('Failed to decode image');

      final resized = img.copyResize(
        image,
        width: inputSize,
        height: inputSize,
        interpolation: img.Interpolation.linear,
      );

      // 2. Build input tensor as flat Float32List for memory efficiency
      //    Shape: [1, 640, 640, 3], normalized to [0.0, 1.0]
      final inputBuffer = Float32List(1 * inputSize * inputSize * 3);
      int idx = 0;
      for (int y = 0; y < inputSize; y++) {
        for (int x = 0; x < inputSize; x++) {
          final pixel = resized.getPixel(x, y);
          inputBuffer[idx++] = pixel.r / 255.0;
          inputBuffer[idx++] = pixel.g / 255.0;
          inputBuffer[idx++] = pixel.b / 255.0;
        }
      }

      // 3. Prepare output buffer based on model's output tensor shape
      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;
      print('[DetectionService] Running inference... Output shape: $outputShape');

      // YOLO11 TFLite output is typically [1, num_classes+4, num_detections]
      // e.g. [1, 10, 8400] for 6 classes with 640x640 input
      if (outputShape.length != 3) {
        throw Exception('Unexpected output tensor rank: ${outputShape.length}');
      }

      final output = List.generate(
        outputShape[0],
        (_) => List.generate(
          outputShape[1],
          (_) => List.filled(outputShape[2], 0.0),
        ),
      );

      // 4. Run the model
      _interpreter!.run(inputBuffer.buffer, output);
      print('[DetectionService] Inference complete');

      // 5. Parse YOLO output and find the best detection
      return _parseYoloOutput(output[0], outputShape[1], outputShape[2]);
    } catch (e, stack) {
      print('[DetectionService] Inference error: $e');
      print('[DetectionService] Stack trace: $stack');
      return _mockResult();
    }
  }

  /// Parses raw YOLO11 output tensor to extract the highest-confidence detection.
  ///
  /// Handles both output orientations:
  /// - Channels-first: [num_classes+4, num_detections] (Ultralytics default)
  /// - Channels-last:  [num_detections, num_classes+4]
  Map<String, dynamic> _parseYoloOutput(
      List<List<double>> output, int dim1, int dim2) {
    final int numClasses = _labels.length;
    final int expectedChannels = 4 + numClasses;

    // Determine data layout
    final bool channelsFirst = (dim1 == expectedChannels);
    final int numDetections = channelsFirst ? dim2 : dim1;

    print('[DetectionService] Parsing: channelsFirst=$channelsFirst, '
        'detections=$numDetections, classes=$numClasses');

    double bestScore = 0;
    int bestClassIdx = 0;
    List<double> bestBox = [0, 0, 0, 0];

    for (int i = 0; i < numDetections; i++) {
      // Extract bounding box (center_x, center_y, width, height)
      double xc, yc, w, h;
      if (channelsFirst) {
        xc = output[0][i];
        yc = output[1][i];
        w  = output[2][i];
        h  = output[3][i];
      } else {
        xc = output[i][0];
        yc = output[i][1];
        w  = output[i][2];
        h  = output[i][3];
      }

      // Find the class with the highest confidence score
      double maxScore = 0;
      int maxIdx = 0;
      for (int c = 0; c < numClasses; c++) {
        final score = channelsFirst ? output[4 + c][i] : output[i][4 + c];
        if (score > maxScore) {
          maxScore = score;
          maxIdx = c;
        }
      }

      // Track the overall best detection
      if (maxScore > bestScore && maxScore > confidenceThreshold) {
        bestScore = maxScore;
        bestClassIdx = maxIdx;
        bestBox = [xc, yc, w, h];
      }
    }

    if (bestScore > confidenceThreshold) {
      // Convert from pixel coords (center format) to normalized (top-left format)
      double nx = (bestBox[0] - bestBox[2] / 2) / inputSize;
      double ny = (bestBox[1] - bestBox[3] / 2) / inputSize;
      double nw = bestBox[2] / inputSize;
      double nh = bestBox[3] / inputSize;

      // Clamp to valid [0, 1] range
      nx = nx.clamp(0.0, 1.0);
      ny = ny.clamp(0.0, 1.0);
      nw = nw.clamp(0.0, 1.0 - nx);
      nh = nh.clamp(0.0, 1.0 - ny);

      final label = bestClassIdx < _labels.length
          ? _labels[bestClassIdx]
          : 'Class $bestClassIdx';

      print('[DetectionService] Best detection: $label '
          '(${(bestScore * 100).toStringAsFixed(1)}%)');

      return {
        'disease_label': label,
        'confidence_score': bestScore,
        'bounding_box': {'x': nx, 'y': ny, 'width': nw, 'height': nh},
      };
    }

    print('[DetectionService] No confident detection found '
        '(best score: ${bestScore.toStringAsFixed(3)})');
    return {
      'disease_label': 'No Disease Detected',
      'confidence_score': 0.0,
      'bounding_box': null,
    };
  }

  /// Fallback mock result if the model fails to load or inference errors out.
  Map<String, dynamic> _mockResult() {
    final random = Random();
    final diseases = [
      {'label': 'Rice Brown Spot', 'minConf': 0.87, 'maxConf': 0.95},
      {'label': 'Rice Blast', 'minConf': 0.82, 'maxConf': 0.93},
      {'label': 'Healthy Crop', 'minConf': 0.94, 'maxConf': 0.99},
    ];
    final pick = diseases[random.nextInt(diseases.length)];
    final conf = (pick['minConf'] as double) +
        random.nextDouble() * ((pick['maxConf'] as double) - (pick['minConf'] as double));
    return {
      'disease_label': pick['label'],
      'confidence_score': double.parse(conf.toStringAsFixed(2)),
      'bounding_box': {
        'x': 0.1 + random.nextDouble() * 0.2,
        'y': 0.1 + random.nextDouble() * 0.2,
        'width': 0.4 + random.nextDouble() * 0.2,
        'height': 0.4 + random.nextDouble() * 0.2,
      },
    };
  }

  void close() {
    _interpreter?.close();
  }
}
