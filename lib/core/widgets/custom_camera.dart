import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CustomCameraPage extends StatefulWidget {
  final double rectWidthRatio;
  final double rectHeightRatio;
  final double borderRadius;
  const CustomCameraPage({
    super.key,
    this.rectWidthRatio = 0.85,
    this.rectHeightRatio = 0.75,
    this.borderRadius = 16,
  });

  @override
  State<CustomCameraPage> createState() => _CustomCameraPageState();
}

class _CustomCameraPageState extends State<CustomCameraPage> {
  CameraController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _controller!.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint("Erreur caméra: $e");
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(_controller!),
          // On applique notre calque de guidage
          CustomPaint(
            painter: CameraOverlayPainter(
              rectWidthRatio: widget.rectWidthRatio,
              rectHeightRatio: widget.rectHeightRatio,
              borderRadius: widget.borderRadius,
            ),
          ),
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                onPressed: () async {
                  final image = await _controller!.takePicture();
                  if (mounted) Navigator.pop(context, image);
                },
                child: const Icon(Icons.camera_alt, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CameraOverlayPainter extends CustomPainter {
  final double rectWidthRatio;
  final double rectHeightRatio;
  final double borderRadius;

  CameraOverlayPainter({
    required this.rectWidthRatio,
    required this.rectHeightRatio,
    this.borderRadius = 12,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black54;

    final rectWidth = size.width * rectWidthRatio;
    final rectHeight = size.height * rectHeightRatio;

    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: rectWidth,
      height: rectHeight,
    );

    // Overlay avec trou
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
        ),
      ),
      paint,
    );

    // Bordure
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(borderRadius)),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CameraOverlayPainter oldDelegate) {
    return rectWidthRatio != oldDelegate.rectWidthRatio ||
        rectHeightRatio != oldDelegate.rectHeightRatio ||
        borderRadius != oldDelegate.borderRadius;
  }
}
