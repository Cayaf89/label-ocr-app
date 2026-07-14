import 'package:flutter/material.dart';

class DetectedTextRegion {
  final int id;
  final String text;
  final double confidence;
  final Rect boundingBox;

  const DetectedTextRegion({
    required this.id,
    required this.text,
    required this.confidence,
    required this.boundingBox,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'confidence': confidence,
        'bounding_box_left': boundingBox.left,
        'bounding_box_top': boundingBox.top,
        'bounding_box_width': boundingBox.width,
        'bounding_box_height': boundingBox.height,
      };

  factory DetectedTextRegion.fromJson(Map<String, dynamic> json) =>
      DetectedTextRegion(
        id: json['id'] as int,
        text: json['text'] as String? ?? '',
        confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
        boundingBox: Rect.fromLTRB(
          (json['bounding_box_left'] as num).toDouble(),
          (json['bounding_box_top'] as num).toDouble(),
          (json['bounding_box_right'] as num).toDouble(),
          (json['bounding_box_bottom'] as num).toDouble(),
        ),
      );

  DetectedTextRegion copyWith({
    int? id,
    String? text,
    double? confidence,
    Rect? boundingBox,
  }) =>
      DetectedTextRegion(
        id: id ?? this.id,
        text: text ?? this.text,
        confidence: confidence ?? this.confidence,
        boundingBox: boundingBox ?? this.boundingBox,
      );

  @override
  String toString() =>
      'DetectedTextRegion(id: $id, text: "$text", confidence: ${confidence.toStringAsFixed(1)}%, box: $boundingBox)';
}
