import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorModel {
  final String id;
  final String name;
  final String imageUrl;
  final String specialization;
  final String about;
  final double rating;
  final int numberOfReviews;
  final String phoneNumber;
  final String email;
  final double latitude;
  final double longitude;
  final String address;
  final bool isAvailable;
  final List<String> availableDays;
  final Map<String, List<String>> availableTimeSlots;

  DoctorModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.specialization,
    required this.about,
    required this.rating,
    required this.numberOfReviews,
    required this.phoneNumber,
    required this.email,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.isAvailable,
    required this.availableDays,
    required this.availableTimeSlots,
  });

  factory DoctorModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DoctorModel(
      id: doc.id,
      name: data['name'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      specialization: data['specialization'] ?? '',
      about: data['about'] ?? '',
      rating: (data['rating'] ?? 0.0).toDouble(),
      numberOfReviews: data['numberOfReviews'] ?? 0,
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      address: data['address'] ?? '',
      isAvailable: data['isAvailable'] ?? false,
      availableDays: List<String>.from(data['availableDays'] ?? []),
      availableTimeSlots: Map<String, List<String>>.from(
        (data['availableTimeSlots'] ?? {}).map(
          (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'imageUrl': imageUrl,
      'specialization': specialization,
      'about': about,
      'rating': rating,
      'numberOfReviews': numberOfReviews,
      'phoneNumber': phoneNumber,
      'email': email,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'isAvailable': isAvailable,
      'availableDays': availableDays,
      'availableTimeSlots': availableTimeSlots,
    };
  }

  DoctorModel copyWith({
    String? id,
    String? name,
    String? imageUrl,
    String? specialization,
    String? about,
    double? rating,
    int? numberOfReviews,
    String? phoneNumber,
    String? email,
    double? latitude,
    double? longitude,
    String? address,
    bool? isAvailable,
    List<String>? availableDays,
    Map<String, List<String>>? availableTimeSlots,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      imageUrl: imageUrl ?? this.imageUrl,
      specialization: specialization ?? this.specialization,
      about: about ?? this.about,
      rating: rating ?? this.rating,
      numberOfReviews: numberOfReviews ?? this.numberOfReviews,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      isAvailable: isAvailable ?? this.isAvailable,
      availableDays: availableDays ?? this.availableDays,
      availableTimeSlots: availableTimeSlots ?? this.availableTimeSlots,
    );
  }
}
