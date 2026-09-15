import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';

class OtpInput extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<String>? onChanged;
  final bool autofocus;

  const OtpInput({
    super.key,
    this.length = 6,
    required this.onCompleted,
    this.onChanged,
    this.autofocus = true,
  });

  @override
  State<OtpInput> createState() => _OtpInputState();
}

class _OtpInputState extends State<OtpInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  bool _completedFired = false;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());

    for (int i = 0; i < widget.length; i++) {
      _focusNodes[i].addListener(() {
        setState(() {}); // repaint for focus border
      });
    }

    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNodes[0].requestFocus();
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _value => _controllers.map((c) => c.text).join();

  bool get _isComplete => _controllers.every((c) => c.text.isNotEmpty);

  void _notify() {
    final v = _value;
    widget.onChanged?.call(v);

    if (_isComplete && !_completedFired) {
      _completedFired = true;
      widget.onCompleted(v);
    }

    // Allow re-fire if the user clears and re-enters
    if (!_isComplete) {
      _completedFired = false;
    }
  }

  void _handleChange(int index, String value) {
    // Paste of the full code into one box
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'\D'), '');
      for (int i = 0; i < widget.length; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final next = (digits.length - 1).clamp(0, widget.length - 1);
      _focusNodes[next].requestFocus();
      setState(() {});
      _notify();
      return;
    }

    // Advance on digit entry
    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    // Retreat on backspace
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }

    setState(() {});
    _notify();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(widget.length, (i) {
        final focused = _focusNodes[i].hasFocus;
        final filled = _controllers[i].text.isNotEmpty;

        return Container(
          width: 48,
          height: 56,
          margin: EdgeInsets.only(right: i == widget.length - 1 ? 0 : 8),
          decoration: BoxDecoration(
            color: kUzinduziWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: focused
                  ? kUzinduziRed
                  : filled
                      ? kUzinduziBlack.withValues(alpha: 0.4)
                      : kUzinduziDivider,
              width: focused ? 2 : 1,
            ),
          ),
          child: Center(
            child: TextField(
              controller: _controllers[i],
              focusNode: _focusNodes[i],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(widget.length),
              ],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: kUzinduziBlack,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: (v) => _handleChange(i, v),
            ),
          ),
        );
      }),
    );
  }
}