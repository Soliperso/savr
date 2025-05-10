import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _nameController = TextEditingController(text: authProvider.userName);
    _emailController = TextEditingController(text: authProvider.userEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      authProvider.updateProfile(
        name: _nameController.text,
        email: _emailController.text,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  Semantics(
                    label:
                        'Profile picture with ${(authProvider.userName?.isNotEmpty ?? false) ? "the letter ${authProvider.userName![0].toUpperCase()}" : "no text"}',
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Theme.of(
                        context,
                      ).primaryColor.withOpacity(0.1),
                      child: Text(
                        (authProvider.userName?.isNotEmpty ?? false)
                            ? authProvider.userName![0].toUpperCase()
                            : '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Semantics(
                      button: true,
                      label: 'Edit profile picture',
                      child: Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.edit,
                          size: 16.sp,
                          color: Colors.white,
                          semanticLabel: 'Edit',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 32.h),

            // Personal Information Section
            Semantics(
              header: true,
              child: Text(
                'Personal Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Semantics(
                    label: 'Name input field',
                    child: TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Name',
                        hintText: 'Enter your name',
                        prefixIcon: Icon(Icons.person_outline, size: 24.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Please enter your name'
                                  : null,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Semantics(
                    label: 'Email input field',
                    child: TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email_outlined, size: 24.sp),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                      validator:
                          (value) =>
                              value?.isEmpty ?? true
                                  ? 'Please enter your email'
                                  : null,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _saveProfile(authProvider),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      child: Text(
                        'Save Changes',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Settings Section
            SizedBox(height: 32.h),
            Semantics(
              header: true,
              child: Text(
                'Settings',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  Semantics(
                    toggled: authProvider.notificationsEnabled,
                    label: 'Toggle notifications',
                    child: SwitchListTile(
                      title: Text(
                        'Notifications',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      ),
                      secondary: Icon(
                        Icons.notifications_outlined,
                        size: 24.sp,
                      ),
                      value: authProvider.notificationsEnabled,
                      onChanged: authProvider.toggleNotifications,
                    ),
                  ),
                  Divider(height: 1),
                  Semantics(
                    toggled: authProvider.savePaymentMethods,
                    label: 'Toggle save payment methods',
                    child: SwitchListTile(
                      title: Text(
                        'Save Payment Methods',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                      ),
                      secondary: Icon(Icons.credit_card_outlined, size: 24.sp),
                      value: authProvider.savePaymentMethods,
                      onChanged: authProvider.toggleSavePaymentMethods,
                    ),
                  ),
                  Divider(height: 1),
                  Consumer<ThemeProvider>(
                    builder:
                        (context, themeProvider, _) => Semantics(
                          toggled: themeProvider.isDarkMode,
                          label: 'Toggle dark mode',
                          child: SwitchListTile(
                            title: Text(
                              'Dark Mode',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(fontFamily: 'Inter'),
                            ),
                            secondary: Icon(
                              themeProvider.isDarkMode
                                  ? Icons.dark_mode_outlined
                                  : Icons.light_mode_outlined,
                              size: 24.sp,
                            ),
                            value: themeProvider.isDarkMode,
                            onChanged: (_) => themeProvider.toggleTheme(),
                          ),
                        ),
                  ),
                ],
              ),
            ),

            // Logout Section
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Semantics(
                  button: true,
                  label: 'Log out of your account',
                  child: Text(
                    'Logout',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
