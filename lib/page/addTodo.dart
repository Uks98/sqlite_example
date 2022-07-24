import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist_sqlite/data/data.dart';

class AddTodoPage extends StatefulWidget {
  final Future<Database> db;

  AddTodoPage({Key? key, required this.db}) : super(key: key);

  @override
  State<AddTodoPage> createState() => _AddTodoPageState();
}

class _AddTodoPageState extends State<AddTodoPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController memoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Todo 추가"),
      ),
      body: Container(
        child: Center(
          child: Column(
            children: [
              Padding(padding: EdgeInsets.all(10)),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "제목"),
              ),
              Padding(padding: EdgeInsets.all(10)),
              TextField(
                controller: memoController,
                decoration: InputDecoration(labelText: "할일"),
              ),
              ElevatedButton(
                  onPressed: () {
                    Todo todo = Todo(
                      title: titleController.text,
                      content: memoController.text,
                      active: false,
                    );
                    Navigator.of(context).pop(todo);
                  },
                  child: Text("저장하기"))
            ],
          ),
        ),
      ),
    );
  }
}
