import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

bool _isTablet(BuildContext context) =>
    MediaQuery.of(context).size.shortestSide >= 600;

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const GlassCard({
    required this.child, 
    this.padding, 
    this.margin, 
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final tablet = _isTablet(context);
    final borderRadius = tablet ? BorderRadius.circular(16.0) : BorderRadius.circular(24.r);

    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: padding ?? EdgeInsets.all(tablet ? 16.0 : 16.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: borderRadius,
              border: Border.all(color: Colors.grey.withOpacity(0.15), width: 1.5),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
