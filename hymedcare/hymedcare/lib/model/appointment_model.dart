import 'package:cloud_firestore/cloud_firestore.dart';

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorImageUrl;
  final String patientId;
  final String patientName;
  final String patientImageUrl;
  final DateTime dateTime;
  final String status; // 'upcoming', 'accepted', 'rejected', 'rescheduled', 'completed', 'cancelled'
  final String notes;
  final DateTime createdAt;
  final DateTime? lastModifiedAt;
  final List<String> patientFiles; // URLs to patient uploaded files
  final List<String> doctorFiles; // URLs to doctor uploaded files
  final String? reasonForChange;
  final DateTime? originalDateTime; // Track original appointment time if rescheduled

  AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorImageUrl,
    required this.patientId,
    required this.patientName,
    required this.patientImageUrl,
    required this.dateTime,
    required this.status,
    required this.notes,
    required this.createdAt,
    this.lastModifiedAt,
    this.patientFiles = const [],
    this.doctorFiles = const [],
    this.reasonForChange,
    this.originalDateTime,
  });

  factory AppointmentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppointmentModel(
      id: doc.id,
      doctorId: data['doctorId'] ?? '',
      doctorName: data['doctorName'] ?? '',
      doctorImageUrl: data['doctorImageUrl'] ?? '',
      patientId: data['patientId'] ?? '',
      patientName: data['patientName'] ?? '',
      patientImageUrl: data['patientImageUrl'] ?? '',
      dateTime: (data['dateTime'] as Timestamp).toDate(),
      status: data['status'] ?? 'upcoming',
      notes: data['notes'] ?? '',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      lastModifiedAt: data['lastModifiedAt'] != null 
          ? (data['lastModifiedAt'] as Timestamp).toDate() 
          : null,
      patientFiles: List<String>.from(data['patientFiles'] ?? []),
      doctorFiles: List<String>.from(data['doctorFiles'] ?? []),
      reasonForChange: data['reasonForChange'],
      originalDateTime: data['originalDateTime'] != null 
          ? (data['originalDateTime'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImageUrl': doctorImageUrl,
      'patientId': patientId,
      'patientName': patientName,
      'patientImageUrl': patientImageUrl,
      'dateTime': Timestamp.fromDate(dateTime),
      'status': status,
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastModifiedAt': lastModifiedAt != null ? Timestamp.fromDate(lastModifiedAt!) : null,
      'patientFiles': patientFiles,
      'doctorFiles': doctorFiles,
      'reasonForChange': reasonForChange,
      'originalDateTime': originalDateTime != null ? Timestamp.fromDate(originalDateTime!) : null,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorImageUrl': doctorImageUrl,
      'patientId': patientId,
      'patientName': patientName,
      'patientImageUrl': patientImageUrl,
      'dateTime': dateTime,
      'status': status,
      'notes': notes,
      'createdAt': createdAt,
      'lastModifiedAt': lastModifiedAt,
      'patientFiles': patientFiles,
      'doctorFiles': doctorFiles,
      'reasonForChange': reasonForChange,
      'originalDateTime': originalDateTime,
    };
  }

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorImageUrl,
    String? patientId,
    String? patientName,
    String? patientImageUrl,
    DateTime? dateTime,
    String? status,
    String? notes,
    DateTime? createdAt,
    DateTime? lastModifiedAt,
    List<String>? patientFiles,
    List<String>? doctorFiles,
    String? reasonForChange,
    DateTime? originalDateTime,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorImageUrl: doctorImageUrl ?? this.doctorImageUrl,
      patientId: patientId ?? this.patientId,
      patientName: patientName ?? this.patientName,
      patientImageUrl: patientImageUrl ?? this.patientImageUrl,
      dateTime: dateTime ?? this.dateTime,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      patientFiles: patientFiles ?? this.patientFiles,
      doctorFiles: doctorFiles ?? this.doctorFiles,
      reasonForChange: reasonForChange ?? this.reasonForChange,
      originalDateTime: originalDateTime ?? this.originalDateTime,
    );
  }
}
