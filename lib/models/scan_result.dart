import 'package:cloud_firestore/cloud_firestore.dart';

class ScanResult {
  final String id;
  final String userId;
  final String diseaseLabel;
  final double confidenceScore;
  final DateTime timestamp;
  final Map<String, dynamic>? boundingBox; // Optional bounding box coordinates

  ScanResult({
    required this.id,
    required this.userId,
    required this.diseaseLabel,
    required this.confidenceScore,
    required this.timestamp,
    this.boundingBox,
  });

  // Create ScanResult from Firestore DocumentSnapshot JSON payload
  factory ScanResult.fromMap(Map<String, dynamic> data, String documentId) {
    DateTime parsedDate;
    if (data['timestamp'] is Timestamp) {
      parsedDate = (data['timestamp'] as Timestamp).toDate();
    } else if (data['timestamp'] is String) {
      parsedDate = DateTime.parse(data['timestamp']);
    } else {
      parsedDate = DateTime.now();
    }

    return ScanResult(
      id: documentId,
      userId: data['user_id'] ?? '',
      diseaseLabel: data['disease_label'] ?? 'Unknown',
      confidenceScore: (data['confidence_score'] ?? 0.0).toDouble(),
      timestamp: parsedDate,
      boundingBox: data['bounding_box'] != null
          ? Map<String, dynamic>.from(data['bounding_box'])
          : null,
    );
  }

  // Convert ScanResult to JSON payload for Firestore saving
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'disease_label': diseaseLabel,
      'confidence_score': confidenceScore,
      'timestamp': Timestamp.fromDate(timestamp),
      'bounding_box': boundingBox,
    };
  }
}
