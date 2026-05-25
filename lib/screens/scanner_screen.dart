import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/scan_provider.dart';
import 'widgets/loading_indicator.dart';
import 'widgets/primary_button.dart';

class ScannerScreen extends ConsumerWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context, WidgetRef ref, ImageSource source) async {
    final success = await ref.read(scanProvider.notifier).selectImage(source);
    if (!success) {
      final errorMsg = ref.read(scanProvider).errorMessage;
      if (errorMsg != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppTheme.alertRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanState = ref.watch(scanProvider);
    final userState = ref.watch(authStateProvider);
    final userId = userState.value?.uid ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Crop Scanner',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppTheme.textPrimary),
        actions: [
          if (scanState.selectedImage != null)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
              tooltip: 'Reset Scanner',
              onPressed: () {
                ref.read(scanProvider.notifier).reset();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main preview and viewport area
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppTheme.glassBorder,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: scanState.selectedImage == null
                      ? _buildEmptyState(context, ref)
                      : _buildImagePreview(context, scanState),
                ),
              ),
              
              // Bottom Action Controls Panel (Glassmorphism)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    decoration: BoxDecoration(
                      color: AppTheme.bgCard.withOpacity(0.7),
                      border: const Border(
                        top: BorderSide(color: AppTheme.glassBorder),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (scanState.selectedImage == null) ...[
                          const Text(
                            'Provide a clear Leaf Specimen',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Position the leaf in the center of the frame and ensure sufficient lighting.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    side: const BorderSide(color: AppTheme.primaryGreen),
                                  ),
                                  onPressed: () => _pickImage(context, ref, ImageSource.gallery),
                                  icon: const Icon(Icons.photo_library, color: AppTheme.primaryGreen),
                                  label: const Text(
                                    'Gallery',
                                    style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: AppTheme.greenGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: AppTheme.greenGlow(opacity: 0.3, blur: 15),
                                  ),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: AppTheme.bgDark,
                                      shadowColor: Colors.transparent,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    onPressed: () => _pickImage(context, ref, ImageSource.camera),
                                    icon: const Icon(Icons.camera_alt),
                                    label: const Text(
                                      'Camera',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else if (scanState.latestResult == null) ...[
                          const Text(
                            'Specimen Loaded Successfully',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Tap the button below to process this leaf with the local AI neural network.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 20),
                          PrimaryButton(
                            text: 'Analyze Specimen',
                            icon: Icons.center_focus_strong,
                            onPressed: () {
                              ref.read(scanProvider.notifier).runDetection(userId);
                            },
                          ),
                        ] else ...[
                          // Detection Completed
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                  boxShadow: AppTheme.greenGlow(opacity: 0.2, blur: 10),
                                ),
                                child: const Icon(Icons.verified, color: AppTheme.primaryGreen, size: 28),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Diagnosis',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                    Text(
                                      scanState.latestResult!.diseaseLabel,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: AppTheme.greenGlow(opacity: 0.3, blur: 10),
                                ),
                                child: Text(
                                  '${(scanState.latestResult!.confidenceScore * 100).round()}% Conf.',
                                  style: const TextStyle(
                                    color: AppTheme.bgDark,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (!scanState.latestResult!.diseaseLabel.toLowerCase().contains('healthy')) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.warningOrange.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.warningOrange.withOpacity(0.3)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(Icons.search, color: AppTheme.warningOrange, size: 16),
                                      SizedBox(width: 6),
                                      Text('Root Cause AI', style: TextStyle(color: AppTheme.warningOrange, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'This was likely triggered by the high humidity (80%) recorded over the last 3 days combined with low soil nitrogen.',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: const [
                                      Icon(Icons.build, color: AppTheme.primaryGreen, size: 16),
                                      SizedBox(width: 6),
                                      Text('Actionable Fix', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Apply copper-based fungicide. Reduce watering for the next 2 days to lower humidity around the crop base.',
                                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                          PrimaryButton(
                            text: 'Return to Dashboard',
                            icon: Icons.arrow_back,
                            onPressed: () {
                              ref.read(scanProvider.notifier).reset();
                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          if (scanState.isScanning)
            const Positioned.fill(
              child: ScanningLoadingOverlay(),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withOpacity(0.05),
                    ),
                  ),
                  child: const Icon(
                    Icons.center_focus_weak_rounded,
                    size: 72,
                    color: Colors.white38,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'No Specimen Active',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please load an image from your gallery or take a live photo of a plant leaf to begin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ),
        // Leaf outline overlay to guide the user
        Center(
          child: Icon(
            Icons.eco_outlined,
            size: 200,
            color: AppTheme.primaryGreen.withOpacity(0.15),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context, ScanState scanState) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final box = scanState.latestResult?.boundingBox;
        
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              scanState.selectedImage!,
              fit: BoxFit.cover,
            ),
            
            // Leaf outline guide when not yet analyzed
            if (scanState.latestResult == null)
              Center(
                child: Icon(
                  Icons.eco_outlined,
                  size: 250,
                  color: AppTheme.primaryGreen.withOpacity(0.3),
                ),
              ),

            if (box != null) ...[
              Container(color: Colors.black54),
              Positioned(
                left: constraints.maxWidth * (box['x'] ?? 0.0),
                top: constraints.maxHeight * (box['y'] ?? 0.0),
                width: constraints.maxWidth * (box['width'] ?? 0.0),
                height: constraints.maxHeight * (box['height'] ?? 0.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryGreen,
                      width: 3.0,
                    ),
                    boxShadow: AppTheme.greenGlow(opacity: 0.5, blur: 15),
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        top: -30,
                        left: -3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryGreen,
                            borderRadius: BorderRadius.circular(4),
                            boxShadow: AppTheme.greenGlow(opacity: 0.4, blur: 8),
                          ),
                          child: Text(
                            '${scanState.latestResult!.diseaseLabel} (${(scanState.latestResult!.confidenceScore * 100).round()}%)',
                            style: const TextStyle(
                              color: AppTheme.bgDark,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
