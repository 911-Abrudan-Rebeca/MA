import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper{
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE todos(
      id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
      title TEXT,
      time TEXT,
      details TEXT,
      goal TEXT,
      emotion TEXT
    )""");
    print('Table "todo" created successfully');
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'planner.db',
      version: 1,
      onCreate: (sql.Database database, int version) async{
        await createTables(database);
      }
    ); 
  }

  static Future<int> createTodo(String title, String time, String details, String goal, String emotion) async {
      final db = await SQLHelper.db();

      final data = {'title':title, 'time': time, 'details': details, 'goal': goal, 'emotion': emotion};
      final id = await db.insert('todos', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);

      return id; //of the row
  }

  static Future<List<Map<String, dynamic>>> getTodos() async{
    final db = await SQLHelper.db();
    return db.query('todos', orderBy: "id");
  }

  static Future<List<Map<String, dynamic>>> getTodo(int id) async {
    final db = await SQLHelper.db();
    return db.query('todos', where: "id = ?", whereArgs: [id], limit: 1);
  }

  static Future<int> updateTodo(
    int id, String title, String time, String details, String goal, String emotion) async{
        final db = await SQLHelper.db();

        final data = {
          'title': title,
          'time': time,
          'details': details,
          'goal': goal,
          'emotion': emotion
        };
        final result =
        await db.update('todos', data, where: "id = ?", whereArgs: [id]);
        print('DATABASE Todo: $data');
        return result;
  }

  static Future<void> deleteTodo(int id) async{
    final db = await SQLHelper.db();
    try{
      await db.delete("todos", where: "id = ?", whereArgs: [id]);
    }
    catch (err){
      debugPrint("Something went wrong with deleting the todo: $err");
    }
  }

}