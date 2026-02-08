import 'dart:convert';

/// Data model for a Crime Complaint.
class ComplaintModel {
  final String id;
  final String title;
  final String description;
  final String crimeType;
  final String? imagePath;
  final String? videoPath;
  final DateTime timestamp;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.description,
    required this.crimeType,
    this.imagePath,
    this.videoPath,
    required this.timestamp,
  });

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'crimeType': crimeType,
      'imagePath': imagePath,
      'videoPath': videoPath,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Convert to JSON string
  String toJson() => json.encode(toMap());

  /// Create from JSON map
  factory ComplaintModel.fromMap(Map<String, dynamic> map) {
    return ComplaintModel(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      crimeType: map['crimeType'],
      imagePath: map['imagePath'],
      videoPath: map['videoPath'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }

  /// Create from JSON string
  factory ComplaintModel.fromJson(String source) =>
      ComplaintModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'ComplaintModel(id: $id, title: $title, crimeType: $crimeType)';
  }
}
