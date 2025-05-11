import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SettingsCard extends StatelessWidget {
  final bool isDarkMode;
  final bool notificationsEnabled;
  final ValueChanged<bool> onDarkModeToggle;
  final ValueChanged<bool> onNotificationsToggle;
  final List<Widget>? additionalOptions; // New parameter

  const SettingsCard({
    Key? key,
    required this.isDarkMode,
    required this.notificationsEnabled,
    required this.onDarkModeToggle,
    required this.onNotificationsToggle,
    this.additionalOptions, // Initialize new parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        children: [
          SwitchListTile(
            title: Text(
              'Dark Mode',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
            ),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 24.sp,
            ),
            value: isDarkMode,
            onChanged: onDarkModeToggle,
          ),
          Divider(height: 1, color: Colors.grey.shade300, thickness: 0.5),
          SwitchListTile(
            title: Text(
              'Notifications',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
            ),
            secondary: Icon(Icons.notifications_outlined, size: 24.sp),
            value: notificationsEnabled,
            onChanged: onNotificationsToggle,
          ),
          if (additionalOptions != null) ...[
            // Add additional options if provided
            Divider(height: 1, color: Colors.grey.shade300, thickness: 0.5),
            ...additionalOptions!,
          ],
        ],
      ),
    );
  }
}
