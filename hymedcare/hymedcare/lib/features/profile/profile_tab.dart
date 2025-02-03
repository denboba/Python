
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hymedcare/screens/utilities/about_us.dart';
import 'package:provider/provider.dart';
import '../../auth/login_page.dart';
import '../../provider/auth_provider.dart';
import 'edit_profile_screen.dart';
import '../../settings/screens/settings_screen.dart';
import '../../services/location_service.dart';
import '../../screens/location_map_screen.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  Widget _buildInfoItem(String label, String? value) {
    return CupertinoListTile(
      title: Text(label),
      subtitle: Text(value ?? 'Not specified'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<HymedCareAuthProvider>(context);
    final currentUser = authProvider.currentUser;
    final isDoctor = currentUser?.role == 'doctor';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Profile'),
        trailing: currentUser != null
            ? CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Text('Edit'),
          onPressed: () {
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => const EditProfileScreen(),
              ),
            );
          },
        )
            : null,
      ),
      child: SafeArea(
        child: currentUser == null
            ? const Center(child: CupertinoActivityIndicator())
            : ListView(
          children: [
            // Profile Header
            CupertinoListSection.insetGrouped(
              header: const Text('Profile'),
              children: [
                CupertinoListTile(
                  leading: CircleAvatar(
                    backgroundImage: currentUser.profilePicture != null
                        ? NetworkImage(currentUser.profilePicture!)
                        : null,
                    child: currentUser.profilePicture == null
                        ? const Icon(CupertinoIcons.person_fill)
                        : null,
                  ),
                  title: Text('${currentUser.firstName} ${currentUser.lastName}'),
                  subtitle: currentUser.bio != null ? Text(currentUser.bio!) : null,
                ),
                if (isDoctor)
                  CupertinoListTile(
                    title: const Text('Doctor'),
                    leading: const Icon(CupertinoIcons.heart_fill, color: CupertinoColors.activeGreen),
                  ),
              ],
            ),

            // Contact Information
            CupertinoListSection.insetGrouped(
              header: const Text('Contact Information'),
              children: [
                _buildInfoItem('Email', currentUser.email),
                _buildInfoItem('Phone', currentUser.phoneNumber),
                _buildInfoItem('Address', currentUser.address),
                if (currentUser.emergencyContact != null)
                  _buildInfoItem('Emergency Contact', currentUser.emergencyContact),
              ],
            ),

            // Medical Information (for patients)
            if (!isDoctor)
              CupertinoListSection.insetGrouped(
                header: const Text('Medical Information'),
                children: [
                  _buildInfoItem('Blood Type', currentUser.bloodType),
                  _buildInfoItem('Allergies', currentUser.allergies),
                  _buildInfoItem('Current Medications', currentUser.currentMedications),
                  _buildInfoItem('Insurance Provider', currentUser.insuranceProvider),
                  _buildInfoItem('Insurance Number', currentUser.insuranceNumber),
                ],
              ),

            // Professional Information (for doctors)
            if (isDoctor)
              CupertinoListSection.insetGrouped(
                header: const Text('Professional Information'),
                children: [
                  _buildInfoItem('Specialization', currentUser.specialization),
                  _buildInfoItem('License Number', currentUser.licenseNumber),
                  _buildInfoItem('Experience', currentUser.experienceYears != null ? '${currentUser.experienceYears} years' : null),
                  _buildInfoItem('Education', currentUser.education),
                  if (currentUser.languages != null)
                    _buildInfoItem('Languages', currentUser.languages!.join(', ')),
                  if (currentUser.certifications != null)
                    _buildInfoItem('Certifications', currentUser.certifications!.join('\n')),
                ],
              ),

            // Actions section
            CupertinoListSection.insetGrouped(
              header: const Text('Account'),
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.pencil),
                  title: const Text('Edit Profile'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.settings),
                  title: const Text('Settings'),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () {
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (context) => const SettingsScreen(),
                      ),
                    );
                  },
                ),
                if (!isDoctor)
                  CupertinoListTile(
                    leading: const Icon(CupertinoIcons.location),
                    title: const Text('View My Location'),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const LocationMapScreen(),
                        ),
                      );
                    },
                  ),
                CupertinoListTile(
                  leading: const Icon(
                    CupertinoIcons.square_arrow_right,
                    color: CupertinoColors.destructiveRed,
                  ),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: CupertinoColors.destructiveRed,
                    ),
                  ),
                  onTap: () async {
                    await authProvider.signOut();
                    if (context.mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const TelemedLoginPage(),
                        ),
                            (route) => false,
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}