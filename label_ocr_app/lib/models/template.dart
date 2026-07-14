import 'package:flutter/material.dart';

class TemplateField {
  final int id;
  final String apiField;
  final double x;
  final double y;
  final double confidence;

  const TemplateField({
    required this.id,
    required this.apiField,
    required this.x,
    required this.y,
    this.confidence = 0.0,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'api_field': apiField,
    'x': x,
    'y': y,
    'confidence': confidence,
  };

  factory TemplateField.fromJson(Map<String, dynamic> json) => TemplateField(
    id: json['id'] as int,
    apiField: json['api_field'] as String,
    x: (json['x'] as num).toDouble(),
    y: (json['y'] as num).toDouble(),
    confidence: (json['confidence'] as num).toDouble(),
  );

  TemplateField copyWith({
    int? id,
    String? apiField,
    double? x,
    double? y,
    double? confidence,
  }) => TemplateField(
    id: id ?? this.id,
    apiField: apiField ?? this.apiField,
    x: x ?? this.x,
    y: y ?? this.y,
    confidence: confidence ?? this.confidence,
  );
}

class Template {
  final int id;
  final String name;
  final String description;
  final String labelPhotoPath;
  final String icon;
  final int fieldsCount;
  final String lastUsed;
  final Color color;
  final Color accent;
  final List<TemplateField> fields;

  const Template({
    required this.id,
    required this.name,
    this.description = '',
    this.labelPhotoPath = '',
    this.icon = '😀',
    this.fieldsCount = 0,
    this.lastUsed = '',
    required this.color,
    required this.accent,
    this.fields = const [],
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'label_photo_path': labelPhotoPath,
    'icon': icon,
    'fields_count': fieldsCount,
    'last_used': lastUsed,
    'color': color.toARGB32().toRadixString(16),
    'accent': accent.toARGB32().toRadixString(16),
  };

  factory Template.fromJson(Map<String, dynamic> json) => Template(
    id: json['id'] as int,
    name: json['name'] as String,
    description: json['description'] as String? ?? '',
    labelPhotoPath: json['label_photo_path'] as String? ?? '',
    icon: json['icon'] as String? ?? '😀',
    fieldsCount: json['fields_count'] as int? ?? 0,
    lastUsed: json['last_used'] as String? ?? '',
    color: Color(int.parse(json['color'] as String, radix: 16) | 0xFF000000),
    accent: Color(int.parse(json['accent'] as String, radix: 16) | 0xFF000000),
  );

  Template copyWith({
    int? id,
    String? name,
    String? description,
    String? labelPhotoPath,
    String? icon,
    int? fieldsCount,
    String? lastUsed,
    Color? color,
    Color? accent,
    List<TemplateField>? fields,
  }) => Template(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description ?? this.description,
    labelPhotoPath: labelPhotoPath ?? this.labelPhotoPath,
    icon: icon ?? this.icon,
    fieldsCount: fieldsCount ?? this.fieldsCount,
    lastUsed: lastUsed ?? this.lastUsed,
    color: color ?? this.color,
    accent: accent ?? this.accent,
    fields: fields ?? this.fields,
  );

  // Sample templates from spec
  static List<Template> getSampleTemplates() => [
    const Template(
      id: 1,
      name: 'Produit laitier',
      description: 'Étiquettes produits laitiers',
      icon: '🥛',
      fieldsCount: 5,
      lastUsed: "Aujourd'hui, 09:14",
      color: Color(0xFFE8F0FE),
      accent: Color(0xFF0047CC),
    ),
    const Template(
      id: 2,
      name: 'Conserves alimentaires',
      description: 'Boîtes de conserve et conserves',
      icon: '🥫',
      fieldsCount: 4,
      lastUsed: 'Hier, 15:30',
      color: Color(0xFFFEF3E8),
      accent: Color(0xFFFF5200),
    ),
    const Template(
      id: 3,
      name: 'Surgelés',
      description: 'Emballages produits surgelés',
      icon: '🧊',
      fieldsCount: 6,
      lastUsed: '12 juil. 2025',
      color: Color(0xFFE8F8FE),
      accent: Color(0xFF0092CC),
    ),
    const Template(
      id: 4,
      name: 'Cosmétiques',
      description: 'Produits de beauté et cosmétiques',
      icon: '💄',
      fieldsCount: 7,
      lastUsed: '10 juil. 2025',
      color: Color(0xFFF5E8FE),
      accent: Color(0xFF7A00CC),
    ),
    const Template(
      id: 5,
      name: 'Médicaments OTC',
      description: 'Médicaments en vente libre',
      icon: '💊',
      fieldsCount: 8,
      lastUsed: '8 juil. 2025',
      color: Color(0xFFFEE8E8),
      accent: Color(0xFFFF0022),
    ),
  ];
}
