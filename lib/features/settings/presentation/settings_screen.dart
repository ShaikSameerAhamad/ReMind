import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: const [
            ListTile(
              leading: Icon(Icons.notifications_outlined),
              title: Text('Notifications'),
              subtitle: Text('Control reminders, tasks, alarms, and digests.'),
            ),
            ListTile(
              leading: Icon(Icons.text_fields_rounded),
              title: Text('Reader'),
              subtitle: Text('Choose reading theme, text size, and spacing.'),
            ),
            ListTile(
              leading: Icon(Icons.privacy_tip_outlined),
              title: Text('Privacy'),
              subtitle: Text('Review account and data controls.'),
            ),
          ],
        ),
      ),
    );
  }
}
