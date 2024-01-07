import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/database_todo.dart';
import 'package:flutter_application_1/model/Todo.dart';
import 'package:flutter_application_1/server/ApiRequests.dart';
import 'package:flutter_application_1/view/AddTodo.dart';
import 'package:flutter_application_1/view/EditTodo.dart';
import 'package:flutter_application_1/view/TodoNotifier.dart';
import 'package:provider/provider.dart';


Future<void> syncCachedRequests() async {
  try {
    final cachedRequests = await DatabaseTodo.instance.getCachedRequests();

    for (var cachedRequest in cachedRequests) {
      final method = cachedRequest['method'];
      final bodyString = cachedRequest['body'];

      // Parse the JSON string into a Dart map
      final body = json.decode(bodyString);

      print('Body for cached request is: $body');
      final id = body['id'];

      try {
        if (method.toLowerCase() == 'put') {
          print("Sending PUT request for cached ToDo:$id");
          // If the method is PUT, assume it's an 'update' request
          await ApiRequests.putRequest('/update', body).timeout(
            Duration(seconds: 2),
            onTimeout: () {
              // Handle the timeout
              print('Timeout syncing cached request: $id');
            },
          );
        } else if (method.toLowerCase() == 'delete') {
          print("Sending DELETE request for cached ToDo:$id");
          // If the method is DELETE, assume it's a 'delete' request
          await ApiRequests.deleteRequest('/delete/$id').timeout(
            Duration(seconds: 2),
            onTimeout: () {
              // Handle the timeout
              throw TimeoutException('The request to the server timed out');
            },
          );
        }

        // Remove the cached request as it was successfully sent to the server
        await DatabaseTodo.instance.removeCachedRequest(cachedRequest['id']);
      } catch (e) {
        // Log the error message to the console
        print('Error syncing cached request: $e');
      }
    }
  } catch (e) {
    // Log the error message to the console
    print('Error syncing cached requests: $e');
  }
}

Future<void> syncLocalTodosToServer(List<Todo> localTodos) async {
  // Post ToDo items that are fresh (negative ID)
  for (var todo in localTodos) {
    if (todo.id! < 0) {
      // ToDo has a negative ID, indicating it is not yet synced with the server
      try {
        // Post to server
        await ApiRequests.postRequest(
          '/add_todo',
          todo.toMap(),
        ).timeout(
          Duration(seconds: 2),
          onTimeout: () {
            // Handle the timeout
            print('Timeout syncing ToDo to the server:${todo.id}');
          },
        );
      } catch (e) {
        // Handle the error
        print('Error posting ToDo ${todo.id} to the server: $e');
      }
    }
  }

  // Make updates/deletes on already existing ToDo items on the server
  await syncCachedRequests();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check for an internet connection
  bool isInternetConnected = await ApiRequests.isInternetConnected();

  List<Todo> todos = [];

  // If there is an internet connection, fetch data from the server
  if (isInternetConnected) {
    // Get local DB ToDos
    List<Todo> localDbTodos = await DatabaseTodo.instance.getTodos();

    // Sync local ToDos with negative IDs to the server
    await syncLocalTodosToServer(localDbTodos);

    try {
      print("Trying to fetch data from server");

      // Use the timeout feature to set a 5-second timeout for the network request
      List<Todo> serverTodos = await ApiRequests.getTodos().timeout(
        Duration(seconds: 10),
        onTimeout: () {
          // This callback is called if the network request times out
          throw TimeoutException('The request to the server timed out');
        },
      ).then((todoMap) {
        return todoMap.map((todoMap) => Todo.fromMap(todoMap)).toList();
      });

      // Clear the local database after successfully syncing with the server
      await DatabaseTodo.instance.clearLocalDatabase();

      // Insert ToDo items received from the server
      await DatabaseTodo.instance.insertTodos(serverTodos);

      todos = serverTodos;
    } catch (e) {
      print("Error fetching ToDo items from the server: $e");

      // If fetching from the server fails, fetch data from the local database
      todos = await DatabaseTodo.instance.getTodos();
    }
  } else {
    // If there is no internet connection, fetch data from the local database
    todos = await DatabaseTodo.instance.getTodos();
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => TodoNotifier()..setTodos(todos)),
      ],
      child: const MyApp(),
    ),
  );
}


//

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(
        // app theme settings
      ),
      home: const MyHomePage(title: 'Todo App'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Color.fromARGB(255, 0, 195, 10),
      ),
      backgroundColor: Color.fromARGB(255, 0, 201, 191),
      body: Consumer<TodoNotifier>(
        builder: (context, todoNotifier, child) {
          final todos = todoNotifier.todos;
          return TodoList(todos: todos);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newTodo = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => AddTodo(),
            ),
          );

          if (newTodo != null) {
            // Add the new ToDo to the list
            context.read<TodoNotifier>().addTodo(newTodo);
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('New Todo added successfully'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        tooltip: 'Add Todo',
        backgroundColor: Color(0xFF023047),
        child: Icon(Icons.add),
      ),
    );
  }
}

class TodoList extends StatelessWidget {
  final List<Todo> todos;

  const TodoList({Key? key, required this.todos}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todos.length,
      itemBuilder: (context, index) {
        final todo = todos[index];
        return GestureDetector(
          onTap: () async {
            final updatedTodo = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EditTodo(todo: todo),
              ),
            );

            if (updatedTodo != null) {
              if (updatedTodo is Todo) {
                // The ToDo was updated, we returned a ToDo type
                // Update the ToDo in the UI
                context.read<TodoNotifier>().updateTodo(updatedTodo);
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Todo updated successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else if (updatedTodo is int) {
                // The ToDo was deleted, we returned an int - the ID of the deleted ToDo
                final scaffoldMessenger = ScaffoldMessenger.of(context);
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text('Todo deleted successfully'),
                    duration: Duration(seconds: 2),
                  ),
                );

                context.read<TodoNotifier>().deleteTodo(updatedTodo);
              }
            }
          },
          child: ListTile(
            title: Text('${todo.title}', style: TextStyle(fontSize: 20)),
            subtitle: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Time: ${todo.time}', style: TextStyle(fontSize: 15)),
                  // other fields 
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

