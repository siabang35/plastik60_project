import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;
  final IconData? icon;
  

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50,
    this.borderRadius = 8,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      height: height,
      child:
          isOutlined
              ? OutlinedButton(
                onPressed: isLoading ? null : onPressed,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: backgroundColor ?? theme.primaryColor,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: _buildChild(context),
              )
              : ElevatedButton(
                onPressed: isLoading ? null : onPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: backgroundColor ?? theme.primaryColor,
                  foregroundColor: textColor ?? Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(borderRadius),
                  ),
                ),
                child: _buildChild(context),
              ),
    );
  }

  Widget _buildChild(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Icon(icon, size: 18), const SizedBox(width: 8), Text(text)],
      );
    }

    return Text(text);
  }
}
