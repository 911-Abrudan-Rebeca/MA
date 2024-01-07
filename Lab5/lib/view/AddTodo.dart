import 'dart:async';

import 'package:flutter_application_1/model/Todo.dart';

import 'package:flutter_application_1/database/database_todo.dart';
import 'package:flutter_application_1/server/ApiRequests.dart';
import 'package:flutter_application_1/view/TodoNotifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class AddTodo extends StatefulWidget {
  @override
  _AddTodoState createState() => _AddTodoState();
}

class _AddTodoState extends State<AddTodo> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController emotionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final todoNotifier = Provider.of<TodoNotifier>(context, listen: false);
    final nextId = todoNotifier.findHighestId() + 1;

    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 201, 191),
      appBar: AppBar(
        title: Text('Add Todo'),
        backgroundColor: Color.fromARGB(255, 195, 0, 117),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextFormField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextFormField(
              controller: timeController,
              decoration: InputDecoration(labelText: 'Time'),
            ),
            TextFormField(
              controller: detailsController,
              decoration: InputDecoration(labelText: 'Details'),
            ),
            TextFormField(
              controller: goalController,
              decoration: InputDecoration(labelText: 'Goal'),
            ),
            TextFormField(
              controller: emotionController,
              decoration: InputDecoration(labelText: 'Emotion'),
            ),

            ElevatedButton(
              onPressed: () async {
                final newTodo = Todo(
                  id: nextId,
                  title: titleController.text,
                  time: timeController.text,
                  details: detailsController.text,
                  goal: goalController.text,
                  emotion: emotionController.text,
                );

                try {
                  var result = 0;
                  // Post to server
                  try {
                    await ApiRequests.postRequest(
                      '/add_todo',
                      newTodo.toMap(),
                    ).timeout(
                      Duration(seconds: 2),
                      onTimeout: () {
                        // This callback is called if the network request times out
                        throw TimeoutException(
                            'The request to the server timed out');
                      },
                    );

                    // Insert new todo in SQLite
                    result = await DatabaseTodo.instance.insertTodo(newTodo);
                  } catch (e) {
                    print("Error posting todo to the server or timeout: $e");

                    // Save todo to local DB with negative ID to be synced at next connection with the server
                    var negativeId = todoNotifier.findLowestId();

                    if (negativeId > 0) {
                      // If it is the first added offline, just negate the id
                      newTodo.id = -newTodo.id;
                    } else {
                      // If multiple are added offline, we need to find the lowest id and subtract 1 from it
                      newTodo.id = negativeId - 1;
                    }

                    result = await DatabaseTodo.instance.insertTodo(newTodo);
                    if (result != 0)
                      print("Successfully posted todo to local DB");
                  }

                  if (result != 0) {
                    Navigator.pop(context, newTodo);
                  } else {
                    // Alert dialog for error
                    print(
                        "Error when trying to add new todo in local database");
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Error'),
                        content: Text('Failed to add a new todo. Please try again.'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                } catch (e) {
                  // Log the error message
                  print("Error when trying to add new todo: $e");

                  // Show AlertDialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Error'),
                      content: Text('Failed to add a new todo. Please try again.'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('OK'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF023047)),
              child: Text('Add Todo'),
            ),
          ],
        ),
      ),
    );
  }
}
