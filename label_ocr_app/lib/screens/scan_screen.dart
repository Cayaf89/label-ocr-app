import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/colors.dart';
import '../app/theme/typography.dart';
import '../components/confidence_pill.dart';
// storage used for future template integration
import '../services/camera_service.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
import '../models/ocr_result.dart';

/// Camera capture + OCR results screen with three states:
/// 1. Empty - camera icon frame + instruction text
/// 2. Scanning - animated scan line within corner frame
/// 3. Result - captured image with overlays + extracted data
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  final CameraService _camera = CameraService();
  final ImageService _imageService = ImageService();

  // States: idle, scanning, result, sent
  String _state = 'idle';
  String? _capturedImagePath;
  // ignore: unused_field - stored for future OCR region display
  List<DetectedTextRegion> _detectedRegions = [];
  final Map<String, DetectedTextRegion?> _fieldValues = {};
  bool _isSending = false;

  late AnimationController _scanAnimationController;
  late Animation<double> _scanLinePosition;

  @override
  void initState() {
    super.initState();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _scanLinePosition = Tween<double>(begin: 0.1, end: 0.85).animate(
      CurvedAnimation(
        parent: _scanAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto() async {
    setState(() => _state = 'scanning');
    try {
      final XFile? photo = await _camera.capturePhoto();
      if (photo == null) {
        setState(() => _state = 'idle');
        return;
      }
      final savedPath = await _imageService.saveCaptureFromXFile(photo);
      setState(() {
        _capturedImagePath = savedPath;
      });
      // Simulate OCR processing
      await Future.delayed(const Duration(milliseconds: 1500));
      await _processOcr(savedPath);
    } catch (e) {
      setState(() => _state = 'idle');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur capture: $e')));
      }
    }
  }

  Future<void> _processOcr(String imagePath) async {
    try {
      // Simulate OCR detection with sample data
      final regions = <DetectedTextRegion>[];
      int idCounter = 0;
      final sampleTexts = ['Lait entier', '3.2% MG', '1L', '25/08/2026', 'FR'];
      for (final text in sampleTexts) {
        regions.add(
          DetectedTextRegion(
            id: idCounter++,
            text: text,
            confidence: 94.0 + (idCounter * 0.5),
            boundingBox: Rect.fromLTWH(
              20.0 + (idCounter * 30),
              30.0 + (idCounter * 40),
              80.0,
              20.0,
            ),
          ),
        );
      }

      setState(() {
        _detectedRegions = regions;
        // Auto-map to fields
        for (int i = 0; i < regions.length && i < API_FIELDS.length - 1; i++) {
          _fieldValues[API_FIELDS[i + 1]] = regions[i];
        }
        _state = 'result';
      });
    } catch (e) {
      setState(() => _state = 'idle');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur OCR: $e')));
      }
    }
  }

  void _resetScan() {
    setState(() {
      _state = 'idle';
      _capturedImagePath = null;
      _detectedRegions = [];
      _fieldValues.clear();
    });
  }

  Future<void> _sendData() async {
    setState(() => _isSending = true);
    // Simulate sending
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Donn\u00e9es envoy\u00e9es avec succ\u00e8s!'),
        ),
      );
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111218),
      body: Column(
        children: [
          // Dark app bar
          _buildAppBar(),

          // Camera / Scan zone (180px)
          Container(
            height: 180,
            decoration: const BoxDecoration(color: Color(0xFF111218)),
            child: _buildCameraZone(),
          ),

          // Action buttons below camera zone
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.horizontalPadding,
              vertical: 12.0,
            ),
            child: _buildActionButtons(),
          ),

          // Extracted data section (visible when scanned)
          if (_state == 'result') ...[
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 80.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.horizontalPadding,
                      ),
                      child: _buildExtractedDataHeader(),
                    ),
                    const SizedBox(height: AppSpacing.gapSmall),
                    ..._buildFieldCards(),
                  ],
                ),
              ),
            ),
          ] else
            const Spacer(),

          // Bottom send bar (visible when scanned)
          if (_state == 'result') _buildSendBar(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      color: const Color(0xFF111218),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Padding(
              padding: const EdgeInsets.only(left: -4.0),
              child: Icon(
                Icons.arrow_back,
                size: 18,
                color: Colors.white.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'OCR Mapper',
                  style: TextStyle(
                    fontSize: 10,
                    fontFamily: AppTypography.monoFontFamily,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  "Scanner une \u00e9tiquette",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppTypography.bodyFontFamily,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraZone() {
    return Stack(
      children: [
        // Hidden video element as subtle background
        Positioned.fill(child: Container(color: const Color(0xFF111218))),

        if (_state == 'result' && _capturedImagePath != null)
          // State 3: Captured image with OCR overlays
          Stack(
            children: [
              Opacity(
                opacity: 0.85,
                child: Image.file(
                  File(_capturedImagePath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
              Positioned.fill(
                child: Stack(
                  children: _fieldValues.entries.map((entry) {
                    final field = entry.key;
                    final region = entry.value;
                    if (region == null) return const SizedBox.shrink();

                    // Calculate position from bounding box
                    final topPercent = (region.boundingBox.top / 320.0) * 100;
                    final leftPercent = (region.boundingBox.left / 320.0) * 100;
                    return Positioned(
                      top: topPercent.clamp(0, 80),
                      left: leftPercent.clamp(5, 40),
                      width: 45,
                      height: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryLight,
                            width: 1,
                          ),
                          color: AppColors.primaryLight.withValues(alpha: 0.15),
                        ),
                        child: Positioned(
                          top: -14,
                          left: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 2,
                              vertical: 1,
                            ),
                            color: AppColors.primaryLight,
                            child: Text(
                              field.split('.').last,
                              style: const TextStyle(
                                fontSize: 7,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Status badge bottom-right
              Positioned(
                bottom: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111218).withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.borderRadiusSmall,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF22c55e),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_fieldValues.values.where((v) => v != null).length} champs reconnus',
                        style: const TextStyle(
                          fontSize: 9,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )
        else if (_state == 'scanning')
          // State 2: Scanning animation
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 128,
                  height: 128,
                  child: Stack(
                    children: [
                      // Corner frame
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildCornerFrame(),
                      ),
                      // Scanning line
                      Positioned(
                        top: _scanLinePosition.value * 128.0,
                        left: 8,
                        right: 8,
                        height: 2,
                        child: Container(color: AppColors.primaryLight),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Analyse en cours...',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppTypography.monoFontFamily,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          )
        else
          // State 1: Empty / No capture yet
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 112,
                  height: 112,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildEmptyFrame(),
                      ),
                      Center(
                        child: Icon(
                          Icons.camera_alt,
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Appuyez sur le bouton ci-dessous pour ouvrir la cam\u00e9ra.',
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: AppTypography.monoFontFamily,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildCornerFrame() {
    return Stack(
      children: [
        // Top-left corner (thicker for top)
        Positioned(
          top: 0,
          left: 0,
          child: Container(width: 24, height: 4, color: AppColors.primaryLight),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(width: 4, height: 24, color: AppColors.primaryLight),
        ),
        // Top-right corner (thicker for top)
        Positioned(
          top: 0,
          right: 0,
          child: Container(width: 24, height: 4, color: AppColors.primaryLight),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(width: 4, height: 24, color: AppColors.primaryLight),
        ),
        // Bottom-left corner (thinner for bottom)
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(width: 24, height: 3, color: AppColors.primaryLight),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(width: 3, height: 24, color: AppColors.primaryLight),
        ),
        // Bottom-right corner (thinner for bottom)
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(width: 24, height: 3, color: AppColors.primaryLight),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(width: 3, height: 24, color: AppColors.primaryLight),
        ),
      ],
    );
  }

  Widget _buildEmptyFrame() {
    return Stack(
      children: [
        // Top-left corner
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 24,
            height: 3,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          child: Container(
            width: 3,
            height: 24,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        // Top-right corner
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 24,
            height: 3,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 3,
            height: 24,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        // Bottom-left corner
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 24,
            height: 3,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 3,
            height: 24,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        // Bottom-right corner
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 24,
            height: 3,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 3,
            height: 24,
            color: Colors.white.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    if (_state == 'idle') {
      return GestureDetector(
        onTap: _capturePhoto,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: AppColors.foregroundLight),
              SizedBox(width: 8),
              Text(
                'Prendre une photo',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTypography.bodyFontFamily,
                ),
              ),
            ],
          ),
        ),
      );
    } else if (_state == 'result') {
      return GestureDetector(
        onTap: _resetScan,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.camera_alt, color: AppColors.foregroundLight),
              SizedBox(width: 8),
              Text(
                'Rescanner',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: AppTypography.bodyFontFamily,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildExtractedDataHeader() {
    return Row(
      children: [
        Text(
          'Donn\u00e9es extraites',
          style: AppTypography.sectionHeader(context).copyWith(fontSize: 10),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight, height: 1)),
      ],
    );
  }

  List<Widget> _buildFieldCards() {
    return _fieldValues.entries.where((e) => e.value != null).map((entry) {
      final fieldName = entry.key;
      final region = entry.value!;

      return Container(
        margin: const EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: AppSpacing.gapSmall,
        ),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Field name header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Text(
                fieldName,
                style: AppTypography.fieldNameHeader(context),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
            ),

            // Value row
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      region.text,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: AppTypography.monoFontFamily,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.gapSmall),
                  ConfidencePill(confidence: region.confidence),
                ],
              ),
            ),

            // Coordinates row
            Padding(
              padding: const EdgeInsets.only(
                left: 12.0,
                right: 12.0,
                bottom: 8.0,
              ),
              child: Text(
                'x: ${region.boundingBox.left.toStringAsFixed(0)} / y: ${region.boundingBox.top.toStringAsFixed(0)}',
                style: AppTypography.coordinateDisplay(context),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSendBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardLight,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: GestureDetector(
        onTap: _isSending ? null : _sendData,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          decoration: BoxDecoration(
            color: _isSending
                ? const Color(0xFF22c55e)
                : AppColors.primaryLight,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSending ? Icons.check_circle_outline : Icons.send,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                _isSending ? 'Envoi en cours...' : 'Envoyer',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppTypography.bodyFontFamily,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
