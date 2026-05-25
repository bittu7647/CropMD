import 'package:flutter/material.dart';
import '../core/theme.dart';
import 'widgets/glass_container.dart';

class RecommendationScreen extends StatelessWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Smart Recommendations'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Irrigation Schedule
            const Row(
              children: [
                Icon(Icons.water_drop, color: Colors.lightBlueAccent, size: 28),
                SizedBox(width: 12),
                Text(
                  'Irrigation Schedule',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Water pumps: Turn on at 6:00 PM today.',
                    style: TextStyle(fontSize: 16, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Based on live IoT sensors, your soil moisture is currently at 45%. This is optimal for now, but will require watering by evening to prevent stress on your crops.',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Fertilizer Plan
            const Row(
              children: [
                Icon(Icons.grass, color: AppTheme.primaryGreen, size: 28),
                SizedBox(width: 12),
                Text(
                  'Fertilizer Plan',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 16),
            GlassContainer(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recommended NPK Ratio: 10-20-10',
                    style: TextStyle(fontSize: 16, color: AppTheme.textPrimary, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'For your primary crops in their current growth stage, apply a phosphorus-rich blend. Recommended dosage: 50kg per acre. Next application is due in 14 days.',
                    style: TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: AppTheme.primaryGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Avoid applying immediately after heavy rainfall to prevent runoff.',
                            style: TextStyle(fontSize: 13, color: AppTheme.primaryGreen.withOpacity(0.9)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
