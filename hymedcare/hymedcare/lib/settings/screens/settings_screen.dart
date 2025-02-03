import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../theme/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Settings'),
      ),
      child: SafeArea(
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return ListView(
              children: [
                const SizedBox(height: 20),
                CupertinoListSection.insetGrouped(
                  header: const Text('Appearance'),
                  children: [
                    CupertinoListTile(
                      title: const Text('Dark Mode'),
                      trailing: CupertinoSwitch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) {
                          themeProvider.toggleTheme();
                        },
                      ),
                    ),
                    CupertinoListTile(
                      title: const Text('Use System Theme'),
                      trailing: CupertinoSwitch(
                        value: themeProvider.useSystemTheme,
                        onChanged: (value) {
                          themeProvider.setUseSystemTheme(value);
                        },
                      ),
                    ),
                  ],
                ),
                // Add more settings sections here
              ],
            );
          },
        ),
      ),
    );
  }
}
