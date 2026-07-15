import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/colors.dart';
import '../app/theme/typography.dart';
import '../components/navbar.dart';
import '../components/confidence_pill.dart';
import '../components/emoji_picker.dart';
import '../models/template.dart';

import '../services/storage_service.dart';
import '../services/camera_service.dart';
import '../services/image_service.dart';
import '../utils/constants.dart';
// coordinate_utils used for future region mapping
import '../models/ocr_result.dart';

class TemplateScreen extends StatefulWidget {
  final int? templateId;

  const TemplateScreen({super.key, this.templateId});

  @override
  State<TemplateScreen> createState() => _TemplateScreenState();
}

class _TemplateScreenState extends State<TemplateScreen> {
  final StorageService _storage = StorageService();
  final CameraService _camera = CameraService();
  final ImageService _imageService = ImageService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedEmoji = '\u{1f600}';
  String? _labelImagePath;

  List<TemplateField> _fields = [];
  final List<DetectedTextRegion> _detectedRegions = [];
  final Map<int, int> _fieldToRegionIndex = {};

  bool _isLoading = true;
  bool _isSaving = false;
  bool _saveSuccess = false;
  int _detectionCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.templateId != null) {
      _loadTemplate(widget.templateId!);
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadTemplate(int id) async {
    final template = await _storage.getTemplate(id);
    if (template == null) return;
    final fields = await _storage.getTemplateFields(id);
    setState(() {
      _nameController.text = template.name;
      _descriptionController.text = template.description;
      _selectedEmoji = template.icon;
      _labelImagePath = template.labelPhotoPath.isNotEmpty
          ? template.labelPhotoPath
          : null;
      _fields = fields;
      _isLoading = false;
    });
  }

  Future<void> _pickOrCaptureImage() async {
    final XFile? picked = await _camera.pickFromGallery();
    if (picked != null) {
      final path = await _imageService.saveCaptureFromXFile(picked);
      setState(() {
        _labelImagePath = path;
        _detectionCount = 0;
      });
    }
  }

  Future<void> _saveTemplate() async {
    if (_nameController.text.trim().isEmpty) return;
    setState(() => _isSaving = true);
    try {
      final template = Template(
        id: widget.templateId ?? -1,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        icon: _selectedEmoji,
        color: const Color(0xFFE8F0FE),
        accent: const Color(0xFF0047CC),
        fieldsCount: _fields.length,
        labelPhotoPath: _labelImagePath ?? '',
      );
      if (widget.templateId != null) {
        await _storage.updateTemplate(widget.templateId!, template, _fields);
      } else {
        await _storage.createTemplate(template, _fields);
      }
      setState(() => _saveSuccess = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => _saveSuccess = false);
          context.pop();
        }
      });
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sauvegarde: $e')),
        );
      }
    }
  }

  int get _mappedCount =>
      _fieldToRegionIndex.values.where((v) => v >= 0).length;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: Navbar(
        title: widget.templateId != null
            ? 'Configuration du template'
            : 'Nouveau template',
        subtitle: 'Label Scanner',
        showBackButton: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: AppSpacing.horizontalPadding,
                      right: AppSpacing.horizontalPadding,
                      top: 16.0,
                      bottom: 80.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionLabel('Ic\u00f4ne & Titre'),
                        const SizedBox(height: AppSpacing.gapSmall),
                        Row(
                          children: [
                            EmojiPicker(
                              selectedEmoji: _selectedEmoji,
                              onEmojiSelected: (emoji) {
                                setState(() => _selectedEmoji = emoji);
                              },
                              size: 36,
                            ),
                            const SizedBox(width: AppSpacing.gapSmall),
                            Expanded(
                              child: TextField(
                                controller: _nameController,
                                decoration: InputDecoration(
                                  hintText: 'Nom de l\'\u00e9tiquette...',
                                  hintStyle: const TextStyle(
                                    color: AppColors.mutedForegroundLight,
                                    fontFamily: AppTypography.bodyFontFamily,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.cardLight,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.borderRadiusSmall,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.borderRadiusSmall,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.borderLight,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppSpacing.borderRadiusSmall,
                                    ),
                                    borderSide: const BorderSide(
                                      color: AppColors.primaryLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12.0,
                                    vertical: 8.0,
                                  ),
                                ),
                                style: const TextStyle(
                                  fontFamily: AppTypography.bodyFontFamily,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.gapMedium),
                        _buildSectionLabel('Description'),
                        const SizedBox(height: AppSpacing.gapSmall),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 2,
                          minLines: 2,
                          decoration: InputDecoration(
                            hintText:
                                'D\u00e9crivez ce type d\'\u00e9tiquette...',
                            hintStyle: const TextStyle(
                              color: AppColors.mutedForegroundLight,
                              fontFamily: AppTypography.bodyFontFamily,
                            ),
                            filled: true,
                            fillColor: AppColors.cardLight,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.borderRadiusSmall,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.borderLight,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.borderRadiusSmall,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.borderLight,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                AppSpacing.borderRadiusSmall,
                              ),
                              borderSide: const BorderSide(
                                color: AppColors.primaryLight,
                                width: 1.5,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12.0,
                              vertical: 8.0,
                            ),
                          ),
                          style: const TextStyle(
                            fontFamily: AppTypography.bodyFontFamily,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.gapLarge),
                        _buildSectionLabel(
                          '\u00c9tiquette de r\u00e9f\u00e9rence',
                        ),
                        const SizedBox(height: AppSpacing.gapSmall),
                        _buildImageZone(),
                        if (_fields.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.gapLarge),
                          _buildMappingSectionHeader(_fields.length),
                          const SizedBox(height: AppSpacing.gapSmall),
                          ..._buildMappingCards(),
                        ],
                      ],
                    ),
                  ),
                ),
                _buildSaveBar(),
              ],
            ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(label, style: AppTypography.sectionHeader(context));
  }

  Widget _buildImageZone() {
    return GestureDetector(
      onTap: _pickOrCaptureImage,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 144),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.borderLight, width: 2),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
        ),
        clipBehavior: Clip.antiAlias,
        child: _labelImagePath != null && File(_labelImagePath!).existsSync()
            ? Stack(
                children: [
                  Image.file(
                    File(_labelImagePath!),
                    fit: BoxFit.contain,
                    width: double.infinity,
                  ),
                  ..._fields.map((field) {
                    final topPercent = (field.y / 320.0) * 100;
                    return Positioned(
                      top: topPercent,
                      left: 10,
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
                              field.apiField.split('.').last,
                              style: const TextStyle(
                                fontSize: 9,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF111218).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.borderRadiusSmall,
                        ),
                      ),
                      child: const Text(
                        'Changer',
                        style: TextStyle(fontSize: 11, color: Colors.white),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
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
                            Icons.flash_on,
                            size: 9,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$_detectionCount zones d\u00e9tect\u00e9es',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.mutedLight,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.image,
                        size: 18,
                        color: AppColors.mutedForegroundLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Photographier une \u00e9tiquette',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        fontFamily: AppTypography.bodyFontFamily,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'L\'OCR d\u00e9tectera automatiquement les textes',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForegroundLight,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildMappingSectionHeader(int count) {
    return Row(
      children: [
        Text(
          'Textes d\u00e9tect\u00e9s \u2192 Champs API',
          style: AppTypography.sectionHeader(context),
        ),
        const Expanded(child: Divider(color: AppColors.borderLight, height: 1)),
        Container(
          margin: const EdgeInsets.only(left: 8),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.mutedLight,
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          ),
          child: Text(
            '$count',
            style: AppTypography.monoLabelSmall.copyWith(
              color: AppColors.mutedForegroundLight,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildMappingCards() {
    return _fields.map((field) {
      final regionIndex = _fieldToRegionIndex[field.id] ?? -1;
      final detectedText =
          regionIndex >= 0 && regionIndex < _detectedRegions.length
          ? _detectedRegions[regionIndex]
          : null;

      return Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.gapSmall),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          border: Border.all(color: AppColors.borderLight),
          borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.mutedLight.withValues(alpha: 0.4),
                border: const Border(
                  bottom: BorderSide(color: AppColors.borderLight),
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Texte d\u00e9tect\u00e9',
                    style: AppTypography.monoLabelSmall.copyWith(
                      letterSpacing: 0.08,
                    ),
                  ),
                  if (detectedText != null)
                    ConfidencePill(confidence: detectedText.confidence),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.qr_code_scanner,
                        size: 11,
                        color: AppColors.primaryLight,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: detectedText != null
                            ? Text(
                                detectedText.text,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppTypography.monoFontFamily,
                                ),
                              )
                            : const Text(
                                'Aucun texte d\u00e9tect\u00e9 \u00e0 cette position',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.mutedForegroundLight,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'x: ${field.x.toStringAsFixed(0)} / y: ${field.y.toStringAsFixed(0)}',
                    style: AppTypography.coordinateDisplay(context),
                  ),
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: AppColors.borderLight)),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 8.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Champ API',
                    style: AppTypography.monoLabelSmall.copyWith(
                      letterSpacing: 0.08,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderLight),
                      borderRadius: BorderRadius.circular(
                        AppSpacing.borderRadiusSmall,
                      ),
                    ),
                    child: DropdownButtonFormField<String>(
                      initialValue: field.apiField,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 10.0,
                          vertical: 6.0,
                        ),
                        border: InputBorder.none,
                        suffixIcon: Padding(
                          padding: EdgeInsets.only(right: 8.0),
                          child: Icon(
                            Icons.arrow_drop_down,
                            size: 12,
                            color: AppColors.mutedForegroundLight,
                          ),
                        ),
                      ),
                      dropdownColor: AppColors.backgroundLight,
                      style: const TextStyle(
                        fontSize: 12,
                        fontFamily: AppTypography.bodyFontFamily,
                      ),
                      items: API_FIELDS
                          .map(
                            (fv) =>
                                DropdownMenuItem(value: fv, child: Text(fv)),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          final idx = _fields.indexWhere(
                            (f) => f.id == field.id,
                          );
                          if (idx >= 0) {
                            _fields[idx] = TemplateField(
                              id: field.id,
                              apiField: value ?? '-- S\u00e9lectionner --',
                              x: field.x,
                              y: field.y,
                              confidence: field.confidence,
                            );
                          }
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildSaveBar() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.cardLight,
        border: Border(top: BorderSide(color: AppColors.borderLight)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$_mappedCount/${_fields.length} champs li\u00e9s',
            style: AppTypography.monoLabelMedium.copyWith(
              color: AppColors.mutedForegroundLight,
            ),
          ),
          GestureDetector(
            onTap: _isSaving ? null : _saveTemplate,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              decoration: BoxDecoration(
                color: _saveSuccess
                    ? const Color(0xFF22c55e)
                    : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusSmall,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _saveSuccess ? Icons.check_circle_outline : Icons.settings,
                    size: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _saveSuccess ? 'Sauvegard\u00e9' : 'Enregistrer',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      fontFamily: AppTypography.bodyFontFamily,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
