import 'package:flutter/cupertino.dart';
import '../../../model/userModel.dart';
import '../../../appointments/screens/create_appointment_screen.dart';

class DoctorProfileScreen extends StatelessWidget {
  final UserModel doctor;

  const DoctorProfileScreen({
    required this.doctor,
    super.key,
  });

  String _formatAvailableHours(Map<String, dynamic>? hours) {
    if (hours == null || hours.isEmpty) return 'Not specified';
    
    return hours.entries
        .map((e) => '${e.key}: ${e.value}')
        .join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Doctor Profile'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Book'),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => CreateAppointmentScreen(
                  doctorId: doctor.uid,
                  doctorName: '${doctor.firstName} ${doctor.lastName}',
                  doctorImageUrl: doctor.profilePicture ?? '',
                ),
              ),
            );
          },
        ),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Doctor Image and Basic Info
            Center(
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: CupertinoColors.systemGrey5,
                      image: doctor.profilePicture != null
                          ? DecorationImage(
                              image: NetworkImage(doctor.profilePicture!),
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    child: doctor.profilePicture == null
                        ? const Icon(
                            CupertinoIcons.person_fill,
                            size: 60,
                            color: CupertinoColors.systemGrey,
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${doctor.firstName} ${doctor.lastName}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (doctor.specialization != null)
                    Text(
                      doctor.specialization!,
                      style: const TextStyle(
                        fontSize: 18,
                        color: CupertinoColors.activeBlue,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Professional Information
            const Text(
              'Professional Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: CupertinoIcons.number,
              title: 'License Number',
              value: doctor.licenseNumber ?? 'Not provided',
            ),
            if (doctor.experienceYears != null)
              _InfoTile(
                icon: CupertinoIcons.time,
                title: 'Years of Experience',
                value: '${doctor.experienceYears} years',
              ),
            if (doctor.availableHours != null)
              _InfoTile(
                icon: CupertinoIcons.clock,
                title: 'Available Hours',
                value: _formatAvailableHours(doctor.availableHours),
              ),

            const SizedBox(height: 32),

            // Contact Information
            const Text(
              'Contact Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _InfoTile(
              icon: CupertinoIcons.mail,
              title: 'Email',
              value: doctor.email,
            ),
            if (doctor.phoneNumber.isNotEmpty)
              _InfoTile(
                icon: CupertinoIcons.phone,
                title: 'Phone',
                value: doctor.phoneNumber,
              ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey6,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: CupertinoColors.activeBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CupertinoColors.systemGrey,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
