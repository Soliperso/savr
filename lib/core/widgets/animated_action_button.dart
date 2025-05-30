import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:savr/core/theme/app_colors.dart';

class AnimatedActionButton extends StatefulWidget {
  final IconData icon;
  final String? label;
  final VoidCallback onTap;
  final String tooltip;
  final bool showLabel;

  const AnimatedActionButton({
    Key? key,
    required this.icon,
    this.label,
    required this.onTap,
    required this.tooltip,
    this.showLabel = false,
  }) : super(key: key);

  @override
  State<AnimatedActionButton> createState() => _AnimatedActionButtonState();
}

class _AnimatedActionButtonState extends State<AnimatedActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: Padding(
        padding: EdgeInsets.only(right: 8.w),
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(30.r),
              onTap: () {
                _controller.forward().then((_) {
                  _controller.reverse();
                });
                widget.onTap();
              },
              onTapDown: (_) => _controller.forward(),
              onTapCancel: () => _controller.reverse(),
              child: Padding(
                padding:
                    widget.showLabel && widget.label != null
                        ? EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h)
                        : EdgeInsets.all(10.r),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(widget.icon, size: 20.sp, color: AppColors.primary),
                    if (widget.showLabel && widget.label != null) ...[
                      SizedBox(width: 4.w),
                      Text(
                        widget.label!,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color:
                              Theme.of(context).brightness == Brightness.dark
                                  ? AppColors.darkTextPrimary
                                  : AppColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
