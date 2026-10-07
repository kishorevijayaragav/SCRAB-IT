import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../providers/scan_provider.dart';
import '../../widgets/scrap_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/scanning_overlay.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  late AnimationController _animController;
  late Animation<double> _scanLineAnimation;

  @override
  void initState() {
    super.initState();
    _initScannerAnimation();
    _initCamera();
  }

  void _initScannerAnimation() {
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
    _scanLineAnimation = Tween<double>(begin: 0.1, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras.isNotEmpty) {
        // Choose back camera
        final backCam = _cameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _cameras.first,
        );

        _cameraController = CameraController(
          backCam,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();
        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (_) {
      // Camera not available (e.g. desktop/emulator without virtual camera)
      if (mounted) {
        setState(() {
          _isCameraInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    try {
      if (_isFlashOn) {
        await _cameraController!.setFlashMode(FlashMode.off);
        setState(() => _isFlashOn = false);
      } else {
        await _cameraController!.setFlashMode(FlashMode.torch);
        setState(() => _isFlashOn = true);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flash is not available on this device')),
      );
    }
  }

  Future<void> _capturePhoto() async {
    final scan = context.read<ScanProvider>();
    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final xfile = await _cameraController!.takePicture();
        scan.setSelectedFile(xfile);
        return;
      } catch (_) {}
    }
    // Fallback to image picker camera
    await scan.pickImage(ImageSource.camera);
  }

  Future<void> _pickGallery() async {
    final scan = context.read<ScanProvider>();
    await scan.pickImage(ImageSource.gallery);
  }

  Future<void> _runAnalysis() async {
    final scan = context.read<ScanProvider>();
    final result = await scan.analyze();
    if (!mounted) return;
    if (result != null) {
      context.push('/results');
    } else if (scan.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(scan.errorMessage!),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scan = context.watch<ScanProvider>();

    return Scaffold(
      appBar: const ScrapAppBar(
        title: 'AI Scanner',
        subtitle: 'Capture or upload scrap for AI identification',
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Live Viewfinder Shell
                _buildCameraShell(scan),
                const SizedBox(height: 16),

                // Upload Box
                _buildUploadBox(scan),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Analysis Loading Overlay
          if (scan.isAnalyzing)
            ScanningOverlay(
              currentStep: scan.currentStep,
              progress: scan.analysisProgress,
              fileName: scan.selectedFile?.name ?? 'image.jpg',
            ),
        ],
      ),
    );
  }

  Widget _buildCameraShell(ScanProvider scan) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E17),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Top pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Live Camera',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.greenLight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: AppColors.green.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isCameraInitialized ? 'Camera active · Ready' : 'AI Scanner · Ready',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Viewfinder View
          Container(
            height: 320,
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFF05110B),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Live Camera or Brand Placeholder
                if (_isCameraInitialized && _cameraController != null)
                  Positioned.fill(
                    child: AspectRatio(
                      aspectRatio: _cameraController!.value.aspectRatio,
                      child: CameraPreview(_cameraController!),
                    ),
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Image.asset(
                          'assets/images/logo-mark.png',
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.camera_alt_outlined,
                            size: 32,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Point camera at scrap material\nor pick an image below',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.65),
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),

                // Corner Reticles Frame
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Stack(
                      children: [
                        _buildCorner(top: 0, left: 0, borderTop: true, borderLeft: true),
                        _buildCorner(top: 0, right: 0, borderTop: true, borderRight: true),
                        _buildCorner(bottom: 0, left: 0, borderBottom: true, borderLeft: true),
                        _buildCorner(bottom: 0, right: 0, borderBottom: true, borderRight: true),

                        // Animated Sweeping Laser Line
                        AnimatedBuilder(
                          animation: _scanLineAnimation,
                          builder: (context, child) {
                            return Align(
                              alignment: Alignment(0, (_scanLineAnimation.value * 2) - 1),
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      AppColors.green.withValues(alpha: 0.9),
                                      Colors.white,
                                      AppColors.green.withValues(alpha: 0.9),
                                      Colors.transparent,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.green.withValues(alpha: 0.6),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Place scrap item inside the frame',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 11.5,
            ),
          ),
          const SizedBox(height: 16),

          // Controls Row (Gallery, Shutter, Flash)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: _pickGallery,
              ),
              // Big Shutter Button
              GestureDetector(
                onTap: _capturePhoto,
                child: Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3.5),
                  ),
                  child: Center(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 26),
                    ),
                  ),
                ),
              ),
              _buildControlButton(
                icon: _isFlashOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                label: 'Flash',
                onTap: _toggleFlash,
                isActive: _isFlashOn,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCorner({
    double? top,
    double? bottom,
    double? left,
    double? right,
    bool borderTop = false,
    bool borderBottom = false,
    bool borderLeft = false,
    bool borderRight = false,
  }) {
    const size = 26.0;
    const thickness = 3.5;
    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border(
            top: borderTop ? const BorderSide(color: AppColors.green, width: thickness) : BorderSide.none,
            bottom: borderBottom ? const BorderSide(color: AppColors.green, width: thickness) : BorderSide.none,
            left: borderLeft ? const BorderSide(color: AppColors.green, width: thickness) : BorderSide.none,
            right: borderRight ? const BorderSide(color: AppColors.green, width: thickness) : BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return Column(
      children: [
        IconButton(
          onPressed: onTap,
          icon: Icon(icon),
          color: isActive ? AppColors.green : Colors.white70,
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildUploadBox(ScanProvider scan) {
    final file = scan.selectedFile;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.line),
      ),
      child: file == null
          ? Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: AppColors.greenLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.greenDark,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Upload Scrap Image',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'JPG, PNG or WEBP · max 10 MB',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                CustomButton(
                  text: 'Browse Files',
                  icon: Icons.file_upload_outlined,
                  onPressed: _pickGallery,
                  isSecondary: true,
                  isBlock: false,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        File(file.path),
                        width: 64,
                        height: 64,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          FutureBuilder<int>(
                            future: file.length(),
                            builder: (context, snapshot) {
                              final size = snapshot.data ?? 0;
                              return Text(
                                '${Formatters.fileSize(size)} · Ready to analyze',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: AppColors.muted),
                      onPressed: scan.clearSelection,
                      tooltip: 'Remove',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                CustomButton(
                  text: 'Analyze Image',
                  icon: Icons.auto_awesome_rounded,
                  onPressed: _runAnalysis,
                  isLoading: scan.isAnalyzing,
                ),
              ],
            ),
    );
  }
}
