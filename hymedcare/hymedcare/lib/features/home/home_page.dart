import 'package:flutter/cupertino.dart';

import '../articles/screens/articles_tab.dart';
import '../chat/screen/chat_tab.dart';
import 'home_tab.dart';
import '../../appointments/screens/appointment_tab.dart';
import '../doctor/screens/patient_or_doctor_tab.dart';
import '../profile/profile_tab.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.calendar),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.group),
            label: 'Patients',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.doc_text),
            label: 'Articles',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble_2),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.person),
            label: 'Profile',
          ),
        ],
      ),
      tabBuilder: (context, index) {
        switch (index) {
          case 0:
            return const HomeTab();
          case 1:
            return const AppointmentsTab();
          case 2:
            return const PatientsTab();
          case 3:
            return const ArticlesTab();
          case 4:
            return const ChatTab();
          case 5:
            return const ProfileTab();
          default:
            return const HomeTab();
        }
      },
    );
  }
}
