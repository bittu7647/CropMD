import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import 'widgets/primary_button.dart';
import 'widgets/glass_container.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  String _farmSize = 'Medium (1-5 Acres)';
  String _language = 'English';
  final List<String> _selectedCrops = [];
  bool _isLoading = false;

  final List<String> _availableCrops = ['Potato', 'Tomato', 'Rice', 'Wheat', 'Maize', 'Cotton'];
  final List<String> _farmSizes = ['Small (<1 Acre)', 'Medium (1-5 Acres)', 'Large (>5 Acres)'];
  final List<String> _languages = ['English', 'Hindi', 'Marathi', 'Tamil', 'Telugu'];

  Future<void> _submitProfile() async {
    if (_selectedCrops.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one crop.'), backgroundColor: AppTheme.warningOrange),
      );
      return;
    }

    setState(() => _isLoading = true);
    final user = ref.read(authStateProvider).value;
    if (user != null) {
      final profile = UserProfile(
        uid: user.uid,
        email: user.email ?? '',
        farmSize: _farmSize,
        crops: _selectedCrops,
        language: _language,
        isProfileComplete: true,
      );
      await ref.read(authControllerProvider.notifier).saveProfile(profile);
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.bgGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person_pin_circle_rounded, size: 64, color: AppTheme.primaryGreen),
                  const SizedBox(height: 16),
                  const Text(
                    'Setup Your Farm Profile',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell us about your farm so we can provide tailored recommendations.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTheme.textMuted),
                  ),
                  const SizedBox(height: 32),
                  GlassContainer(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Farm Size', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _farmSize,
                          dropdownColor: AppTheme.bgSurface,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          items: _farmSizes.map((size) => DropdownMenuItem(value: size, child: Text(size))).toList(),
                          onChanged: (val) => setState(() => _farmSize = val!),
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.landscape, color: AppTheme.textMuted)),
                        ),
                        const SizedBox(height: 24),
                        const Text('Primary Crops', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _availableCrops.map((crop) {
                            final isSelected = _selectedCrops.contains(crop);
                            return FilterChip(
                              label: Text(crop),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) _selectedCrops.add(crop);
                                  else _selectedCrops.remove(crop);
                                });
                              },
                              selectedColor: AppTheme.primaryGreen.withOpacity(0.2),
                              checkmarkColor: AppTheme.primaryGreen,
                              labelStyle: TextStyle(color: isSelected ? AppTheme.primaryGreen : AppTheme.textMuted),
                              backgroundColor: AppTheme.bgSurface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: isSelected ? AppTheme.primaryGreen : AppTheme.glassBorder),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        const Text('Preferred Language', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          value: _language,
                          dropdownColor: AppTheme.bgSurface,
                          style: const TextStyle(color: AppTheme.textPrimary),
                          items: _languages.map((lang) => DropdownMenuItem(value: lang, child: Text(lang))).toList(),
                          onChanged: (val) => setState(() => _language = val!),
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.language, color: AppTheme.textMuted)),
                        ),
                        const SizedBox(height: 32),
                        PrimaryButton(
                          text: 'Complete Setup',
                          isLoading: _isLoading,
                          onPressed: _submitProfile,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
