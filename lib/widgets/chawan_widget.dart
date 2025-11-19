import 'package:flutter/material.dart';
import 'package:rive/rive.dart';

class ChawanWidget extends StatefulWidget {
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ChawanWidget({
    super.key,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  State<ChawanWidget> createState() => _ChawanWidgetState();
}

class _ChawanWidgetState extends State<ChawanWidget> {
  StateMachineController? _controller;
  SMIInput<bool>? _tapInput;
  SMIInput<bool>? _grabInput;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _tapInput?.value = true;
        Future.delayed(const Duration(milliseconds: 300), () {
          _tapInput?.value = false;
        });
        widget.onTap();
      },
      onLongPress: () {
        _grabInput?.value = true;
        widget.onLongPress();
      },
      child: SizedBox(
        width: 280,
        height: 280,
        child: RiveAnimation.asset(
          'assets/rive/chawan.riv',
          fit: BoxFit.contain,
          stateMachines: const ['Motion'],
          onInit: (artboard) {
            _controller = StateMachineController.fromArtboard(artboard, 'Motion');
            if (_controller != null) {
              artboard.addController(_controller!);
              _tapInput = _controller!.findInput<bool>('tap');
              _grabInput = _controller!.findInput<bool>('grab');
            }
          },
        ),
      ),
    );
  }
}