import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:inspiria/features/outfit/data/clothing_material/clothing_service.dart';
import 'package:inspiria/routes/router_enum.dart';
import 'package:permission_handler/permission_handler.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isNavigating = false;
  
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_isNavigating) return; 

    final CameraController? cameraController = _controller;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_cameras != null && _cameras!.isNotEmpty) {
        _onNewCameraSelected(_cameras![0]);
      }
    }
  }

  Future<void> _initCamera() async {
    final status = await Permission.camera.request();
    
    if (status.isGranted) {
      if (!mounted) return;
      setState(() {
        _isPermissionGranted = true;
      });

      try {
        _cameras = await availableCameras();
        if (_cameras != null && _cameras!.isNotEmpty) {
          _onNewCameraSelected(_cameras![0]);
        } else {
          debugPrint('No cameras found on device.');
        }
      } catch (e) {
        debugPrint('Error occurred while retrieving cameras: $e');
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  void _onNewCameraSelected(CameraDescription cameraDescription) async {
    final previousCameraController = _controller;
    if (previousCameraController != null) {
      await previousCameraController.dispose();
    }

    final CameraController cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg, 
    );

    if (!mounted) return;
    setState(() {
      _controller = cameraController;
    });

    try {
      await cameraController.initialize();
      await cameraController.setFlashMode(FlashMode.off); 
      
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = _controller!.value.isInitialized;
      });
    } on CameraException catch (e) {
      debugPrint('Erreur init caméra: $e');
    }
  }

  Future<void> _takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) return;
    try {
      final XFile file = await _controller!.takePicture();
      await _handleImageAction(File(file.path));
    } catch (e) {
      debugPrint('Erreur capture: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      await _handleImageAction(File(image.path));
    }
  }

  Future<void> _handleImageAction(File imageFile) async {
    setState(() => _isNavigating = true);

    final aiJson = await ClothingService.analyzeClothingIA(imageFile);

    if (mounted) {
      if (aiJson != null) {
        context.go(SCREEN.SCANNERSUCCESSFULL.path, extra: {
          'imageFile': imageFile,
          'aiData': aiJson,
        });
      } else {
        setState(() => _isNavigating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur lors de l'analyse de l'image")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_isNavigating) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Column(
          children: [
            Text(
              'AI SCANNER',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              height: size.height * 0.40, 
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                color: Colors.grey[200], 
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(30),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_isPermissionGranted && _isCameraInitialized && _controller != null)
                      LayoutBuilder(
                        builder: (context, constraints) {
                          if (_controller == null || !_controller!.value.isInitialized || _controller!.value.previewSize == null) {
                            return const Center(child: CircularProgressIndicator(color: Colors.black));
                          }
                          
                          return SizedBox(
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _controller!.value.previewSize!.height,
                                height: _controller!.value.previewSize!.width,
                                child: CameraPreview(_controller!),
                              ),
                            ),
                          );
                        },
                      )
                    else
                      const Center(child: CircularProgressIndicator(color: Colors.black)),

                    CustomPaint(
                      painter: ScannerOverlayPainter(),
                    ),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 5),
              child: Text(
                'Position Your Item',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Place your clothing item within the frame for AI-powered recognition',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _takePicture, 
                icon: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                label: const Text('CAPTURE & SCAN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 5,
                  shadowColor: Colors.black26,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: ElevatedButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.upload_outlined, color: Colors.black),
                label: const Text('UPLOAD FROM GALLERY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF3F3F3), 
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
class _AddClothingForm extends StatefulWidget {
  const _AddClothingForm({
    required this.imageFile,
    required this.types,
    required this.subTypes,
    required this.scrollController,
    required this.onSubmit,
  });

  final File imageFile;
  final List<String> types;
  final List<String> subTypes;
  final ScrollController scrollController;
  final Function(Map<String, dynamic>) onSubmit;

  @override
  State<_AddClothingForm> createState() => _AddClothingFormState();
}

class _AddClothingFormState extends State<_AddClothingForm> {
  String? selectedType;
  String? selectedSubType;
  final TextEditingController colorController = TextEditingController();

  void _handlePress() {
    if (selectedType == null || selectedSubType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and subcategory.')),
      );
      return;
    }

    final Map<String, dynamic> scannedData = {
      'imageFile': widget.imageFile,
      'category': selectedType,
      'subCategory': selectedSubType,
      'color': colorController.text.isNotEmpty ? colorController.text : 'Unknown',
    };

    widget.onSubmit(scannedData);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      controller: widget.scrollController,
      children: [
        Center(
          child: Container(
            width: 40, height: 5,
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
          ),
        ),
        const Text('New Item Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(widget.imageFile, height: 200, fit: BoxFit.cover),
          ),
        ),
        const SizedBox(height: 24),
        DropdownButtonFormField<String>(
          decoration: _inputDecoration('Category (Type)'),
          value: selectedType, // ignore: deprecated_member_use
          items: widget.types.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (val) => setState(() => selectedType = val),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          decoration: _inputDecoration('Garment Type (Subtype)'),
          value: selectedSubType, // ignore: deprecated_member_use
          isExpanded: true,
          items: widget.subTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
          onChanged: (val) => setState(() => selectedSubType = val),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: colorController,
          decoration: _inputDecoration('Color', icon: Icons.palette_outlined),
        ),
        const SizedBox(height: 32),
        ElevatedButton(
          onPressed: _handlePress,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: const Text('ADD TO CLOSET'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, {IconData? icon}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(width: 1.5)),
      filled: true,
      fillColor: Colors.grey.shade50,
    );
  }
}
class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final double cornerSize = 50.0; 
    final double padding = 30.0;    

    final path = Path();

    path.moveTo(padding, padding + cornerSize);
    path.quadraticBezierTo(padding, padding, padding + cornerSize, padding);

    path.moveTo(size.width - padding - cornerSize, padding);
    path.quadraticBezierTo(size.width - padding, padding, size.width - padding, padding + cornerSize);

    path.moveTo(size.width - padding, size.height - padding - cornerSize);
    path.quadraticBezierTo(size.width - padding, size.height - padding, size.width - padding - cornerSize, size.height - padding);

    path.moveTo(padding + cornerSize, size.height - padding);
    path.quadraticBezierTo(padding, size.height - padding, padding, size.height - padding - cornerSize);

    canvas.drawPath(path, paint);

    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
      
    final glowPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.4)
      ..strokeWidth = 6
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(size.width - padding, size.height / 2),
      glowPaint,
    );
    canvas.drawLine(
      Offset(padding, size.height / 2),
      Offset(size.width - padding, size.height / 2),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}