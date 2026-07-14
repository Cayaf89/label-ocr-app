import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/colors.dart';
import '../app/theme/typography.dart';
import '../components/navbar.dart';
import '../models/template.dart';
import '../services/storage_service.dart';

class TemplateListScreen extends StatefulWidget {
  const TemplateListScreen({super.key});

  @override
  State<TemplateListScreen> createState() => _TemplateListScreenState();
}

class _TemplateListScreenState extends State<TemplateListScreen> {
  final StorageService _storageService = StorageService();
  List<Template> _templates = [];
  int _scansThisMonth = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final templates = await _storageService.getAllTemplates();
    final scansThisMonth = await _storageService.getScansThisMonth();
    setState(() {
      _templates = templates;
      _scansThisMonth = scansThisMonth;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: Navbar(
        title: 'Mes Templates',
        subtitle: 'Label Scanner',
        showBackButton: false,
        rightAction: _buildNewButton(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            color: AppColors.cardLight,
            border: Border(bottom: BorderSide(color: AppColors.borderLight)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            children: [
              _buildStatItem(
                icon: Icons.layers,
                label: '${_templates.length} templates',
              ),
              const SizedBox(width: 24),
              _buildStatItem(
                icon: Icons.inventory_2,
                label: '$_scansThisMonth scans ce mois',
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(
              left: AppSpacing.horizontalPadding,
              right: AppSpacing.horizontalPadding,
              top: AppSpacing.gapMedium,
              bottom: 24.0,
            ),
            child: Column(
              children: [
                if (_templates.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(
                      child: Text(
                        'Aucun template. Appuyez sur "Nouveau" pour commencer.',
                        style: AppTypography.monoLabelMedium.copyWith(
                          color: AppColors.mutedForegroundLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ..._buildTemplateCards(),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: GestureDetector(
            onTap: () => context.push('/templates/new'),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.borderLight, width: 2.0),
                borderRadius: BorderRadius.circular(
                  AppSpacing.borderRadiusSmall,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 14,
                      color: AppColors.mutedForegroundLight,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Cr\u00e9er un nouveau template',
                      style: TextStyle(
                        fontFamily: AppTypography.bodyFontFamily,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.mutedForegroundLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNewButton(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/templates/new'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, size: 12, color: Colors.white),
            SizedBox(width: 4),
            Text(
              'Nouveau',
              style: TextStyle(
                fontFamily: AppTypography.bodyFontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label}) {
    final match = RegExp(r'^(\d+)').firstMatch(label);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: AppColors.mutedForegroundLight),
        const SizedBox(width: 6),
        RichText(
          text: TextSpan(
            style: AppTypography.monoLabelMedium.copyWith(
              color: AppColors.mutedForegroundLight,
              fontSize: 10,
            ),
            children: match != null
                ? [
                    TextSpan(
                      text: match.group(1)!,
                      style: const TextStyle(
                        fontFamily: AppTypography.monoFontFamily,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: AppColors.foregroundLight,
                      ),
                    ),
                    TextSpan(text: label.substring(match.end)),
                  ]
                : [TextSpan(text: label)],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildTemplateCards() {
    return _templates.map((template) {
      return GestureDetector(
        onTap: () => context.push('/templates/${template.id}/configure'),
        child: Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.gapSmall),
          decoration: BoxDecoration(
            color: AppColors.cardLight,
            border: Border.all(color: AppColors.borderLight),
            borderRadius: BorderRadius.circular(AppSpacing.borderRadiusSmall),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12.0,
                  vertical: 12.0,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: template.color,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.borderRadiusSmall,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          template.icon,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.gapMedium),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style: const TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.foregroundLight,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            template.description,
                            style: const TextStyle(
                              fontFamily: AppTypography.bodyFontFamily,
                              fontSize: 10,
                              color: AppColors.mutedForegroundLight,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6.0,
                        vertical: 2.0,
                      ),
                      decoration: BoxDecoration(
                        color: template.accent,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.borderRadiusSmall,
                        ),
                      ),
                      child: Text(
                        '${template.fieldsCount} champs',
                        style: const TextStyle(
                          fontFamily: AppTypography.monoFontFamily,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.borderLight)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 8.0,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.label,
                              color: AppColors.mutedForegroundLight,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              template.lastUsed.isNotEmpty
                                  ? template.lastUsed
                                  : 'Jamais utilis\u00e9',
                              style: const TextStyle(
                                fontFamily: AppTypography.monoFontFamily,
                                fontSize: 9,
                                color: AppColors.mutedForegroundLight,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          left: BorderSide(color: AppColors.borderLight),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => context.push(
                              '/templates/${template.id}/configure',
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Icon(
                                Icons.settings,
                                color: AppColors.foregroundLight,
                              ),
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 20,
                            color: AppColors.borderLight,
                          ),
                          GestureDetector(
                            onTap: () => context.push('/scan'),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.qr_code_scanner,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Scan',
                                    style: TextStyle(
                                      fontFamily: AppTypography.bodyFontFamily,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
