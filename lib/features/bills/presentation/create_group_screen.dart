import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../features/shared/widgets/animated_snackbar.dart';
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
  final _memberController = TextEditingController();
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

  // Added color selection feature
  final List<Color> _colorOptions = [
    AppColors.primary,
    AppColors.success,
    AppColors.warningOrange,
    AppColors.expenseRed,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];
  int _selectedColorIndex = 0;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _descFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _memberController.dispose();
    _nameFocus.dispose();
    _descFocus.dispose();
    super.dispose();
  }

  // Helper method to get group initials
  String _getGroupInitials() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return '?';

    final words = name.split(' ');
    if (words.length == 1) {
      return name.isNotEmpty ? name[0].toUpperCase() : '?';
    }

    return '${words[0][0]}${words[1][0]}'.toUpperCase();
  }

  // Helper method to build section headers
  Widget _buildSectionHeader(String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 8.h),
        Divider(color: Colors.grey.withOpacity(0.2), thickness: 1),
        SizedBox(height: 16.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: _colorOptions[_selectedColorIndex].withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 16.sp,
                color: _colorOptions[_selectedColorIndex],
              ),
            ),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
      ],
    );
  }

  // Color picker modal
  void _showColorPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20.w,
                right: 20.w,
                top: 20.h,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40.w,
                    height: 5.h,
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(3.r),
                    ),
                  ),

                  // Title with icon
                  Row(
                    children: [
                      Icon(
                        Icons.palette_outlined,
                        color: _colorOptions[_selectedColorIndex],
                        size: 24.sp,
                      ),
                      SizedBox(width: 10.w),
                      Text(
                        'Choose Group Color',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Toggle between preset colors and color wheel
                  Container(
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.grey[800]?.withOpacity(0.3)
                              : Colors.grey[200]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        // Preset Colors Tab
                        Expanded(
                          child: ElevatedButton(
                            onPressed: null, // Already on this tab
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  isDark ? Colors.grey[700] : Colors.white,
                              foregroundColor:
                                  _colorOptions[_selectedColorIndex],
                              elevation: 2,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.grid_view_rounded,
                                  size: 16.sp,
                                  color: _colorOptions[_selectedColorIndex],
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Presets',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Color Wheel Tab
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              // Close current sheet and open color wheel picker
                              Navigator.pop(context);
                              _showColorWheelPicker(context);
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: Theme.of(context).hintColor,
                              padding: EdgeInsets.symmetric(vertical: 12.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.color_lens_outlined, size: 16.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  'Color Wheel',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Description
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Pick a color that represents your group',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ),

                  SizedBox(height: 20.h),

                  // Section title
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: EdgeInsets.only(bottom: 12.h),
                    child: Text(
                      'Preset Colors',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),

                  // Color options grid with preview
                  Wrap(
                    spacing: 16.w,
                    runSpacing: 22.h,
                    alignment: WrapAlignment.center,
                    children: List.generate(
                      _colorOptions.length,
                      (index) => GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          setState(() {
                            _selectedColorIndex = index;
                          });
                          // Update preview immediately
                          Future.delayed(const Duration(milliseconds: 100), () {
                            setState(
                              () {},
                            ); // Trigger a rebuild for smoother animation
                          });
                        },
                        child: Column(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 62.w,
                              height: 62.h,
                              decoration: BoxDecoration(
                                color: _colorOptions[index],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      _selectedColorIndex == index
                                          ? Colors.white
                                          : Colors.transparent,
                                  width: _selectedColorIndex == index ? 4 : 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _colorOptions[index].withOpacity(
                                      _selectedColorIndex == index ? 0.5 : 0.3,
                                    ),
                                    blurRadius:
                                        _selectedColorIndex == index ? 12 : 8,
                                    spreadRadius:
                                        _selectedColorIndex == index ? 2 : 1,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_selectedColorIndex == index)
                                    Container(
                                      width: 62.w,
                                      height: 62.h,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: RadialGradient(
                                          colors: [
                                            Colors.white.withOpacity(0.0),
                                            Colors.white.withOpacity(0.3),
                                          ],
                                          stops: const [0.6, 1.0],
                                        ),
                                      ),
                                    ),
                                  if (_selectedColorIndex == index)
                                    Icon(
                                      Icons.check_rounded,
                                      color: Colors.white,
                                      size: 32.sp,
                                      weight: 700,
                                    ),
                                ],
                              ),
                            ),
                            SizedBox(height: 6.h),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: 8.w,
                              height: 8.h,
                              decoration: BoxDecoration(
                                color:
                                    _selectedColorIndex == index
                                        ? _colorOptions[index]
                                        : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Preview and apply button
                  SizedBox(height: 32.h),
                  Row(
                    children: [
                      // Preview
                      Container(
                        width: 50.w,
                        height: 50.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _colorOptions[_selectedColorIndex],
                              _colorOptions[_selectedColorIndex].withOpacity(
                                0.8,
                              ),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _colorOptions[_selectedColorIndex]
                                  .withOpacity(0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            _getGroupInitials(),
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 16.w),

                      // Apply button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _colorOptions[_selectedColorIndex],
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14.r),
                            ),
                          ),
                          child: Text(
                            'Apply Color',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ),
    );
  }

  // Color wheel picker modal
  void _showColorWheelPicker(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color pickerColor = _colorOptions[_selectedColorIndex];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? Colors.grey[850] : Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20.w,
                right: 20.w,
                top: 20.h,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40.w,
                      height: 5.h,
                      margin: EdgeInsets.only(bottom: 16.h),
                      decoration: BoxDecoration(
                        color: Colors.grey[400],
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                    ),

                    // Title with icon
                    Row(
                      children: [
                        Icon(
                          Icons.palette_outlined,
                          color: pickerColor,
                          size: 24.sp,
                        ),
                        SizedBox(width: 10.w),
                        Text(
                          'Choose Group Color',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Toggle between preset colors and color wheel
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.grey[800]?.withOpacity(0.3)
                                : Colors.grey[200]?.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 3,
                            spreadRadius: 0,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 4.w,
                        vertical: 4.h,
                      ),
                      child: Row(
                        children: [
                          // Preset Colors Tab
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                // Close current sheet and open preset color picker
                                Navigator.pop(context);
                                _showColorPicker(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(context).hintColor,
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.grid_view_rounded, size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Presets',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Color Wheel Tab (Active)
                          Expanded(
                            child: AnimatedContainer(
                              duration: Duration(milliseconds: 200),
                              child: ElevatedButton(
                                onPressed: null, // Already on this tab
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      isDark ? Colors.grey[700] : Colors.white,
                                  foregroundColor: pickerColor,
                                  elevation: 2,
                                  shadowColor: pickerColor.withOpacity(0.3),
                                  padding: EdgeInsets.symmetric(vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.color_lens_outlined,
                                      size: 16.sp,
                                      color: pickerColor,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Color Wheel',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Pick a color that represents your group',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Section title
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        'Custom Color',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),

                    // Color wheel picker in a nice card
                    Container(
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.grey[800]?.withOpacity(0.3)
                                : Colors.grey[100]?.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      padding: EdgeInsets.all(16.w),
                      child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: (color) {
                          pickerColor = color;
                          setState(() {}); // Rebuild UI to update preview
                        },
                        enableAlpha: false,
                        labelTypes: const [],
                        displayThumbColor: true,
                        portraitOnly: true,
                        colorPickerWidth: 300.w,
                        pickerAreaHeightPercent: 0.7,
                        hexInputBar: true,
                        pickerAreaBorderRadius: BorderRadius.circular(12.r),
                      ),
                    ),

                    // Recent colors
                    SizedBox(height: 24.h),
                    Container(
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: Text(
                        'Preset Colors',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(14.w),
                      decoration: BoxDecoration(
                        color:
                            isDark
                                ? Colors.grey[800]?.withOpacity(0.3)
                                : Colors.grey[100]?.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          width: 1,
                        ),
                      ),
                      child: Wrap(
                        spacing: 10.w,
                        runSpacing: 10.w,
                        alignment: WrapAlignment.spaceEvenly,
                        children: List.generate(
                          _colorOptions.length,
                          (index) => GestureDetector(
                            onTap: () {
                              pickerColor = _colorOptions[index];
                              // Rebuild color picker with new color
                              setState(() {});
                            },
                            child: Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                color: _colorOptions[index],
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color:
                                      pickerColor == _colorOptions[index]
                                          ? Colors.white
                                          : Colors.transparent,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: _colorOptions[index].withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 4,
                                    spreadRadius: 1,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child:
                                  pickerColor == _colorOptions[index]
                                      ? Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 24.sp,
                                      )
                                      : null,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Preview and apply button
                    SizedBox(height: 24.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 20.h,
                        horizontal: 16.w,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            pickerColor.withOpacity(0.15),
                            pickerColor.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(15.r),
                        border: Border.all(
                          color: pickerColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: pickerColor.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 0,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // Preview
                          Column(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                width: 64.w,
                                height: 64.h,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      pickerColor,
                                      pickerColor.withOpacity(0.8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: pickerColor.withOpacity(0.4),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    _getGroupInitials(),
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 22.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black26,
                                          blurRadius: 2,
                                          offset: Offset(0, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                'Preview',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                  color: Theme.of(context).hintColor,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 20.w),

                          // Apply button
                          Expanded(
                            child: SizedBox(
                              height: 55.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    // Find closest color in _colorOptions or add new color
                                    int closestIndex = 0;
                                    double minDifference = double.infinity;

                                    for (
                                      int i = 0;
                                      i < _colorOptions.length;
                                      i++
                                    ) {
                                      final diff = _calculateColorDifference(
                                        _colorOptions[i],
                                        pickerColor,
                                      );
                                      if (diff < minDifference) {
                                        minDifference = diff;
                                        closestIndex = i;
                                      }
                                    }

                                    // If color is very close to an existing one, use that index
                                    // Otherwise, replace the last color with the new one
                                    if (minDifference < 50) {
                                      _selectedColorIndex = closestIndex;
                                    } else {
                                      // Replace the last color with the custom color
                                      _colorOptions[_colorOptions.length - 1] =
                                          pickerColor;
                                      _selectedColorIndex =
                                          _colorOptions.length - 1;
                                    }
                                  });
                                  Navigator.pop(context);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pickerColor,
                                  foregroundColor: Colors.white,
                                  elevation: 3,
                                  shadowColor: pickerColor.withOpacity(0.5),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline,
                                      size: 18.sp,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Apply Color',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  // Helper method to calculate color difference (using simple RGB distance)
  double _calculateColorDifference(Color a, Color b) {
    return math.sqrt(
      math.pow(a.red - b.red, 2) +
          math.pow(a.green - b.green, 2) +
          math.pow(a.blue - b.blue, 2),
    );
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
                  title: const Text('Choose from Gallery'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatarFromSource(ImageSource.gallery);
                  },
                ),
                Divider(height: 1, color: Colors.grey[300]),
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take a Photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickAvatarFromSource(ImageSource.camera);
                  },
                ),
                if (_avatarFile != null) ...[
                  Divider(height: 1, color: Colors.grey[300]),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      setState(() => _avatarFile = null);
                      Navigator.pop(context);
                    },
                  ),
                ],
                SizedBox(height: 8.h),
              ],
            ),
          ),
    );
  }

  void _addMember() {
    final member = _memberController.text.trim();
    if (member.isEmpty) {
      return;
    }

    if (!_selectedFriends.contains(member)) {
      setState(() {
        _selectedFriends.add(member);
        _memberController.clear();
      });
      FocusScope.of(context).requestFocus(FocusNode());
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$member is already in the group'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      );
    }
  }

  void _removeMember(int index) {
    if (index >= 0 && index < _selectedFriends.length) {
      final removedMember = _selectedFriends[index];
      setState(() {
        _selectedFriends.removeAt(index);
      });

      // Show undo snackbar
      final snackBar = SnackBar(
        content: Text('Removed $removedMember'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            setState(() {
              _selectedFriends.insert(index, removedMember);
            });
          },
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // Handle create group
  void _handleCreateGroup() async {
    FocusScope.of(context).unfocus();
    if (_formKey.currentState!.validate()) {
      if (_selectedFriends.isEmpty) {
        AnimatedSnackBar.show(
          context,
          message: 'Please add at least one member',
          backgroundColor: Colors.red.withOpacity(0.9),
        );
        return;
      }
      setState(() => _isLoading = true);

      try {
        final billProvider = Provider.of<BillProvider>(context, listen: false);
        await billProvider.createGroup(
          name: _nameController.text,
          description:
              _descriptionController.text.isEmpty
                  ? '-'
                  : _descriptionController.text,
          members: _selectedFriends,
          avatarFile: _avatarFile,
        );

        if (mounted) {
          Navigator.pop(context);
          AnimatedSnackBar.show(
            context,
            message: 'Group created successfully',
            backgroundColor: _colorOptions[_selectedColorIndex].withOpacity(
              0.9,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating group: ${e.toString()}')),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = _colorOptions[_selectedColorIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Create New Group',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_rounded, size: 20.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Introduction Card
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primaryColor.withOpacity(0.15),
                        primaryColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: primaryColor.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.people_rounded,
                          size: 32.sp,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4.h),
                            Text(
                              'Add friends or family to split bills and track expenses together',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13.sp,
                                height: 1.4,
                                color: Theme.of(context).hintColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Group info section
                _buildSectionHeader('Group Information', Icons.info_outline),

                // Group Icon Preview with color selection
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]?.withOpacity(0.5)
                            : Colors.grey[50]?.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]!
                              : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Material(
                          elevation: 4,
                          shadowColor: primaryColor.withOpacity(0.4),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: () => _showColorPicker(context),
                            borderRadius: BorderRadius.circular(50.r),
                            splashColor: primaryColor.withOpacity(0.2),
                            highlightColor: primaryColor.withOpacity(0.1),
                            child: Stack(
                              children: [
                                Container(
                                  width: 92.w,
                                  height: 92.h,
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    shape: BoxShape.circle,
                                    gradient: LinearGradient(
                                      colors: [
                                        primaryColor,
                                        primaryColor.withOpacity(0.85),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: primaryColor.withOpacity(0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child:
                                        _avatarFile == null
                                            ? Text(
                                              _getGroupInitials(),
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 32.sp,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white,
                                                letterSpacing: -0.5,
                                              ),
                                            )
                                            : const SizedBox(),
                                  ),
                                ),
                                if (_avatarFile != null)
                                  Container(
                                    width: 92.w,
                                    height: 92.h,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                        image: FileImage(_avatarFile!),
                                        fit: BoxFit.cover,
                                      ),
                                      border: Border.all(
                                        color: primaryColor,
                                        width: 3,
                                      ),
                                    ),
                                  ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: InkWell(
                                    onTap: _showAvatarSourceSheet,
                                    child: Container(
                                      padding: EdgeInsets.all(8.w),
                                      decoration: BoxDecoration(
                                        color: primaryColor,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.2,
                                            ),
                                            blurRadius: 4,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _avatarFile != null
                                            ? Icons.edit
                                            : Icons.camera_alt,
                                        color: Colors.white,
                                        size: 16.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Preset colors button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showColorPicker(context),
                                icon: Icon(Icons.palette_outlined, size: 16.sp),
                                label: Text(
                                  'Preset Colors',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(
                                    color: primaryColor.withOpacity(0.5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.h,
                                    horizontal: 10.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 12.w),
                            // Color wheel button
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _showColorWheelPicker(context),
                                icon: Icon(
                                  Icons.color_lens_outlined,
                                  size: 16.sp,
                                ),
                                label: Text(
                                  'Color Wheel',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: primaryColor,
                                  side: BorderSide(
                                    color: primaryColor.withOpacity(0.5),
                                  ),
                                  padding: EdgeInsets.symmetric(
                                    vertical: 10.h,
                                    horizontal: 10.w,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Form fields section
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.only(bottom: 16.h),
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey[850]?.withOpacity(0.5)
                            : Colors.grey[50]?.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.grey[800]!
                              : Colors.grey[200]!,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Group name field
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        autofocus: true,
                        maxLength: 30,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Group Name',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray,
                          ),
                          hintText: 'e.g. Roommates, Family, Trip to Paris',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: Theme.of(context).hintColor.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.group,
                            size: 18.sp,
                            color: AppColors.gray,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]?.withOpacity(0.3)
                                  : Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          suffixIcon:
                              _nameController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed:
                                        () => setState(
                                          () => _nameController.clear(),
                                        ),
                                    tooltip: 'Clear',
                                  )
                                  : null,
                          counterText: '',
                          helperText: 'Max 30 characters',
                          helperStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.sp,
                            color: AppColors.grayLight,
                          ),
                        ),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp),
                        textInputAction: TextInputAction.next,
                        onFieldSubmitted:
                            (_) =>
                                FocusScope.of(context).requestFocus(_descFocus),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a group name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.h),

                      // Description field
                      TextFormField(
                        controller: _descriptionController,
                        focusNode: _descFocus,
                        maxLength: 60,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray,
                          ),
                          hintText: 'Add a short description about this group',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: Theme.of(context).hintColor.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.description,
                            size: 18.sp,
                            color: AppColors.gray,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: BorderSide(
                              color: primaryColor,
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey[800]?.withOpacity(0.3)
                                  : Colors.grey[50],
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          counterText: '',
                          helperText: 'Max 60 characters',
                          helperStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.sp,
                            color: AppColors.grayLight,
                          ),
                          suffixIcon:
                              _descriptionController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(Icons.clear),
                                    onPressed:
                                        () => setState(
                                          () => _descriptionController.clear(),
                                        ),
                                    tooltip: 'Clear',
                                  )
                                  : null,
                        ),
                        style: TextStyle(fontFamily: 'Inter', fontSize: 15.sp),
                        maxLines: 2,
                        textInputAction: TextInputAction.done,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),

                // Members section
                _buildSectionHeader('Add Members', Icons.person_add),
                Text(
                  'Select friends to add to this group',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13.sp,
                    fontStyle: FontStyle.italic,
                    color: AppColors.grayLight,
                  ),
                ),
                SizedBox(height: 16.h),

                // Member input field
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _memberController,
                        decoration: InputDecoration(
                          labelText: 'Member Email or Name',
                          labelStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.gray,
                          ),
                          hintText: 'Enter email or name',
                          hintStyle: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.sp,
                            color: Theme.of(context).hintColor.withOpacity(0.6),
                          ),
                          prefixIcon: Icon(
                            Icons.person,
                            size: 18.sp,
                            color: AppColors.gray,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 14.h,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    SizedBox(
                      height: 56.h,
                      child: ElevatedButton(
                        onPressed: _addMember,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16.w),
                        ),
                        child: Icon(Icons.add),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),

                // Available friends list
                ...(_availableFriends.isNotEmpty
                    ? [
                      Text(
                        'Suggested',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).hintColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      // Simplified Chips
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children:
                              _availableFriends.map((friend) {
                                final isSelected = _selectedFriends.contains(
                                  friend,
                                );
                                return FilterChip(
                                  selected: isSelected,
                                  avatar: CircleAvatar(
                                    backgroundColor:
                                        isSelected
                                            ? _colorOptions[_selectedColorIndex]
                                            : Colors.grey[400],
                                    child: Text(
                                      friend[0],
                                      style: TextStyle(
                                        color:
                                            isSelected
                                                ? Colors.white
                                                : Colors.black,
                                        fontSize: 12.sp,
                                      ),
                                    ),
                                  ),
                                  label: Text(friend),
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
                                  selectedColor:
                                      _colorOptions[_selectedColorIndex]
                                          .withOpacity(0.2),
                                );
                              }).toList(),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ]
                    : []),

                // Selected members list
                if (_selectedFriends.isNotEmpty) ...[
                  Text(
                    'Members (${_selectedFriends.length})',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color:
                            isDark
                                ? Colors.grey[700]!
                                : Colors.grey.withOpacity(0.2),
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: ListView.separated(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _selectedFriends.length,
                      separatorBuilder: (context, index) => Divider(height: 1),
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: primaryColor.withOpacity(0.2),
                            child: Text(
                              _selectedFriends[index][0].toUpperCase(),
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(_selectedFriends[index]),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.remove_circle_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _removeMember(index),
                          ),
                        );
                      },
                    ),
                  ),
                ] else ...[
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 16.h),
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color:
                          isDark
                              ? Colors.grey[800]!.withOpacity(0.2)
                              : Colors.grey[100]!.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48.sp,
                            color: Theme.of(context).hintColor.withOpacity(0.5),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            'No members added yet',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          Text(
                            'Add members to split bills with',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).hintColor.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                SizedBox(height: 32.h),

                // Create group button
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleCreateGroup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child:
                        _isLoading
                            ? SizedBox(
                              width: 24.w,
                              height: 24.h,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Text(
                              'Create Group',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
