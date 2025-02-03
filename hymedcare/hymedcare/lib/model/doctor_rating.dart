class DoctorRating {
  final String id;
  final String doctorId;
  final String patientId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  DoctorRating({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory DoctorRating.fromMap(Map<String, dynamic> map) {
    return DoctorRating(
      id: map['id'] as String,
      doctorId: map['doctorId'] as String,
      patientId: map['patientId'] as String,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
