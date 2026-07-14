import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/template.dart';
import '../models/scan_record.dart';

/// Service for SQLite database operations.
///
/// Manages persistence of templates, template fields, and scan records.
/// Uses the singleton pattern to ensure a single database connection.
class StorageService {
  static Database? _database;

  /// Get the database instance (singleton pattern).
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database with schema from specification.
  Future<Database> _initDatabase() async {
    final String path = join(await getDatabasesPath(), 'label_ocr.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Templates table
        await db.execute('''
          CREATE TABLE templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT DEFAULT '',
            icon TEXT DEFAULT '😀',
            color TEXT DEFAULT '#E8F0FE',
            accent TEXT DEFAULT '#0047CC',
            label_photo_path TEXT,
            created_at TEXT DEFAULT (datetime('now')),
            updated_at TEXT DEFAULT (datetime('now'))
          )
        ''');

        // Template fields table
        await db.execute('''
          CREATE TABLE template_fields (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            template_id INTEGER NOT NULL REFERENCES templates(id) ON DELETE CASCADE,
            api_field TEXT NOT NULL,
            x REAL NOT NULL,
            y REAL NOT NULL,
            confidence REAL DEFAULT 0.0
          )
        ''');

        // Scans table
        await db.execute('''
          CREATE TABLE scans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            template_id INTEGER REFERENCES templates(id),
            ocr_text TEXT NOT NULL,
            confidence REAL DEFAULT 0.0,
            image_path TEXT,
            metadata_json TEXT,
            created_at TEXT DEFAULT (datetime('now'))
          )
        ''');

        // Insert sample templates with their fields
        final samples = Template.getSampleTemplates();
        for (final template in samples) {
          await db.insert('templates', _templateToDbMap(template));
        }
      },
      onOpen: (db) async {},
    );
  }

  // === Helper Methods ===

  /// Convert a [Template] to a database map, excluding fields_count.
  Map<String, dynamic> _templateToDbMap(Template template) {
    return {
      'id': template.id,
      'name': template.name,
      'description': template.description,
      'icon': template.icon,
      'color': template.color.toARGB32().toRadixString(16),
      'accent': template.accent.toARGB32().toRadixString(16),
      'label_photo_path': template.labelPhotoPath,
    };
  }

  /// Convert a database row to a [Template], loading fields count from the DB.
  Template _dbRowToTemplate(Map<String, dynamic> map, int fieldsCount) {
    return Template(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      labelPhotoPath: map['label_photo_path'] as String? ?? '',
      icon: map['icon'] as String? ?? '😀',
      fieldsCount: fieldsCount,
      lastUsed: map['updated_at'] as String? ?? '',
      color: Color(
        int.parse(map['color'] as String, radix: 16) | 0xFF000000,
      ),
      accent: Color(
        int.parse(map['accent'] as String, radix: 16) | 0xFF000000,
      ),
    );
  }

  // === Template Operations ===

  /// Get all templates with their fields count.
  Future<List<Template>> getAllTemplates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('templates');

    return Future.wait(maps.map((map) async {
      // Get fields count for this template
      final List<Map<String, dynamic>> fieldMaps = await db.query(
        'template_fields',
        where: 'template_id = ?',
        whereArgs: [map['id']],
      );

      return _dbRowToTemplate(map, fieldMaps.length);
    }));
  }

  /// Get a single template by ID with its fields.
  Future<Template?> getTemplate(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'templates',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;

    // Get fields count for this template
    final List<Map<String, dynamic>> fieldMaps = await db.query(
      'template_fields',
      where: 'template_id = ?',
      whereArgs: [id],
    );

    return _dbRowToTemplate(maps.first, fieldMaps.length);
  }

  /// Create a new template and its fields within a transaction.
  Future<int> createTemplate(Template template, List<TemplateField> fields) async {
    final db = await database;
    return await db.transaction((txn) async {
      // Insert template (without id - let DB auto-generate it)
      final Map<String, dynamic> templateMap = _templateToDbMap(template);
      templateMap.remove('id'); // Let SQLite handle AUTOINCREMENT
      final int id = await txn.insert('templates', templateMap);

      // Insert fields
      for (final field in fields) {
        await txn.insert('template_fields', {
          'template_id': id,
          'api_field': field.apiField,
          'x': field.x,
          'y': field.y,
          'confidence': field.confidence,
        });
      }

      return id;
    });
  }

  /// Update an existing template and replace all its fields.
  Future<void> updateTemplate(
    int id,
    Template template,
    List<TemplateField> fields,
  ) async {
    final db = await database;
    await db.transaction((txn) async {
      // Update template
      final Map<String, dynamic> templateMap = _templateToDbMap(template);
      templateMap.remove('id'); // Don't update id
      await txn.update(
        'templates',
        templateMap,
        where: 'id = ?',
        whereArgs: [id],
      );

      // Delete old fields and insert new ones
      await txn.delete('template_fields', where: 'template_id = ?', whereArgs: [id]);
      for (final field in fields) {
        await txn.insert('template_fields', {
          'template_id': id,
          'api_field': field.apiField,
          'x': field.x,
          'y': field.y,
          'confidence': field.confidence,
        });
      }
    });
  }

  /// Delete a template and all its associated fields.
  Future<void> deleteTemplate(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      // Fields are deleted via ON DELETE CASCADE, but be explicit for clarity
      await txn.delete('template_fields', where: 'template_id = ?', whereArgs: [id]);
      await txn.delete('templates', where: 'id = ?', whereArgs: [id]);
    });
  }

  /// Get template fields by template ID.
  Future<List<TemplateField>> getTemplateFields(int templateId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'template_fields',
      where: 'template_id = ?',
      whereArgs: [templateId],
    );

    return List.generate(maps.length, (i) => TemplateField.fromJson(maps[i]));
  }

  // === Scan Record Operations ===

  /// Save a scan record.
  Future<int> saveScan(ScanRecord scan) async {
    final db = await database;
    return await db.insert('scans', scan.toJson());
  }

  /// Get all scans, optionally filtered by template ID.
  ///
  /// Results are ordered by [created_at] descending (newest first).
  Future<List<ScanRecord>> getScans({int? templateId}) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;

    if (templateId != null) {
      maps = await db.query(
        'scans',
        where: 'template_id = ?',
        whereArgs: [templateId],
        orderBy: 'created_at DESC',
      );
    } else {
      maps = await db.query('scans', orderBy: 'created_at DESC');
    }

    return List.generate(maps.length, (i) => ScanRecord.fromJson(maps[i]));
  }

  /// Get the number of scans performed in the current calendar month.
  Future<int> getScansThisMonth() async {
    final db = await database;
    final DateTime now = DateTime.now();
    final String startOfMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';

    final List<Map<String, dynamic>> result = await db.rawQuery(
      "SELECT COUNT(*) as count FROM scans WHERE created_at >= ?",
      [startOfMonth],
    );

    return (result.first['count'] as int?) ?? 0;
  }

  /// Delete a scan record by ID.
  Future<void> deleteScan(int id) async {
    final db = await database;
    await db.delete('scans', where: 'id = ?', whereArgs: [id]);
  }

  // === Utility Methods ===

  /// Close the database connection.
  ///
  /// Call this when the application is shutting down to release resources.
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}