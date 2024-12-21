// 📂 lib/gui/screens/splash_screen.dart

import 'package:flutter/material.dart';
import '../components/logo_widget.dart';

class SplashScreen extends StatefulWidget {
  final Future<void> Function()? onInit;
  final String? loadingText;
  final Widget Function(BuildContext context)? buildBackground;
  final Duration minimumDuration;
  final VoidCallback? onInitComplete;

  const SplashScreen({
    super.key,
    this.onInit,
    this.loadingText,
    this.buildBackground,
    this.minimumDuration = const Duration(seconds: 2),
    this.onInitComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeInAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (widget.onInit != null) {
      try {
        // Ensure minimum splash duration
        await Future.wait([
          widget.onInit!(),
          Future.delayed(widget.minimumDuration),
        ]);
      } catch (e) {
        // Handle initialization error
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error initializing app: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } else {
      await Future.delayed(widget.minimumDuration);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      // Fade out animation
      await _controller.reverse();

      widget.onInitComplete?.call();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Custom background if provided
          if (widget.buildBackground != null)
            widget.buildBackground!(context)
          else
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.primaryContainer,
                  ],
                ),
              ),
            ),

          // Content
          FadeTransition(
            opacity: _fadeInAnimation,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  LogoWidget(
                    variant: LogoVariant.full,
                    theme: LogoTheme.light,
                    width: 150,
                    height: 150,
                    isAnimated: true,
                  ),
                  const SizedBox(height: 32),

                  // Loading indicator
                  if (_isLoading) ...[
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    if (widget.loadingText != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        widget.loadingText!,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}