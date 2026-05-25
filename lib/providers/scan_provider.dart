import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/scan_result.dart';
import '../services/database_service.dart';
import '../services/tflite_service.dart';
import 'dashboard_provider.dart';

// Provide DetectionService
final tfliteServiceProvider = Provider<DetectionService>((ref) {
  final service = DetectionService();
  service.init(); // Initialize asynchronously in background
  return service;
});

// Provide Scanning StateNotifier
final scanProvider = StateNotifierProvider<ScanNotifier, ScanState>((ref) {
  final tfliteService = ref.watch(tfliteServiceProvider);
  final databaseService = ref.watch(databaseServiceProvider);
  return ScanNotifier(tfliteService, databaseService);
});

// State definition for the scanning workflow
class ScanState {
  final bool isScanning;
  final File? selectedImage;
  final ScanResult? latestResult;
  final String? errorMessage;
  final bool permissionDenied;

  ScanState({
    this.isScanning = false,
    this.selectedImage,
    this.latestResult,
    this.errorMessage,
    this.permissionDenied = false,
  });

  ScanState copyWith({
    bool? isScanning,
    File? selectedImage,
    ScanResult? latestResult,
    String? errorMessage,
    bool? permissionDenied,
  }) {
    return ScanState(
      isScanning: isScanning ?? this.isScanning,
      selectedImage: selectedImage ?? this.selectedImage,
      latestResult: latestResult ?? this.latestResult,
      errorMessage: errorMessage,
      permissionDenied: permissionDenied ?? this.permissionDenied,
    );
  }
}

class ScanNotifier extends StateNotifier<ScanState> {
  final DetectionService _detectionService;
  final DatabaseService _databaseService; // DatabaseService from dashboard_provider

  final ImagePicker _picker = ImagePicker();

  ScanNotifier(this._detectionService, this._databaseService) : super(ScanState());

  // Reset scan screen state
  void reset() {
    state = ScanState();
  }

  // Gracefully handle permissions, then pick an image
  Future<bool> selectImage(ImageSource source) async {
    state = state.copyWith(errorMessage: null, permissionDenied: false);

    // Only request camera permission explicitly; for gallery,
    // image_picker uses the system photo picker on modern Android
    // which handles its own permissions internally.
    if (source == ImageSource.camera) {
      final cameraStatus = await Permission.camera.request();
      if (!cameraStatus.isGranted) {
        state = state.copyWith(
          errorMessage: 'Camera permission is required to scan crops.',
          permissionDenied: true,
        );
        return false;
      }
    }

    // Pick the image
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        state = state.copyWith(selectedImage: File(pickedFile.path));
        return true;
      }
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to select image: ${e.toString()}');
    }
    return false;
  }

  // Run the detection model and push the results to Firestore
  Future<void> runDetection(String userId) async {
    if (state.selectedImage == null) {
      state = state.copyWith(errorMessage: 'Please select an image first.');
      return;
    }

    state = state.copyWith(isScanning: true, errorMessage: null);

    try {
      // Run local inference
      final detection = await _detectionService.runInference(state.selectedImage!);

      // Construct ScanResult model
      final scanResult = ScanResult(
        id: '', // Will be assigned by Firestore automatically
        userId: userId,
        diseaseLabel: detection['disease_label'],
        confidenceScore: detection['confidence_score'],
        timestamp: DateTime.now(),
        boundingBox: detection['bounding_box'],
      );

      // Save to Firebase Cloud Firestore
      await _databaseService.saveScanResult(scanResult);

      state = state.copyWith(
        isScanning: false,
        latestResult: scanResult,
      );
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'Detection failed: ${e.toString()}',
      );
    }
  }
}
