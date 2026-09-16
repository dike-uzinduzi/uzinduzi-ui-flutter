import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme.dart';
import '../../albums/album_models.dart';

class LaunchCountdown extends StatefulWidget {
  final AlbumLaunch launch;
  final bool dark;

  const LaunchCountdown({super.key, required this.launch, this.dark = false});

  @override
  State<LaunchCountdown> createState() => _LaunchCountdownState();
}

class _LaunchCountdownState extends State<LaunchCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

String _format(Duration d) {
  if (d.inSeconds <= 0) return 'closed';
  if (d.inDays >= 1) {
    final days = d.inDays;
    final hours = d.inHours % 24;
    final mins = d.inMinutes % 60;
    return '${days}d ${hours}h ${mins}m left';
  }
  if (d.inHours >= 1) {
    final hours = d.inHours;
    final mins = d.inMinutes % 60;
    return '${hours}h ${mins}m left';
  }
  if (d.inMinutes >= 1) {
    return '${d.inMinutes}m ${d.inSeconds % 60}s left';
  }
  return '${d.inSeconds}s left';
}

  @override
  Widget build(BuildContext context) {
    final remaining = widget.launch.remaining;
    final live = widget.launch.isActive;
    final endingSoon = live && remaining.inHours < 24;

    final dotColor = !live
        ? kUzinduziGrey
        : endingSoon
            ? kStatusScheduled
            : kStatusLive;

    final label = !live
        ? 'ENDED'
        : endingSoon
            ? 'ENDING SOON'
            : 'LIVE';

    final textColor = widget.dark ? Colors.white : kUzinduziBlack;
    final subtleColor = widget.dark ? Colors.white70 : kUzinduziGrey;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.circle, size: 8, color: dotColor),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: dotColor,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(width: 10),
        Text('•', style: TextStyle(color: subtleColor)),
        const SizedBox(width: 10),
        Text(
          _format(remaining),
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor),
        ),
      ],
    );
  }
}