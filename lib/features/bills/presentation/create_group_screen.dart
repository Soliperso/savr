import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../../features/shared/widgets/animated_snackbar.dart';
import '../../auth/presentation/widgets/profile_picture_widget.dart';
import '../../../providers/bill_provider.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<String> _availableFriends = [
    'John',
    'Sarah',
    'Mike',
    'Lisa',
    'David',
  ];
  final List<String> _selectedFriends = [];
  File? _avatarFile;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatarFromSource(ImageSource source) async {
    final picked = await _picker.pickImage(
      source: source,
      maxWidth: 600,
      maxHeight: 600,
      imageQuality: 85,
    );
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

  void _showAvatarSourceSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatarFromSource(ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatarFromSource(ImageSource.camera);
                  },
                ),
              ],
            ),
          ),
    );
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _descriptionController.clear();
      _selectedFriends.clear();
      _avatarFile = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final cardColor = isDark ? Colors.grey[900] : Colors.white;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: localizations.cancel,
            onPressed: _clearForm,
          ),
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'Cancel',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Card(
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          elevation: isDark ? 0 : 3,
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ProfilePictureWidget(
                      imageProvider:
                          _avatarFile != null ? FileImage(_avatarFile!) : null,
                      isUploading: false,
                      onEdit: _showAvatarSourceSheet,
                      primaryColor: primaryColor,
                      iconColor: iconColor,
                      userName: _nameController.text,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // Group name
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        autofocus: true,
                        maxLength: 30,
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          prefixIcon: const Icon(Icons.group),
                          counterText: '',
                          helperText: 'Max 30 characters',
                        ),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a group name';
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted:
                            (_) =>
                                FocusScope.of(context).requestFocus(_descFocus),
                      ),
                      if (_nameController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed:
                              () => setState(() => _nameController.clear()),
                          tooltip: 'Clear',
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  // Description
                  Stack(
                    alignment: Alignment.centerRight,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        focusNode: _descFocus,
                        maxLength: 60,
                        decoration: InputDecoration(
                          labelText: 'Description (optional)',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          prefixIcon: const Icon(Icons.description),
                          counterText: '',
                          helperText: 'Max 60 characters',
                        ),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                      if (_descriptionController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed:
                              () => setState(
                                () => _descriptionController.clear(),
                              ),
                          tooltip: 'Clear',
                        ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  // Members section
                  Text(
                    'Add Members',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Select friends to add to this group',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  if (_availableFriends.isEmpty)
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      child: Text(
                        'No friends available',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ),
                  if (_availableFriends.isNotEmpty)
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children:
                          _availableFriends.map((friend) {
                            final isSelected = _selectedFriends.contains(
                              friend,
                            );
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              curve: Curves.easeInOut,
                              child: FilterChip(
                                selected: isSelected,
                                avatar: CircleAvatar(
                                  backgroundColor:
                                      isSelected
                                          ? primaryColor
                                          : Colors.grey[300],
                                  child: Text(
                                    friend[0],
                                    style: TextStyle(
                                      color:
                                          isSelected
                                              ? Colors.white
                                              : Colors.black,
                                    ),
                                  ),
                                ),
                                label: Text(
                                  friend,
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                  ),
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedFriends.add(friend);
                                    } else {
                                      _selectedFriends.remove(friend);
                                    }
                                  });
                                  HapticFeedback.mediumImpact();
                                },
                                selectedColor: primaryColor,
                                checkmarkColor: Colors.white,
                                backgroundColor:
                                    isSelected
                                        ? primaryColor.withOpacity(0.13)
                                        : Colors.grey[100],
                                elevation: isSelected ? 2 : 0,
                              ),
                            );
                          }).toList(),
                    ),
                  SizedBox(height: 32.h),
                  // Error message if no members selected
                  if (_formKey.currentState?.validate() == true &&
                      _selectedFriends.isEmpty)
                    Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 20.sp,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'Please select at least one member',
                          style: TextStyle(color: Colors.red, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  // Create button
                  SizedBox(
                    width: double.infinity,
                    height: 50.h,
                    child: AnimatedScale(
                      scale: _isLoading ? 0.97 : 1.0,
                      duration: const Duration(milliseconds: 120),
                      child: Semantics(
                        label: _isLoading ? 'Saving...' : 'Create Group',
                        button: true,
                        child: ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleCreateGroup,
                          icon:
                              _isLoading
                                  ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.save_alt_rounded),
                          label: Text(
                            'Create Group',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
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
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handleCreateGroup() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (_selectedFriends.isEmpty) {
        AnimatedSnackBar.show(
          context,
          message: 'Please select at least one member',
          backgroundColor: Colors.red.withOpacity(0.9),
        );
        return;
      }
      setState(() => _isLoading = true);
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // Simulate loading
      final billProvider = Provider.of<BillProvider>(context, listen: false);
      billProvider.createGroup(
        name: _nameController.text,
        description:
            _descriptionController.text.isEmpty
                ? '-'
                : _descriptionController.text,
        members: _selectedFriends,
        avatarFile: _avatarFile,
      );
      setState(() => _isLoading = false);
      if (mounted) {
        Navigator.pop(context);
        AnimatedSnackBar.show(
          context,
          message: 'Group created successfully',
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
        );
      }
    }
  }
}
