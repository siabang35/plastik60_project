import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;

  const SectionHeader({super.key, required this.title, this.onSeeAllPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        if (onSeeAllPressed != null)
          TextButton(onPressed: onSeeAllPressed, child: const Text('See All')),
      ],
    );
  }
}
