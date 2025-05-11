import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfilePictureWidget extends StatelessWidget {
  final ImageProvider? imageProvider;
  final bool isUploading;
  final VoidCallback onEdit;
  final Color primaryColor;
  final Color iconColor;
  final String? userName;

  const ProfilePictureWidget({
    Key? key,
    required this.imageProvider,
    required this.isUploading,
    required this.onEdit,
    required this.primaryColor,
    required this.iconColor,
    this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          Semantics(
            label: 'Profile picture',
            child: CircleAvatar(
              radius: 60.r,
              backgroundColor: primaryColor.withOpacity(0.1),
              backgroundImage: imageProvider,
              child:
                  isUploading
                      ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                      )
                      : (imageProvider == null && userName != null)
                      ? Text(
                        userName?.isNotEmpty == true
                            ? userName![0].toUpperCase()
                            : '',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w600,
                          color: primaryColor,
                        ),
                      )
                      : null,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: onEdit,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(Icons.camera_alt, size: 20.sp, color: iconColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
