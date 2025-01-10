import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../services/platform/logo_loader_service.dart';
import '../../models/logo_transform.dart';

class PlatformAwareLogo extends StatefulWidget {
  final String? logoFile;
  final Map<String, dynamic>? logoTransform;
  final double containerSize;
  final Color? backgroundColor;
  final Widget Function()? defaultWidget;
  final LogoLoaderService logoLoader;
  final VoidCallback? onLogoLoaded;
  final VoidCallback? onLogoError;
  final Duration retryDelay;
  final int maxRetries;

  const PlatformAwareLogo({
    Key? key,
    this.logoFile,
    this.logoTransform,
    required this.containerSize,
    this.backgroundColor,
    this.defaultWidget,
    required this.logoLoader,
    this.onLogoLoaded,
    this.onLogoError,
    this.retryDelay = const Duration(seconds: 3),
    this.maxRetries = 3,
  }) : super(key: key);

  @override
  State<PlatformAwareLogo> createState() => _PlatformAwareLogoState();
}

class _PlatformAwareLogoState extends State<PlatformAwareLogo> {
  Uint8List? _logoBytes;
  bool _isLoading = false;
  bool _hasError = false;
  int _retryCount = 0;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    if (widget.logoFile != null) {
      _loadLogo();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  @override
  void didUpdateWidget(PlatformAwareLogo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logoFile != widget.logoFile) {
      _retryCount = 0;
      if (widget.logoFile != null) {
        _loadLogo();
      } else {
        setState(() {
          _logoBytes = null;
          _hasError = false;
        });
      }
    }
  }

  Future<void> _loadLogo() async {
    if (widget.logoFile == null || _isLoading || _disposed) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      final bytes = await widget.logoLoader.loadLogo(widget.logoFile!);

      if (_disposed) return;

      if (bytes != null) {
        setState(() {
          _logoBytes = bytes;
          _isLoading = false;
          _hasError = false;
        });
        widget.onLogoLoaded?.call();
      } else {
        throw Exception('Failed to load logo');
      }
    } catch (e) {
      print('Error loading logo: $e');
      if (_disposed) return;

      setState(() {
        _logoBytes = null;
        _isLoading = false;
        _hasError = true;
      });

      if (_retryCount < widget.maxRetries) {
        _retryCount++;
        Future.delayed(widget.retryDelay, () {
          if (!_disposed) _loadLogo();
        });
      } else {
        widget.onLogoError?.call();
      }
    }
  }

  Widget _buildLogoContent() {
    if (_isLoading) {
      return Center(
        child: SizedBox(
          width: widget.containerSize * 0.3,
          height: widget.containerSize * 0.3,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
          ),
        ),
      );
    }

    if (_logoBytes != null) {
      final cropScreenSize = 200.0;
      final scaleRatio = (widget.containerSize / cropScreenSize) - 0.095;

      final transform = widget.logoTransform != null
          ? LogoTransformData.fromJson(widget.logoTransform!)
          : null;

      return Container(
        width: widget.containerSize,
        height: widget.containerSize,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: transform?.backgroundColor ?? widget.backgroundColor,
        ),
        child: SizedBox.expand(
          child: OverflowBox(
            maxWidth: cropScreenSize,
            maxHeight: cropScreenSize,
            child: Transform.scale(
              scale: scaleRatio * (transform?.scale ?? 1.0),
              child: Transform.translate(
                offset: transform?.position ?? Offset.zero,
                child: Image.memory(
                  _logoBytes!,
                  width: cropScreenSize,
                  height: cropScreenSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error displaying logo: $error');
                    return widget.defaultWidget?.call() ??
                        const Center(child: Icon(Icons.error_outline));
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                _retryCount = 0;
                _loadLogo();
              },
              tooltip: 'Retry loading logo',
            ),
            if (_retryCount > 0)
              Text(
                'Retry ${_retryCount}/${widget.maxRetries}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      );
    }

    return widget.defaultWidget?.call() ??
        const Center(child: Text('No logo'));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _buildLogoContent(),
    );
  }
}