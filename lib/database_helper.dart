import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:opart_v2/model_opart.dart';
import 'package:opart_v2/print/models/opart_recipe.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const _databaseName = 'MyDatabase.db';
  static const _databaseVersion = 1;

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final Directory documentsDirectory =
        await getApplicationDocumentsDirectory();
    final String path = join(documentsDirectory.path, _databaseName);
    return openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE opart (
                id INTEGER PRIMARY KEY,
                data STRING NOT NULL )
              ''');
  }

  Future<int> insert(Map<String, dynamic> data) async {
    final String jsonMap = jsonEncode(data);
    final Database db = await database;
    final int id = await db.insert('opart', {'data': jsonMap});
    return id;
  }

  Future<List<Map<String, dynamic>>> getData() async {
    final Database db = await database;
    return db.query('opart');
  }

  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('opart', where: 'id = ?', whereArgs: [id]);
  }

  /// Hydrates [savedOpArt] from SQLite. Each row's JSON is parsed once.
  Future<void> getUserDb() async {
    final rows = await getData();
    for (final row in rows) {
      final Map<String, dynamic> raw =
          jsonDecode(row['data'] as String) as Map<String, dynamic>;
      final Map<String, dynamic> fixedData = {'id': row['id']};

      raw.forEach((key, value) {
        if (key == 'type') {
          fixedData['type'] = OpArtType.values.firstWhere(
            (e) => e.toString() == raw['type'] as String,
          );
        } else if (key == 'colors') {
          fixedData['colors'] = OpArtRecipe.parseColorList(value) ?? <Color>[];
        } else if (OpArtRecipe.isColorSettingKey(key)) {
          fixedData[key] = OpArtRecipe.parseColor(value) ?? value;
        } else {
          fixedData[key] = value;
        }
      });

      savedOpArt.add(fixedData);
    }
    if (savedOpArt.isNotEmpty) {
      rebuildMain.value++;
    }
  }

  Future<void> deleteDB() async {
    final Database db = await database;
    await db.delete('opart');
  }
}
