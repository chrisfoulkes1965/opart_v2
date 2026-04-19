import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:opart_v2/model_opart.dart';
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
    await db.delete(
      'opart',
      where: 'id = ?',
      whereArgs: [id],
    );
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
          fixedData['type'] = OpArtType.values
              .firstWhere((e) => e.toString() == raw['type'] as String);
        } else if (key == 'colors') {
          final List<String> stringList =
              value.toString().split(',');
          final List<Color> colorList = [];
          for (final part in stringList) {
            if (!part.contains('(0x')) continue;
            final String valueString = part.split('(0x')[1].split(')')[0];
            final int intValue = int.parse(valueString, radix: 16);
            colorList.add(Color(intValue));
          }
          fixedData['colors'] = colorList;
        } else if (value.toString().contains('Color(')) {
          final String valueString =
              value.toString().split('(0x')[1].split(')')[0];
          final int intValue = int.parse(valueString, radix: 16);
          fixedData[key] = Color(intValue);
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
