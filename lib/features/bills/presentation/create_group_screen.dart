import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/bill_provider.dart';
import '../../../features/shared/widgets/animated_snackbar.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Group name
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Group Name',
                  labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.group),
                ),
                style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a group name';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  labelStyle: TextStyle(fontFamily: 'Inter', fontSize: 14.sp),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                style: TextStyle(fontFamily: 'Inter', fontSize: 16.sp),
                maxLines: 2,
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

              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children:
                    _availableFriends.map((friend) {
                      final isSelected = _selectedFriends.contains(friend);
                      return FilterChip(
                        selected: isSelected,
                        label: Text(
                          friend,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: isSelected ? Colors.white : Colors.black87,
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
                        },
                        selectedColor: Theme.of(context).primaryColor,
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
              ),

              SizedBox(height: 32.h),

              // Create button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _handleCreateGroup,
                  style: ElevatedButton.styleFrom(
                    textStyle: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  child: const Text('Create Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCreateGroup() {
    if (_formKey.currentState!.validate()) {
      if (_selectedFriends.isEmpty) {
        AnimatedSnackBar.show(
          context,
          message: 'Please select at least one member',
          backgroundColor: Colors.red.withOpacity(0.9),
        );
        return;
      }

      final billProvider = Provider.of<BillProvider>(context, listen: false);
      final newGroup = billProvider.createGroup(
        name: _nameController.text,
        description:
            _descriptionController.text.isEmpty
                ? 'No description'
                : _descriptionController.text,
        members: _selectedFriends,
      );

      Navigator.pop(context);

      AnimatedSnackBar.show(
        context,
        message: 'Group "${newGroup.name}" created successfully',
        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.9),
      );
    }
  }
}
