import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import 'widgets/profile_picture_widget.dart';
import 'widgets/settings_card.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  bool _isUploading = false;

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

  Future<void> _pickImage(ImageSource source) async {
    try {
      setState(() {
        _isUploading = true;
      });

      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      // Crop the image
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio4x3,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Theme.of(context).primaryColor,
            toolbarWidgetColor: Colors.white,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop Image'),
        ],
      );

      if (croppedFile == null) {
        setState(() {
          _isUploading = false;
        });
        return;
      }

      setState(() {
        _imageFile = File(croppedFile.path);
      });

      final success = await context.read<AuthProvider>().updateProfileImage(
        croppedFile.path,
      );

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        // Enhanced snackbar messages with bold text for better visibility
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                ),
                SizedBox(width: 8.w),
                Text(
                  success
                      ? 'Profile image updated successfully'
                      : 'Failed to update profile image',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor:
                success ? Colors.green.shade100 : Colors.red.shade100,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  ImageProvider? _getProfileImage(AuthProvider authProvider) {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (authProvider.profileImage != null) {
      return NetworkImage(authProvider.profileImage!);
    }
    return null;
  }

  Future<void> _saveProfile(AuthProvider authProvider) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isUploading = true;
      });

      try {
        // Call the updateProfile method synchronously
        authProvider.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8.w),
                  const Text('Profile updated successfully!'),
                ],
              ),
              backgroundColor: Colors.green.shade100,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 8.w),
                  Text('Error updating profile: $e'),
                ],
              ),
              backgroundColor: Colors.red.shade100,
            ),
          );
        }
      } finally {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (BuildContext context) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Profile Picture',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 16.h),
                ListTile(
                  leading: Icon(Icons.photo_library, size: 24.sp),
                  title: Text(
                    'Choose from Gallery',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.camera_alt, size: 24.sp),
                  title: Text(
                    'Take a Photo',
                    style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final primaryColor = isDark ? AppColors.primaryDark : AppColors.primary;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: primaryColor,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            ProfilePictureWidget(
              imageProvider: _getProfileImage(authProvider),
              isUploading: _isUploading,
              onEdit: _showImageSourceActionSheet,
              primaryColor: primaryColor,
              iconColor: iconColor,
              userName: authProvider.userName,
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
                  color: primaryColor,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      prefixIcon: Icon(Icons.person_outline, size: 24.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter your name'
                                : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined, size: 24.sp),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    validator:
                        (value) =>
                            value?.isEmpty ?? true
                                ? 'Please enter your email'
                                : null,
                  ),
                  SizedBox(height: 24.h),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          _isUploading
                              ? null
                              : () => _saveProfile(authProvider),
                      child:
                          _isUploading
                              ? const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              )
                              : Text(
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
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            SettingsCard(
              isDarkMode: themeProvider.isDarkMode,
              notificationsEnabled: authProvider.notificationsEnabled,
              onDarkModeToggle: (_) => themeProvider.toggleTheme(),
              onNotificationsToggle: authProvider.toggleNotifications,
              additionalOptions: [
                ListTile(
                  leading: Icon(
                    Icons.lock_outline,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  title: Text(
                    'Change Password',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: iconColor,
                  ),
                  onTap: () {
                    // Navigate to password change screen or show a dialog
                  },
                ),
                Divider(height: 1, color: Colors.grey.shade300, thickness: 0.5),
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: Text(
                    'Delete Account',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Inter',
                      color: Colors.red,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: Colors.red,
                  ),
                  onTap: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Delete Account'),
                          content: const Text(
                            'Are you sure you want to delete your account? This action cannot be undone.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        );
                      },
                    );

                    if (confirm == true) {
                      await authProvider.deleteAccount();
                      if (mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    }
                  },
                ),
              ],
            ),

            // Create a new card section for Languages and Currency
            SizedBox(height: 32.h),
            Text(
              'Preferences',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
            SizedBox(height: 16.h),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Language',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    trailing: DropdownButton<String>(
                      value: null, // Removed default value
                      // hint: Text('Select Language'),
                      underline: Container(), // Remove the underline
                      items:
                          authProvider.availableLanguages.map((
                            String language,
                          ) {
                            return DropdownMenuItem<String>(
                              value: language,
                              child: Text(
                                language,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newLanguage) {
                        if (newLanguage != null) {
                          authProvider.changeLanguage(newLanguage);
                        }
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey.shade300,
                    thickness: 0.5,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.attach_money,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                    title: Text(
                      'Currency',
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    trailing: DropdownButton<String>(
                      value: null, // Removed default value
                      // hint: Text('Select Currency'),
                      underline: Container(), // Remove the underline
                      items:
                          authProvider.availableCurrencies.map((
                            String currency,
                          ) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(
                                currency,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            );
                          }).toList(),
                      onChanged: (String? newCurrency) {
                        if (newCurrency != null) {
                          authProvider.changeCurrency(newCurrency);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Logout Button
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
                ),
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
          ],
        ),
      ),
    );
  }
}
