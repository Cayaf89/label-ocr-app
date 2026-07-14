class ScanRecord {
  final int id;
  final int? templateId;
  final String ocrText;
  final double confidence;
  final String? imagePath;
  final String metadataJson;
  final DateTime createdAt;

  const ScanRecord({
    required this.id,
    this.templateId,
    required this.ocrText,
    this.confidence = 0.0,
    this.imagePath,
    this.metadataJson = '{}',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'template_id': templateId,
        'ocr_text': ocrText,
        'confidence': confidence,
        'image_path': imagePath,
        'metadata_json': metadataJson,
        'created_at': createdAt.toIso8601String(),
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
        id: json['id'] as int,
        templateId: json['template_id'] as int?,
        ocrText: json['ocr_text'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        imagePath: json['image_path'] as String?,
        metadataJson: json['metadata_json'] as String? ?? '{}',
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  ScanRecord copyWith({
    int? id,
    int? templateId,
    String? ocrText,
    double? confidence,
    String? imagePath,
    String? metadataJson,
    DateTime? createdAt,
  }) =>
      ScanRecord(
        id: id ?? this.id,
        templateId: templateId ?? this.templateId,
        ocrText: ocrText ?? this.ocrText,
        confidence: confidence ?? this.confidence,
        imagePath: imagePath ?? this.imagePath,
        metadataJson: metadataJson ?? this.metadataJson,
        createdAt: createdAt ?? this.createdAt,
      );
}
