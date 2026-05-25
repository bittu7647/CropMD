import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../models/scan_result.dart';
import '../providers/auth_provider.dart';
import '../providers/dashboard_provider.dart';
import 'scanner_screen.dart';
import 'recommendation_screen.dart';
import 'widgets/scan_card.dart';
import 'widgets/glass_container.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(scanHistoryProvider);
    final authController = ref.watch(authControllerProvider.notifier);
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                floating: true,
                title: Row(
                  children: [
                    const Icon(Icons.location_on, color: AppTheme.primaryGreen, size: 20),
                    const SizedBox(width: 8),
                    const Text('Farm Command Center', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18)),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.wb_sunny, color: AppTheme.warningOrange),
                    tooltip: 'Weather: Sunny, 32°C',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Hyper-local Weather: 32°C, 40% Humidity. No rain expected today.')),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout_rounded, color: AppTheme.textPrimary),
                    tooltip: 'Sign Out',
                    onPressed: () async {
                      await authController.logout();
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Welcome & Sustainability Score
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Welcome back,', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
                                profileAsync.when(
                                  data: (profile) => Text(
                                    profile?.email ?? 'Farmer',
                                    style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  loading: () => const Text('Loading...', style: TextStyle(color: AppTheme.textPrimary)),
                                  error: (_, __) => const Text('Farmer', style: TextStyle(color: AppTheme.textPrimary)),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppTheme.glassBorder),
                              boxShadow: AppTheme.greenGlow(opacity: 0.2, blur: 10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.shield, color: AppTheme.primaryGreen),
                                const SizedBox(width: 8),
                                Column(
                                  children: const [
                                    Text('Score', style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
                                    Text('85/100', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold, fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // IoT Sensor Data Dashboard
                      const Text('Live Sensor Data', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildGauge('Moisture', '45%', Icons.water_drop, Colors.lightBlueAccent, 0.45),
                          _buildGauge('Temp', '32°C', Icons.thermostat, AppTheme.warningOrange, 0.7),
                          _buildGauge('Humidity', '60%', Icons.cloud, Colors.white70, 0.60),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Soil Moisture: 45% - Needs Water Tomorrow',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.lightBlueAccent, fontSize: 13, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 24),

                      // Smart Recommendations Quick Link
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const RecommendationScreen()),
                          );
                        },
                        child: GlassContainer(
                          padding: const EdgeInsets.all(16),
                          borderColor: AppTheme.primaryGreen.withOpacity(0.5),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryGreen.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.tips_and_updates, color: AppTheme.primaryGreen),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text('Smart Recommendations', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 16)),
                                    Text('View AI irrigation & fertilizer plans', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, color: AppTheme.textMuted, size: 16),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text('Recent Diagnostics', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              
              // Diagnostic History List
              historyAsync.when(
                data: (scans) {
                  if (scans.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            children: [
                              Icon(Icons.agriculture_rounded, size: 64, color: AppTheme.primaryGreen.withOpacity(0.3)),
                              const SizedBox(height: 16),
                              const Text('No Scans Yet', style: TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              const Text('Tap the camera button to analyze a crop.', style: TextStyle(color: AppTheme.textMuted)),
                            ],
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
                          child: ScanResultCardWrapper(scanResult: scans[index]),
                        );
                      },
                      childCount: scans.length,
                    ),
                  );
                },
                loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen))),
                error: (err, _) => SliverToBoxAdapter(child: Center(child: Text('Error loading history: $err', style: const TextStyle(color: AppTheme.alertRed)))),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 72,
        width: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppTheme.greenGradient,
          boxShadow: AppTheme.greenGlow(opacity: 0.5, blur: 25),
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScannerScreen()),
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.camera_enhance, size: 32, color: AppTheme.bgDark),
        ),
      ),
    );
  }

  Widget _buildGauge(String label, String value, IconData icon, Color color, double percentage) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                value: percentage,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            Icon(icon, color: color, size: 32),
          ],
        ),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 12)),
      ],
    );
  }
}

class ScanResultCardWrapper extends StatelessWidget {
  final ScanResult scanResult;
  const ScanResultCardWrapper({Key? key, required this.scanResult}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScanCard(
      scanResult: scanResult,
      onTap: () {
        // Simple dialog for history detail
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppTheme.bgElevated,
            title: Text(scanResult.diseaseLabel, style: const TextStyle(color: AppTheme.textPrimary)),
            content: Text('Confidence: ${(scanResult.confidenceScore * 100).round()}%\nScanned on: ${scanResult.timestamp.toLocal().toString().split('.')[0]}', style: const TextStyle(color: AppTheme.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close', style: TextStyle(color: AppTheme.primaryGreen))),
            ],
          ),
        );
      },
    );
  }
}
