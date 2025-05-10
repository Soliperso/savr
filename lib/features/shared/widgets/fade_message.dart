import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FadeMessage extends StatefulWidget {
  final String message;
  final Color backgroundColor;
  final Duration duration;
  final VoidCallback? onDismissed;

  const FadeMessage({
    super.key,
    required this.message,
    this.backgroundColor = Colors.black87,
    this.duration = const Duration(seconds: 2),
    this.onDismissed,
  });

  @override
  State<FadeMessage> createState() => _FadeMessageState();
}

class _FadeMessageState extends State<FadeMessage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _opacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismissed?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          widget.message,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14.sp,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
