import 'package:flutter/material.dart';
import '../themes/app_theme.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final Widget? trailing;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null && !isLoading;

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          child: _buildContent(context),
        );
        break;
      case ButtonType.secondary:
        button = ElevatedButton(
          onPressed: isEnabled ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryLight,
            foregroundColor: Colors.white,
          ),
          child: _buildContent(context),
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isEnabled ? onPressed : null,
          child: _buildContent(context),
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isEnabled ? onPressed : null,
          child: _buildContent(context),
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildContent(BuildContext context) {
    if (isLoading) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    final children = <Widget>[];

    if (icon != null) {
      children.add(Icon(icon, size: 20));
      children.add(const SizedBox(width: 8));
    }

    children.add(Text(text));

    if (trailing != null) {
      children.add(const SizedBox(width: 8));
      children.add(trailing!);
    }

    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}
