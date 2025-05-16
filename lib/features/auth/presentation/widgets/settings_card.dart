import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    final localizations = AppLocalizations.of(context);
    String getString(
      String? Function(AppLocalizations l) selector,
      String fallback,
    ) {
      final l = localizations;
      if (l == null) return fallback;
      try {
        return selector(l) ?? fallback;
      } catch (_) {
        return fallback;
      }
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align all children to the left
        children: [
          SwitchListTile(
            title: Text(
              getString((l) => l.darkMode, 'Dark Mode'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
            ),
            secondary: Icon(
              isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
              size: 22.sp,
            ),
            value: isDarkMode,
            onChanged: onDarkModeToggle,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          Divider(
            height: 1,
            color: Colors.grey.shade200,
            thickness: 0.3,
            endIndent: 6.w,
            indent: 6.w,
          ),
          SwitchListTile(
            title: Text(
              getString((l) => l.notifications, 'Notifications'),
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
            ),
            secondary: Icon(Icons.notifications_outlined, size: 22.sp),
            value: notificationsEnabled,
            onChanged: onNotificationsToggle,
            contentPadding: EdgeInsets.symmetric(horizontal: 8.w),
            controlAffinity: ListTileControlAffinity.trailing,
          ),
          if (additionalOptions != null) ...[
            // Add additional options if provided
            Divider(
              height: 1,
              color: Colors.grey.shade200,
              thickness: 0.3,
              endIndent: 6.w,
              indent: 6.w,
            ),
            ...additionalOptions!,
          ],
        ],
      ),
    );
  }
}
