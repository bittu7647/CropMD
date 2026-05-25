import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/scan_result.dart';
import '../services/database_service.dart';
import 'auth_provider.dart';

// Provide the DatabaseService instance
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// Provide a stream of scan results matching the logged-in user ID
final scanHistoryProvider = StreamProvider<List<ScanResult>>((ref) {
  final databaseService = ref.watch(databaseServiceProvider);
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user != null) {
        return databaseService.getScanHistoryStream(user.uid);
      }
      return Stream.value(<ScanResult>[]);
    },
    error: (_, __) => Stream.value(<ScanResult>[]),
    loading: () => Stream.value(<ScanResult>[]),
  );
});
