import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/database/database_todo.dart';
import 'package:flutter_application_1/server/ApiRequests.dart';
//import 'package:sqflite/sqflite.dart';


import '../model/Todo.dart';


class EditTodo extends StatefulWidget {
  final Todo todo;

  EditTodo({required this.todo});

  @override
  _EditTodoState createState() => _EditTodoState();
}

class _EditTodoState extends State<EditTodo> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController timeController = TextEditingController();
  final TextEditingController detailsController = TextEditingController();
  final TextEditingController goalController = TextEditingController();
  final TextEditingController emotionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.todo.title;
    timeController.text = widget.todo.time;
    detailsController.text = widget.todo.details;
    goalController.text = widget.todo.goal;
    emotionController.text = widget.todo.emotion;
  }

  Future<void> deleteTodoOnServer(int todoId) async {
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 0, 201, 191),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Color.fromARGB(255, 0, 195, 10),
        title: Text('Edit Todo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
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
                  final editedTodo = Todo(
                    id: widget.todo.id,
                    title: titleController.text,
                    time: timeController.text,
                    details: detailsController.text,
                    goal: goalController.text,
                    emotion: emotionController.text,
                  );

                  var result = 0;

                  try {
                    await ApiRequests.putRequest(
                      '/update',
                      editedTodo.toMap(),
                    ).timeout(
                      Duration(seconds: 2),
                      onTimeout: () {
                        throw TimeoutException('The request to the server timed out');
                      },
                    );

                    result = await DatabaseTodo.instance.updateTodo(editedTodo);
                    final uId = editedTodo.id;
                    print("Updated todo id: $uId");
                  } catch (e) {
                    print("Error when trying to update todo on the server or timeout: $e");

                    result = await DatabaseTodo.instance.updateTodo(editedTodo);
                    final uId = editedTodo.id;
                    if (result != 0) {
                      print("Successfully updated todo locally: $uId");

                      Map<String, dynamic> editedTodoMap = editedTodo.toMap();

                      String body = jsonEncode(editedTodoMap);

                      await DatabaseTodo.instance.cacheRequest('put', body);
                      print("Successfully cached update request for todo id: $uId");
                    }
                  }

                  if (result != 0) {
                    Navigator.pop(context, editedTodo);
                  } else {
                    print("Error when trying to update todo locally");
                  }

                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Todo updated successfully'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF023047)),
                child: Text('Save Changes'),
              ),

              ElevatedButton(
                onPressed: () async {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Delete Todo'),
                      content: Text('Are you sure you want to delete this todo? This action cannot be undone!'),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Cancel'),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                        TextButton(
                          child: Text('Delete'),
                          onPressed: () async {
                            final idToDelete = widget.todo.id;
                            var result = 0;

                            try {
                              await ApiRequests.deleteRequest(
                                '/delete/$idToDelete',
                              ).timeout(
                                Duration(seconds: 2),
                                onTimeout: () {
                                  throw TimeoutException('The request to the server timed out');
                                },
                              );

                              result = await DatabaseTodo.instance.deleteTodo(widget.todo.id);
                              print("Deleted todo: $idToDelete");
                            } catch (e) {
                              print("Error when trying to delete todo on the server or timeout: $e");

                              result = await DatabaseTodo.instance.deleteTodo(widget.todo.id);

                              if (result != 0) {
                                print("Successfully deleted todo locally with id: $idToDelete");

                                await DatabaseTodo.instance.cacheRequest('delete', jsonEncode({'id': idToDelete}));

                                print("Successfully cached delete request for todo id: $idToDelete");
                              }
                            }

                            if (result != 0) {
                              Navigator.pop(context, widget.todo.id);
                              Navigator.pop(context, widget.todo.id);
                            } else {
                              print("Error when trying to delete todo");
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Error'),
                                  content: Text('Failed to delete the todo. Please try again.'),
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
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF023047)),
                child: Text('Delete Todo'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
