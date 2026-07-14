import 'dart:math';

import 'package:flutter/material.dart';

import '../models/ocr_result.dart';
import '../models/template.dart';

class CoordinateUtils {
  // Reference height for coordinate normalization (from spec)
  static const double referenceHeight = 320.0;

  /// Convert pixel Y to percentage-based value (0-100)
  static double pixelToPercentageY(double pixelY) {
    return (pixelY / referenceHeight) * 100.0;
  }

  /// Convert percentage back to pixel Y for a given image height
  static double percentageToPixelY(double percent, double imageHeight) {
    return (percent / 100.0) * imageHeight;
  }

  /// Normalize all field coordinates from pixels to percentages
  static List<TemplateField> normalizeFields(List<TemplateField> fields) {
    return fields
        .map(
          (field) => TemplateField(
            id: field.id,
            apiField: field.apiField,
            x: pixelToPercentageY(field.x),
            y: pixelToPercentageY(field.y),
            confidence: field.confidence,
          ),
        )
        .toList();
  }

  /// Find the closest template field for a detected text region using Euclidean distance
  /// Threshold: 15 pixels in both X and Y axes
  static TemplateField? findMatchingField(
    double textX,
    double textY,
    List<TemplateField> fields,
  ) {
    TemplateField? bestMatch;
    double bestDistance = 999999.0;

    for (final field in fields) {
      final dx = (field.x - textX).abs();
      final dy = (field.y - textY).abs();

      // Check if within threshold
      if (dx <= 15 && dy <= 15) {
        final distance = dx * dx + dy * dy;
        if (distance < bestDistance) {
          bestDistance = distance;
          bestMatch = field;
        }
      }
    }

    return bestMatch;
  }

  /// Find the closest template field using full Euclidean distance with threshold
  static TemplateField? findClosestField(
    double textX,
    double textY,
    List<TemplateField> fields,
  ) {
    if (fields.isEmpty) return null;

    TemplateField? bestMatch;
    double bestDistance = double.infinity;

    for (final field in fields) {
      final dx = field.x - textX;
      final dy = field.y - textY;
      final distance = sqrt(dx * dx + dy * dy);

      if (distance < bestDistance) {
        bestDistance = distance;
        bestMatch = field;
      }
    }

    return bestMatch;
  }

  /// Calculate Euclidean distance between two points
  static double euclideanDistance(double x1, double y1, double x2, double y2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    return sqrt(dx * dx + dy * dy);
  }

  /// Normalize a detected text region's bounding box to percentage coordinates
  static DetectedTextRegion normalizeBoundingBox(
    DetectedTextRegion region,
    double imageWidth,
    double imageHeight,
  ) {
    return DetectedTextRegion(
      id: region.id,
      text: region.text,
      confidence: region.confidence,
      boundingBox: Rect.fromLTRB(
        (region.boundingBox.left / imageWidth),
        (region.boundingBox.top / imageHeight),
        (region.boundingBox.right / imageWidth),
        (region.boundingBox.bottom / imageHeight),
      ),
    );
  }
}
