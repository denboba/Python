import 'package:flutter/cupertino.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../model/userModel.dart';
import 'doctor_profile_screen.dart';

class DoctorsListScreen extends StatefulWidget {
  const DoctorsListScreen({super.key});

  @override
  State<DoctorsListScreen> createState() => _DoctorsListScreenState();
}

class _DoctorsListScreenState extends State<DoctorsListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Find a Doctor'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: CupertinoSearchTextField(
                controller: _searchController,
                placeholder: 'Search doctors by name or specialization',
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .where('role', isEqualTo: 'Doctor')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: CupertinoColors.systemRed),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(child: CupertinoActivityIndicator());
                  }

                  final doctors = snapshot.data!.docs
                      .map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        return UserModel(
                          uid: doc.id,
                          firstName: data['firstName'] ?? '',
                          lastName: data['lastName'] ?? '',
                          email: data['email'] ?? '',
                          role: data['role'] ?? '',
                          phoneNumber: data['phoneNumber'],
                          profilePicture: data['profilePicture'],
                          specialization: data['specialization'],
                          licenseNumber: data['licenseNumber'],
                          experienceYears: data['experienceYears'],
                          availableHours: data['availableHours'],
                          createdAt: data['createdAt'] ?? DateTime.now().toString(),
                          lastSeen: data['lastSeen'] ?? DateTime.now().toString(),
                        );
                      })
                      .where((doctor) {
                        if (_searchQuery.isEmpty) return true;
                        final name = '${doctor.firstName} ${doctor.lastName}'
                            .toLowerCase();
                        final specialization =
                            doctor.specialization?.toLowerCase() ?? '';
                        return name.contains(_searchQuery) ||
                            specialization.contains(_searchQuery);
                      })
                      .toList();

                  if (doctors.isEmpty) {
                    return const Center(
                      child: Text(
                        'No doctors found',
                        style: TextStyle(color: CupertinoColors.systemGrey),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: doctors.length,
                    itemBuilder: (context, index) {
                      final doctor = doctors[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) =>
                                  DoctorProfileScreen(doctor: doctor),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: CupertinoColors.systemBackground,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: CupertinoColors.systemGrey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: CupertinoColors.systemGrey5,
                                  image: doctor.profilePicture != null
                                      ? DecorationImage(
                                          image:
                                              NetworkImage(doctor.profilePicture!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: doctor.profilePicture == null
                                    ? const Icon(
                                        CupertinoIcons.person_fill,
                                        size: 30,
                                        color: CupertinoColors.systemGrey,
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dr. ${doctor.firstName} ${doctor.lastName}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    if (doctor.specialization != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        doctor.specialization!,
                                        style: const TextStyle(
                                          color: CupertinoColors.activeBlue,
                                        ),
                                      ),
                                    ],
                                    if (doctor.experienceYears != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        '${doctor.experienceYears} years experience',
                                        style: const TextStyle(
                                          color: CupertinoColors.systemGrey,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const Icon(
                                CupertinoIcons.chevron_right,
                                color: CupertinoColors.systemGrey,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
