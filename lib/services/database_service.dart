import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scan_result.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Save scan result to Firestore under 'scans' collection
  Future<void> saveScanResult(ScanResult result) async {
    try {
      await _firestore.collection('scans').add(result.toMap());
    } catch (e) {
      throw Exception('Failed to save scan: ${e.toString()}');
    }
  }

  // Get real-time stream of scan history for a specific user
  // Sorted client-side to avoid requiring a Firestore composite index
  Stream<List<ScanResult>> getScanHistoryStream(String userId) {
    return _firestore
        .collection('scans')
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final results = snapshot.docs.map((doc) {
        return ScanResult.fromMap(doc.data(), doc.id);
      }).toList();
      // Sort client-side: newest first
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    });
  }
}
