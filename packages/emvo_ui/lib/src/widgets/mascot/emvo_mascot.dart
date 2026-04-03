import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import 'package:emvo_assets/emvo_assets.dart';

import 'mascot_controller.dart';

class EmvoMascot extends ConsumerStatefulWidget {
  final double size;
  final bool autoPlay;

  const EmvoMascot({
    super.key,
    this.size = 120,
    this.autoPlay = true,
  });

  @override
  ConsumerState<EmvoMascot> createState() => _EmvoMascotState();
}

class _EmvoMascotState extends ConsumerState<EmvoMascot> {
  StateMachineController? _controller;
  SMITrigger? _triggerIdle;
  SMITrigger? _triggerListen;
  SMITrigger? _triggerThink;
  SMITrigger? _triggerHappy;
  SMITrigger? _triggerConcern;
  SMITrigger? _triggerCelebrate;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _onRiveInit(Artboard artboard) {
    _controller = StateMachineController.fromArtboard(
      artboard,
      'State Machine 1', // Default state machine name
    );

    if (_controller != null) {
      artboard.addController(_controller!);

      // Get triggers from state machine
      _triggerIdle = _controller?.findSMI<SMITrigger>('idle');
      _triggerListen = _controller?.findSMI<SMITrigger>('listen');
      _triggerThink = _controller?.findSMI<SMITrigger>('think');
      _triggerHappy = _controller?.findSMI<SMITrigger>('happy');
      _triggerConcern = _controller?.findSMI<SMITrigger>('concern');
      _triggerCelebrate = _controller?.findSMI<SMITrigger>('celebrate');

      // Set initial state
      _triggerIdle?.fire();
    }
  }

  void _updateMascotState(MascotState state) {
    switch (state) {
      case MascotState.idle:
        _triggerIdle?.fire();
        break;
      case MascotState.listening:
        _triggerListen?.fire();
        break;
      case MascotState.thinking:
        _triggerThink?.fire();
        break;
      case MascotState.happy:
        _triggerHappy?.fire();
        break;
      case MascotState.concerned:
        _triggerConcern?.fire();
        break;
      case MascotState.celebrating:
        _triggerCelebrate?.fire();
        break;
      case MascotState.encouraging:
      case MascotState.surprised:
        _triggerIdle?.fire();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<MascotState>(mascotProvider, (_, next) {
      _updateMascotState(next);
    });

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: RiveAnimation.asset(
        EmvoAssets.mascotMain,
        onInit: _onRiveInit,
        fit: BoxFit.contain,
      ),
    );
  }
}

// Simplified mascot for loading states
class EmvoMascotSimple extends StatelessWidget {
  final double size;

  const EmvoMascotSimple({
    super.key,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: const RiveAnimation.asset(
        EmvoAssets.mascotIdle,
        fit: BoxFit.contain,
      ),
    );
  }
}
