import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/theme_provider.dart';
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
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8.w),
                const Text(
                  'Image selected. Press Save Changes to update your profile.',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade100,
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
        // Update profile info
        authProvider.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
        );

        // Upload image if a new one was selected
        bool imageUpdateSuccess = true;
        String? imageErrorMessage;
        if (_imageFile != null) {
          try {
            imageUpdateSuccess = await authProvider.updateProfileImage(
              _imageFile!.path,
            );
          } catch (error) {
            imageUpdateSuccess = false;
            imageErrorMessage = error.toString().replaceAll('Exception: ', '');
            debugPrint('Error updating profile image: $error');
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.green),
                  SizedBox(width: 8.w),
                  Text(
                    _imageFile != null && !imageUpdateSuccess
                        ? 'Profile updated but image upload failed: ${imageErrorMessage ?? "Unknown error"}'
                        : 'Profile updated successfully!',
                  ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  leading: Icon(
                    Icons.photo_library,
                    size: 24.sp,
                    color: isDark ? Colors.white : Colors.black,
                  ),
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
                  leading: Icon(
                    Icons.camera_alt,
                    size: 24.sp,
                    color: isDark ? Colors.white : Colors.black,
                  ),
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

  void _showChangePasswordDialog() {
    final _currentPasswordController = TextEditingController();
    final _newPasswordController = TextEditingController();
    final _confirmPasswordController = TextEditingController();
    final _formKey = GlobalKey<FormState>();
    bool _isSubmitting = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Change Password'),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _currentPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Current Password',
                      ),
                      validator:
                          (v) =>
                              v == null || v.isEmpty
                                  ? 'Enter current password'
                                  : null,
                    ),
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'New Password',
                      ),
                      validator:
                          (v) =>
                              v == null || v.length < 6
                                  ? 'Min 6 characters'
                                  : null,
                    ),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Confirm New Password',
                      ),
                      validator:
                          (v) =>
                              v != _newPasswordController.text
                                  ? 'Passwords do not match'
                                  : null,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed:
                      _isSubmitting
                          ? null
                          : () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              setState(() => _isSubmitting = true);
                              // TODO: Integrate with AuthProvider.changePassword when backend is ready
                              await Future.delayed(const Duration(seconds: 1));
                              setState(() => _isSubmitting = false);
                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Password changed (demo only)',
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            }
                          },
                  child:
                      _isSubmitting
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text('Change Password'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  double _calculateProfileCompletion(AuthProvider authProvider) {
    int total = 3;
    int filled = 0;
    if ((authProvider.userName ?? '').isNotEmpty) filled++;
    if ((authProvider.userEmail ?? '').isNotEmpty) filled++;
    if (_getProfileImage(authProvider) != null) filled++;
    return filled / total;
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context);
    // Defensive: fallback to English strings if localizations is null
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

    final primaryColor = isDark ? AppColors.primaryDark : Colors.black;
    final iconColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final borderColor = isDark ? Colors.grey[800] : Colors.grey[200];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          getString((l) => l.profile, 'Profile'),
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : Colors.black,
          ),
        ),
        backgroundColor: isDark ? Colors.black : Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: iconColor),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Picture Section
            Center(
              child: Hero(
                tag: 'profile-avatar',
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ProfilePictureWidget(
                      imageProvider: _getProfileImage(authProvider),
                      isUploading: _isUploading,
                      onEdit: _showImageSourceActionSheet,
                      primaryColor: primaryColor,
                      iconColor:
                          Colors.white, // Force camera icon to always be white
                      userName: authProvider.userName,
                    ),
                    if (_isUploading)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.18),
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Profile Completion Meter
            Card(
              margin: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: borderColor ?? Colors.grey, width: 1.1),
              ),
              elevation: isDark ? 0 : 2,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.verified_user,
                          color: primaryColor,
                          size: 18.sp,
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: Text(
                            'Profile Completion', // fallback to English, since not in l10n
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 15.sp,
                              color: isDark ? Colors.white70 : primaryColor,
                            ),
                          ),
                        ),
                        Text(
                          '${(_calculateProfileCompletion(authProvider) * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.bold,
                            fontSize: 15.sp,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal:
                            12.w, // Increased horizontal margin for better alignment
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(6.r),
                        child: LinearProgressIndicator(
                          value: _calculateProfileCompletion(authProvider),
                          backgroundColor: Colors.grey[300],
                          color: primaryColor,
                          minHeight: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),

            // Personal Information Section
            Semantics(
              header: true,
              child: Row(
                children: [
                  Icon(Icons.person, color: primaryColor, size: 22.sp),
                  SizedBox(width: 8.w),
                  Text(
                    getString(
                      (l) => l.personalInformation,
                      'Personal Information',
                    ),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: borderColor ?? Colors.grey, width: 1.1),
              ),
              elevation: isDark ? 0 : 2,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 22.sp,
                            color: iconColor, // Use iconColor for consistency
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                hintText: getString((l) => l.name, 'Name'),
                                border: InputBorder.none,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 1.2,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return getString(
                                    (l) => l.pleaseEnterYourName,
                                    'Please enter your name',
                                  );
                                }
                                if (value.length < 2) {
                                  return 'Name too short';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.next,
                              autofillHints: const [AutofillHints.name],
                              style: TextStyle(fontSize: 15.sp),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 22.sp,
                            color: iconColor, // Use iconColor for consistency
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                hintText: getString((l) => l.email, 'Email'),
                                border: InputBorder.none,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.grey[200]!,
                                    width: 0.5,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: primaryColor,
                                    width: 1.2,
                                  ),
                                ),
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: 12.h,
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return getString(
                                    (l) => l.pleaseEnterYourEmail,
                                    'Please enter your email',
                                  );
                                }
                                if (value == authProvider.userEmail) {
                                  return null;
                                }
                                final emailRegex = RegExp(
                                  r'^[^@\s]+@[^@\s]+\.[^@\s]+\u0000?',
                                );
                                if (!emailRegex.hasMatch(value)) {
                                  return 'Invalid email address';
                                }
                                return null;
                              },
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.emailAddress,
                              autofillHints: const [AutofillHints.email],
                              style: TextStyle(fontSize: 15.sp),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              _isUploading
                                  ? null
                                  : () => _saveProfile(authProvider),
                          icon:
                              _isUploading
                                  ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Icon(
                                    Icons.save_alt_rounded,
                                    size: 18,
                                  ),
                          label: Text(
                            getString((l) => l.saveChanges, 'Save Changes'),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white70 : Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            elevation: isDark ? 0 : 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Settings Section
            SizedBox(height: 32.h),
            Row(
              children: [
                Icon(Icons.settings, color: primaryColor, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  getString((l) => l.settings, 'Settings'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            SettingsCard(
              isDarkMode: themeProvider.isDarkMode,
              notificationsEnabled: authProvider.notificationsEnabled,
              onDarkModeToggle: (_) => themeProvider.toggleTheme(),
              onNotificationsToggle: authProvider.toggleNotifications,
              additionalOptions: [
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                  ), // Align with SwitchListTile
                  leading: Icon(
                    Icons.lock_outline,
                    color: isDark ? Colors.white : Colors.black,
                    size: 22.sp,
                  ),
                  title: Text(
                    getString((l) => l.changePassword, 'Change Password'),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16.sp,
                    color: iconColor,
                  ),
                  onTap: _showChangePasswordDialog,
                ),
                Divider(
                  height: 1,
                  color: Colors.grey[200],
                  thickness: 0.5,
                  endIndent: 6.w,
                  indent: 6.w,
                ),
                ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                  ), // Align with SwitchListTile
                  leading: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                    size: 22.sp,
                  ),
                  title: Text(
                    getString((l) => l.deleteAccount, 'Delete Account'),
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

            // Preferences Section
            SizedBox(height: 32.h),
            Row(
              children: [
                Icon(Icons.tune, color: primaryColor, size: 22.sp),
                SizedBox(width: 8.w),
                Text(
                  getString((l) => l.preferences, 'Preferences'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : primaryColor,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Card(
              color: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: borderColor ?? Colors.grey, width: 1.1),
              ),
              elevation: isDark ? 0 : 2,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: isDark ? Colors.white : Colors.black,
                      size: 22.sp,
                    ),
                    title: Text(
                      getString((l) => l.language, 'Language'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    trailing: DropdownButton<String>(
                      value: authProvider.currentLanguage,
                      underline: Container(),
                      items: const [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(
                            'English',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'fr',
                          child: Text(
                            'Français',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'es',
                          child: Text(
                            'Español',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                          ),
                        ),
                        DropdownMenuItem(
                          value: 'ar',
                          child: Text(
                            'العربية',
                            style: TextStyle(fontFamily: 'Inter', fontSize: 14),
                          ),
                        ),
                      ],
                      onChanged: (String? newLanguage) {
                        if (newLanguage != null &&
                            newLanguage != authProvider.currentLanguage) {
                          // Change the language first
                          authProvider.changeLanguage(newLanguage);
                          // After the locale is updated and the widget tree rebuilds, show the SnackBar in the new language
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            final localizations = AppLocalizations.of(context);
                            String languageDisplayName;
                            switch (newLanguage) {
                              case 'en':
                                languageDisplayName =
                                    localizations?.languageEnglish ?? 'English';
                                break;
                              case 'fr':
                                languageDisplayName =
                                    localizations?.languageFrench ?? 'Français';
                                break;
                              case 'es':
                                languageDisplayName =
                                    localizations?.languageSpanish ?? 'Español';
                                break;
                              case 'ar':
                                languageDisplayName =
                                    localizations?.languageArabic ?? 'العربية';
                                break;
                              default:
                                languageDisplayName = newLanguage;
                            }
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: EdgeInsets.only(
                                  bottom: 24.h,
                                  left: 16.w,
                                  right: 16.w,
                                ),
                                backgroundColor: Colors.green.shade100,
                                elevation: 6,
                                content: Row(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      color: Colors.green.shade800,
                                    ),
                                    SizedBox(width: 10.w),
                                    Expanded(
                                      child: Text(
                                        localizations?.languageChanged(
                                              languageDisplayName,
                                            ) ??
                                            'Language changed to $languageDisplayName!',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.green.shade900,
                                          fontFamily: 'Inter',
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          });
                        }
                      },
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: Colors.grey[200],
                    thickness: 0.5,
                    endIndent: 6.w,
                    indent: 6.w,
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.attach_money,
                      color: isDark ? Colors.white : Colors.black,
                      size: 22.sp,
                    ),
                    title: Text(
                      getString((l) => l.currency, 'Currency'),
                      style: Theme.of(
                        context,
                      ).textTheme.bodyLarge?.copyWith(fontFamily: 'Inter'),
                    ),
                    trailing: DropdownButton<String>(
                      value: authProvider.currentCurrency,
                      underline: Container(),
                      items:
                          authProvider.availableCurrencies.map((
                            String currency,
                          ) {
                            return DropdownMenuItem<String>(
                              value: currency,
                              child: Text(
                                currency,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
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
              child: ElevatedButton.icon(
                onPressed:
                    _isUploading
                        ? null
                        : () async {
                          await authProvider.logout();
                          if (mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              '/login',
                              (route) => false,
                            );
                          }
                        },
                icon:
                    _isUploading
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(Icons.logout, size: 18),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.error,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  elevation: isDark ? 0 : 2,
                ),
                label: Text(
                  getString((l) => l.logout, 'Logout'),
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
    );
  }
}
