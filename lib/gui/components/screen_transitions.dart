// 📂 lib/gui/components/screen_transitions.dart

import 'package:flutter/material.dart';

enum TransitionType {
  fade,
  slide,
  scale,
  rotation,
  size,
}

class AppPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;
  final TransitionType transitionType;
  final Duration duration;
  final Duration reverseDuration;
  final Curve curve;
  final Curve reverseCurve;
  final bool fullscreenDialog;

  AppPageRoute({
    required this.page,
    this.transitionType = TransitionType.fade,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    this.reverseCurve = Curves.easeInOut,
    this.fullscreenDialog = false,
    RouteSettings? settings,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      switch (transitionType) {
        case TransitionType.fade:
          return FadeTransition(
            opacity: animation,
            child: child,
          );

        case TransitionType.slide:
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );

        case TransitionType.scale:
          return ScaleTransition(
            scale: animation,
            child: child,
          );

        case TransitionType.rotation:
          return RotationTransition(
            turns: animation,
            child: child,
          );

        case TransitionType.size:
          return SizeTransition(
            sizeFactor: animation,
            child: child,
          );
      }
    },
    transitionDuration: duration,
    reverseTransitionDuration: reverseDuration,
    settings: settings,
    fullscreenDialog: fullscreenDialog,
  );
}

class FadeIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final Duration duration;
  final AlignmentGeometry alignment;
  final TextDirection? textDirection;
  final StackFit sizing;

  const FadeIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
  });

  @override
  State<FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<FadeIndexedStack> {
  late int oldIndex;

  @override
  void initState() {
    super.initState();
    oldIndex = widget.index;
  }

  @override
  void didUpdateWidget(FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      setState(() {
        oldIndex = oldWidget.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: widget.duration,
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: IndexedStack(
            index: widget.index,
            alignment: widget.alignment,
            textDirection: widget.textDirection,
            sizing: widget.sizing,
            children: widget.children,
          ),
        );
      },
    );
  }
}

class SlideRoute extends PageRouteBuilder {
  final Widget page;
  final AxisDirection direction;

  SlideRoute({
    required this.page,
    this.direction = AxisDirection.right,
  }) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      Offset begin;
      switch (direction) {
        case AxisDirection.up:
          begin = const Offset(0.0, 1.0);
          break;
        case AxisDirection.right:
          begin = const Offset(-1.0, 0.0);
          break;
        case AxisDirection.down:
          begin = const Offset(0.0, -1.0);
          break;
        case AxisDirection.left:
          begin = const Offset(1.0, 0.0);
          break;
      }

      return SlideTransition(
        position: Tween<Offset>(
          begin: begin,
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeInOut,
        )),
        child: child,
      );
    },
  );
}