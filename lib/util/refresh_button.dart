import 'package:flutter/material.dart';
import 'package:studipassau/constants.dart';

class RefreshIconButton extends StatefulWidget {
  const RefreshIconButton({
    required this.onPressed,
    required this.isLoading,
    super.key,
  });

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  State<RefreshIconButton> createState() => _RefreshIconButtonState();
}

class _RefreshIconButtonState extends State<RefreshIconButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    if (widget.isLoading) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(RefreshIconButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isLoading != oldWidget.isLoading) {
      if (widget.isLoading) {
        _controller.repeat();
      } else {
        _controller.stop();
        _controller.animateTo(1);
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IconButton(
    icon: RotationTransition(
      turns: _controller,
      child: const Icon(Icons.refresh),
    ),
    tooltip: context.i18n.refresh,
    onPressed: widget.isLoading ? null : widget.onPressed,
  );
}
