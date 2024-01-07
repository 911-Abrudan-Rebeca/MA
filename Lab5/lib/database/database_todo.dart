import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_application_1/model/Todo.dart';

class DatabaseTodo {
  DatabaseTodo._();
  static final DatabaseTodo instance = DatabaseTodo._();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  Future<void> resetDatabase() async {
    try {
      // Get the path to the database file
      final String path = join(await getDatabasesPath(), 'todos.db');

      // Delete the existing database file
      await deleteDatabase(path);
      print("Database deleted successfully");

      // Reinitialize the database
      _database = null;
      await initDatabase();
      print("Database reinitialized successfully");
    } catch (e) {
      // Log the error message to the console
      print('Error resetting database: $e');
      rethrow;
    }
  }

  Future<void> deleteTodosTable() async {
    try {
      final db = await database;
      await db.execute('DROP TABLE IF EXISTS todos');
      print("ToDos table deleted successfully");
    } catch (e) {
      print('Error deleting todos table: $e');
      rethrow;
    }
  }

  Future<Database> initDatabase() async {
    try {
      final String path = join(await getDatabasesPath(), 'todos.db');

      return await openDatabase(
        path,
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
          CREATE TABLE todos(
            id INTEGER PRIMARY KEY,
            title TEXT,
            time TEXT,
            details TEXT,
            goal TEXT,
            emotion TEXT
          )
        ''').catchError((error){
          print('Error first : $error');
        });

        print("CREAETING");


          await db.execute('''
            CREATE TABLE cached_requests(
              id INTEGER PRIMARY KEY,
              method TEXT,
              body TEXT,
              timestamp TEXT
            )
          ''').catchError((error) {
            // Log the error message to the console
            print('Error creating cached_requests table: $error');
          });
        },
      );
    } catch (e) {
      print('Error initializing database: $e');
      rethrow;
    }
  }

  Future<void> insertTodos(List<Todo> todos) async {
    for (var todo in todos) {
      try {
        await insertTodo(todo);
        print("Inserted ToDo: ${todo.id}");
      } catch (e) {
        if (e is DatabaseException &&
            e.toString().contains('UNIQUE constraint failed')) {
          print(
              'Error inserting ToDo (ID: ${todo.id}): Unique constraint violation: ToDo.ID already exists in local DB');
        } else {
          print('Error inserting ToDo (ID: ${todo.id}): $e');
        }
      }
    }
  }

  Future<int> insertTodo(Todo todo) async {
    try {
      final db = await database;
      return await db.insert('todos', todo.toMap());
    } catch (e) {
      print('Error inserting ToDo: $e');
      rethrow;
    }
  }

  Future<List<Todo>> getTodos() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('todos');
    return List.generate(maps.length, (i) {
      return Todo.fromMap(maps[i]);
    });
  }

  Future<int> updateTodo(Todo todo) async {
    try {
      final db = await database;
      return await db.update(
        'todos',
        todo.toMap(),
        where: 'id = ?',
        whereArgs: [todo.id],
      );
    } catch (e) {
      print('Error updating ToDo: $e');
      rethrow;
    }
  }

  Future<int> deleteTodo(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'todos',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      print('Error deleting ToDo: $e');
      rethrow;
    }
  }

  Future<void> clearLocalDatabase() async {
    try {
      final db = await database;
      await db.delete('todos');
      print("Cleared local database");
    } catch (e) {
      print('Error clearing local database: $e');
      rethrow;
    }
  }

  // Cache request when the device is offline
  Future<int> cacheRequest(String method, String body) async {
    try {
      final db = await database;
      final timestamp = DateTime.now().toUtc().toIso8601String();
      return await db.insert(
        'cached_requests',
        {'method': method,  'body': body, 'timestamp': timestamp},
      );
    } catch (e) {
      // Log the error message to the console
      print('Error caching request: $e');
      rethrow;
    }
  }

   Future<List<Map<String, dynamic>>> getCachedRequests() async {
  try {
    final db = await database;

    // Check if the cached_requests table exists
    final isTableExists = await db
        .rawQuery('SELECT name FROM sqlite_master WHERE type="table" AND name="cached_requests"')
        .then((result) => result.isNotEmpty);

    if (!isTableExists) {
      print('The cached_requests table does not exist.');
      return [];
    }

    // Continue with the query if the table exists
    return await db.query('cached_requests');
  } catch (e) {
    // Log the error message to the console
    print('Error getting cached requests: $e');
    rethrow;
  }
}

  // Remove cached request after successfully sending to the server
  Future<int> removeCachedRequest(int id) async {
    try {
      final db = await database;
      return await db.delete(
        'cached_requests',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      // Log the error message to the console
      print('Error removing cached request: $e');
      rethrow;
    }
  }
}
