import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:permission_handler/permission_handler.dart';

/// Widget de scan OCR pour capturer le numéro de reçu
class ReceiptNumberScanner extends StatefulWidget {
  final Function(String) onNumberDetected;
  final RegExp? numberPattern;

  const ReceiptNumberScanner({
    Key? key,
    required this.onNumberDetected,
    this.numberPattern,
  }) : super(key: key);

  @override
  State<ReceiptNumberScanner> createState() => _ReceiptNumberScannerState();
}

class _ReceiptNumberScannerState extends State<ReceiptNumberScanner> {
  CameraController? _cameraController;
  final TextRecognizer _textRecognizer = TextRecognizer();
  bool _isProcessing = false;
  String? _detectedNumber;
  String? _feedbackMessage;

  late RegExp _pattern;

  @override
  void initState() {
    super.initState();
    // Pattern par défaut : 5 à 10 chiffres consécutifs
    _pattern = widget.numberPattern ?? RegExp(r'\b\d{5,10}\b');
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final status = await Permission.camera.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDeniedDialog();
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _showError('Aucune caméra disponible');
        return;
      }

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFocusMode(FocusMode.auto);

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      _showError('Erreur d\'initialisation: $e');
    }
  }

  Future<void> _captureAndProcess() async {
    if (_isProcessing || _cameraController == null) return;

    setState(() {
      _isProcessing = true;
      _feedbackMessage = 'Analyse en cours...';
    });

    try {
      final XFile imageFile = await _cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(imageFile.path);

      final recognizedText = await _textRecognizer.processImage(inputImage);

      // Supprimer le fichier temporaire
      await File(imageFile.path).delete();

      _extractReceiptNumber(recognizedText.text);
    } catch (e) {
      setState(() {
        _feedbackMessage = 'Erreur: ${e.toString()}';
      });
      debugPrint('Erreur capture: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });

      // Effacer le message après 2 secondes si aucun numéro détecté
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _detectedNumber == null) {
          setState(() {
            _feedbackMessage = null;
          });
        }
      });
    }
  }

  void _extractReceiptNumber(String text) {
    debugPrint('Texte reconnu: $text');

    final lines = text.split('\n');

    for (final line in lines) {
      // Nettoyage : supprimer espaces et caractères spéciaux
      final cleaned = line
          .replaceAll(RegExp(r'\s+'), '')
          .replaceAll('O', '0') // Correction O -> 0
          .replaceAll('l', '1') // Correction l -> 1
          .replaceAll('I', '1') // Correction I -> 1
          .replaceAll('S', '5') // Correction S -> 5
          .replaceAll('B', '8') // Correction B -> 8
          .replaceAll(RegExp(r'[^\d]'), ''); // Garder uniquement les chiffres

      // Recherche du pattern exact
      if (_pattern.hasMatch(cleaned)) {
        _onNumberFound(cleaned);
        return;
      }

      // Recherche de séquences numériques
      final matches = RegExp(r'\d{5,10}').allMatches(cleaned);
      for (final match in matches) {
        final candidate = match.group(0)!;
        if (_pattern.hasMatch(candidate)) {
          _onNumberFound(candidate);
          return;
        }
      }
    }

    setState(() {
      _feedbackMessage = 'Numéro non détecté. Réessayez.';
    });
  }

  void _onNumberFound(String number) {
    setState(() {
      _detectedNumber = number;
      _feedbackMessage = 'Numéro détecté !';
    });

    HapticFeedback.mediumImpact();

    // Retourner le numéro après un court délai
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) {
        widget.onNumberDetected(number);
      }
    });
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission requise'),
        content: const Text(
          'L\'accès à la caméra est nécessaire pour scanner les numéros.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Paramètres'),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Aperçu caméra
          CameraPreview(_cameraController!),

          // Overlay avec zone de scan
          CustomPaint(
            painter: ScannerOverlayPainter(
              scanAreaRect: _getScanAreaRect(),
              isDetected: _detectedNumber != null,
            ),
          ),

          // Barre supérieure
          _buildTopBar(),

          // Feedback visuel
          if (_feedbackMessage != null) _buildFeedback(),

          // Instructions
          _buildInstructions(),
        ],
      ),
      floatingActionButton: _detectedNumber == null
          ? FloatingActionButton.extended(
              onPressed: _isProcessing ? null : _captureAndProcess,
              backgroundColor: _isProcessing
                  ? Colors.grey
                  : const Color(0xFF0E8446),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.camera, color: Colors.white),
              label: Text(
                _isProcessing ? 'Analyse...' : 'Scanner',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Rect _getScanAreaRect() {
    final size = MediaQuery.of(context).size;
    const double scanAreaWidth = 300.0;
    const double scanAreaHeight = 120.0;

    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaWidth,
      height: scanAreaHeight,
    );
  }

  Widget _buildTopBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 28),
              onPressed: () => Navigator.pop(context),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'Scanner le numéro',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 48), // Espacement pour équilibrer
          ],
        ),
      ),
    );
  }

  Widget _buildFeedback() {
    final isSuccess = _detectedNumber != null;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 100),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: isSuccess ? const Color(0xFF0E8446) : Colors.orange,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: (isSuccess ? const Color(0xFF0E8446) : Colors.orange)
                      .withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle : Icons.info,
                  color: Colors.white,
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  _feedbackMessage ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (_detectedNumber != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _detectedNumber!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.receipt_long, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Placez le numéro dans le cadre',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              'puis appuyez sur Scanner',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter pour l'overlay du scanner avec zone de scan
class ScannerOverlayPainter extends CustomPainter {
  final Rect scanAreaRect;
  final bool isDetected;

  ScannerOverlayPainter({required this.scanAreaRect, required this.isDetected});

  @override
  void paint(Canvas canvas, Size size) {
    // Zone sombre autour de la zone de scan
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final scanAreaPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(12)),
      );
    final overlayPath = Path.combine(
      PathOperation.difference,
      backgroundPath,
      scanAreaPath,
    );

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withOpacity(0.6),
    );

    // Bordure de la zone de scan
    final borderPaint = Paint()
      ..color = isDetected ? const Color(0xFF0E8446) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    canvas.drawRRect(
      RRect.fromRectAndRadius(scanAreaRect, const Radius.circular(12)),
      borderPaint,
    );

    // Coins décoratifs
    _drawCorners(canvas, scanAreaRect, isDetected);
  }

  void _drawCorners(Canvas canvas, Rect rect, bool detected) {
    final paint = Paint()
      ..color = detected ? const Color(0xFF0E8446) : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round;

    const cornerLength = 24.0;

    // Coin supérieur gauche
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topLeft,
      rect.topLeft + const Offset(0, cornerLength),
      paint,
    );

    // Coin supérieur droit
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.topRight,
      rect.topRight + const Offset(0, cornerLength),
      paint,
    );

    // Coin inférieur gauche
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomLeft,
      rect.bottomLeft + const Offset(0, -cornerLength),
      paint,
    );

    // Coin inférieur droit
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(-cornerLength, 0),
      paint,
    );
    canvas.drawLine(
      rect.bottomRight,
      rect.bottomRight + const Offset(0, -cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(ScannerOverlayPainter oldDelegate) {
    return oldDelegate.isDetected != isDetected;
  }
}
