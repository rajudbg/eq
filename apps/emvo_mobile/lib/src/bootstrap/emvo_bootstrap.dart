import 'package:flutter/material.dart';
import 'package:emvo_ui/emvo_ui.dart';

/// Shows Emvo-themed UI immediately, then runs [onBootstrapComplete] (Firebase,
/// notifications, etc.) before swapping in the real app — avoids a long white
/// frame when anonymous sign-in is slow on weak networks.
class EmvoAppBootstrap extends StatefulWidget {
  const EmvoAppBootstrap({
    super.key,
    required this.onBootstrapComplete,
    required this.app,
  });

  final Future<void> Function() onBootstrapComplete;
  final Widget app;

  @override
  State<EmvoAppBootstrap> createState() => _EmvoAppBootstrapState();
}

class _EmvoAppBootstrapState extends State<EmvoAppBootstrap> {
  var _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runBootstrap());
  }

  Future<void> _runBootstrap() async {
    try {
      await widget.onBootstrapComplete();
    } catch (e, st) {
      FlutterError.dumpErrorToConsole(
        FlutterErrorDetails(exception: e, stack: st),
      );
    }
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) return widget.app;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: EmvoTheme.lightTheme,
      darkTheme: EmvoTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const _BootstrapSplash(),
    );
  }
}

class _BootstrapSplash extends StatelessWidget {
  const _BootstrapSplash();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: EmvoAmbientBackground(
        child: SafeArea(
          child: Center(
            child: EmvoLoadingPanel(
              message: 'Starting Emvo…',
            ),
          ),
        ),
      ),
    );
  }
}
