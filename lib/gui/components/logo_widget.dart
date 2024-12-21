// 📂 lib/gui/components/logo_widget.dart

import 'package:flutter/material.dart';

enum LogoVariant {
  full,     // Full logo with text
  icon,     // Icon only
  text      // Text only
}

enum LogoTheme {
  light,    // Light theme version
  dark,     // Dark theme version
  colored   // Full color version
}

class LogoWidget extends StatelessWidget {
  final LogoVariant variant;
  final LogoTheme theme;
  final double? width;
  final double? height;
  final BoxFit fit;
  final bool isAnimated;
  final Duration animationDuration;
  final VoidCallback? onTap;
  final String? semanticsLabel;

  const LogoWidget({
    super.key,
    this.variant = LogoVariant.full,
    this.theme = LogoTheme.colored,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.isAnimated = false,
    this.animationDuration = const Duration(milliseconds: 300),
    this.onTap,
    this.semanticsLabel,
  });

  String _getAssetPath() {
    final variantPath = variant == LogoVariant.full
        ? 'full'
        : variant == LogoVariant.icon
        ? 'icon'
        : 'text';

    final themePath = theme == LogoTheme.light
        ? 'light'
        : theme == LogoTheme.dark
        ? 'dark'
        : 'colored';

    return 'assets/logo_${variantPath}_$themePath.png';
  }

  @override
  Widget build(BuildContext context) {
    Widget logo = Image.asset(
      _getAssetPath(),
      width: width,
      height: height,
      fit: fit,
      semanticLabel: semanticsLabel,
      errorBuilder: (context, error, stackTrace) {
        // Fallback text if image fails to load
        return SizedBox(
          width: width,
          height: height,
          child: Center(
            child: Text(
              'Logo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: theme == LogoTheme.light
                    ? Colors.white
                    : theme == LogoTheme.dark
                    ? Colors.black
                    : null,
              ),
            ),
          ),
        );
      },
    );

    // Add animation if requested
    if (isAnimated) {
      logo = TweenAnimationBuilder<double>(
        duration: animationDuration,
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Opacity(
            opacity: value,
            child: Transform.scale(
              scale: 0.8 + (value * 0.2),
              child: child,
            ),
          );
        },
        child: logo,
      );
    }

    // Add tap handler if provided
    if (onTap != null) {
      logo = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: logo,
        ),
      );
    }

    return logo;
  }
}

class AnimatedLogoWidget extends StatefulWidget {
  final LogoVariant variant;
  final LogoTheme theme;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Duration animationDuration;
  final VoidCallback? onAnimationComplete;
  final String? semanticsLabel;

  const AnimatedLogoWidget({
    super.key,
    this.variant = LogoVariant.full,
    this.theme = LogoTheme.colored,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.onAnimationComplete,
    this.semanticsLabel,
  });

  @override
  State<AnimatedLogoWidget> createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeIn,
      ),
    );

    _controller.forward().then((_) {
      widget.onAnimationComplete?.call();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: LogoWidget(
              variant: widget.variant,
              theme: widget.theme,
              width: widget.width,
              height: widget.height,
              fit: widget.fit,
              semanticsLabel: widget.semanticsLabel,
            ),
          ),
        );
      },
    );
  }
}