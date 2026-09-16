import 'package:flutter/material.dart';

import '../core/theme.dart';

class BadgeDot extends StatelessWidget {
  final int count;
  final Widget child;

  const BadgeDot({super.key, required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -2,
          top: -2,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            constraints: const BoxConstraints(minWidth: 16),
            decoration: BoxDecoration(
              color: kUzinduziRed,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: kUzinduziWhite, width: 1.5),
            ),
            child: Text(
              count > 9 ? '9+' : '$count',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}