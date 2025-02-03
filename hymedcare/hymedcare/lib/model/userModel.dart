class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String role; // "doctor" or "patient"
  final String? profilePicture;
  final String createdAt;
  final String lastSeen;
  final String phoneNumber;
  final String? address;
  final String? bio;
  final String? emergencyContact;
  final String? bloodType;
  final String? allergies;
  final String? currentMedications;

  // Location fields
  final double? latitude;
  final double? longitude;
  final bool? shareLocation;

  // Doctor-specific fields
  final String? specialization;
  final String? licenseNumber;
  final int? experienceYears;
  final Map<String, dynamic>? availableHours;
  final List<String>? certifications;
  final String? education;
  final List<String>? languages;
  final bool? isAvailable;
  final double? consultationFee;

  // Patient-specific fields
  final String? medicalHistory;
  final String? assignedDoctorId;
  final String? insuranceProvider;
  final String? insuranceNumber;
  final DateTime? dateOfBirth;
  final String? gender;

  // Rating fields
  final double? rating;
  final int? reviewCount;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
    required this.phoneNumber,
    this.profilePicture,
    required this.createdAt,
    required this.lastSeen,
    this.address,
    this.bio,
    this.emergencyContact,
    this.bloodType,
    this.allergies,
    this.currentMedications,
    this.latitude,
    this.longitude,
    this.shareLocation,
    this.specialization,
    this.licenseNumber,
    this.experienceYears,
    this.availableHours,
    this.certifications,
    this.education,
    this.languages,
    this.isAvailable,
    this.consultationFee,
    this.medicalHistory,
    this.assignedDoctorId,
    this.insuranceProvider,
    this.insuranceNumber,
    this.dateOfBirth,
    this.gender,
    this.rating,
    this.reviewCount,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    String formatTimestamp(dynamic timestamp) {
      if (timestamp == null) return '';
      if (timestamp is int) {
        return timestamp.toString();
      }
      return timestamp.toString();
    }

    return UserModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      profilePicture: map['profilePicture'],
      createdAt: formatTimestamp(map['createdAt']),
      lastSeen: formatTimestamp(map['lastSeen']),
      address: map['address'],
      bio: map['bio'],
      emergencyContact: map['emergencyContact'],
      bloodType: map['bloodType'],
      allergies: map['allergies'],
      currentMedications: map['currentMedications'],
      latitude: map['latitude']?.toDouble(),
      longitude: map['longitude']?.toDouble(),
      shareLocation: map['shareLocation'],
      specialization: map['specialization'],
      licenseNumber: map['licenseNumber'],
      experienceYears: map['experienceYears'],
      availableHours: map['availableHours'],
      certifications: map['certifications'] != null ? List<String>.from(map['certifications']) : null,
      education: map['education'],
      languages: map['languages'] != null ? List<String>.from(map['languages']) : null,
      isAvailable: map['isAvailable'],
      consultationFee: map['consultationFee']?.toDouble(),
      medicalHistory: map['medicalHistory'],
      assignedDoctorId: map['assignedDoctorId'],
      insuranceProvider: map['insuranceProvider'],
      insuranceNumber: map['insuranceNumber'],
      dateOfBirth: map['dateOfBirth'] != null ? DateTime.parse(map['dateOfBirth']) : null,
      gender: map['gender'],
      rating: map['rating']?.toDouble(),
      reviewCount: map['reviewCount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
      'phoneNumber': phoneNumber,
      'profilePicture': profilePicture,
      'createdAt': createdAt,
      'lastSeen': lastSeen,
      'address': address,
      'bio': bio,
      'emergencyContact': emergencyContact,
      'bloodType': bloodType,
      'allergies': allergies,
      'currentMedications': currentMedications,
      'latitude': latitude,
      'longitude': longitude,
      'shareLocation': shareLocation,
      'specialization': specialization,
      'licenseNumber': licenseNumber,
      'experienceYears': experienceYears,
      'availableHours': availableHours,
      'certifications': certifications,
      'education': education,
      'languages': languages,
      'isAvailable': isAvailable,
      'consultationFee': consultationFee,
      'medicalHistory': medicalHistory,
      'assignedDoctorId': assignedDoctorId,
      'insuranceProvider': insuranceProvider,
      'insuranceNumber': insuranceNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'rating': rating,
      'reviewCount': reviewCount,
    };
  }

  UserModel copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    String? email,
    String? role,
    String? phoneNumber,
    String? profilePicture,
    String? createdAt,
    String? lastSeen,
    String? address,
    String? bio,
    String? emergencyContact,
    String? bloodType,
    String? allergies,
    String? currentMedications,
    double? latitude,
    double? longitude,
    bool? shareLocation,
    String? specialization,
    String? licenseNumber,
    int? experienceYears,
    Map<String, dynamic>? availableHours,
    List<String>? certifications,
    String? education,
    List<String>? languages,
    bool? isAvailable,
    double? consultationFee,
    String? medicalHistory,
    String? assignedDoctorId,
    String? insuranceProvider,
    String? insuranceNumber,
    DateTime? dateOfBirth,
    String? gender,
    double? rating,
    int? reviewCount,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
      lastSeen: lastSeen ?? this.lastSeen,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      bloodType: bloodType ?? this.bloodType,
      allergies: allergies ?? this.allergies,
      currentMedications: currentMedications ?? this.currentMedications,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      shareLocation: shareLocation ?? this.shareLocation,
      specialization: specialization ?? this.specialization,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      experienceYears: experienceYears ?? this.experienceYears,
      availableHours: availableHours ?? this.availableHours,
      certifications: certifications ?? this.certifications,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      isAvailable: isAvailable ?? this.isAvailable,
      consultationFee: consultationFee ?? this.consultationFee,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      assignedDoctorId: assignedDoctorId ?? this.assignedDoctorId,
      insuranceProvider: insuranceProvider ?? this.insuranceProvider,
      insuranceNumber: insuranceNumber ?? this.insuranceNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }
}
