import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/data.dart';

class DataBaseApp extends StatefulWidget {
  final Future<Database> db;
  DataBaseApp({Key? key,required this.db}) : super(key: key);

  @override
  State<DataBaseApp> createState() => _DataBaseAppState();
}

class _DataBaseAppState extends State<DataBaseApp> {

  Future<List<Todo>> getTodos()async {
    final Database database = await widget.db;
    //query함수로 todos를 가져온다.
    final List<Map<String,dynamic>> maps = await database.query("todos");
    print(maps);
    return List.generate(maps.length, (index){
      bool activity = maps[index]["activity"] == 1 ? true : false;
      return Todo(
        title: maps[index]["title"].toString(),
        content: maps[index]["content"].toString(),
        active: activity,
        id: maps[index]["id"],
      );
    },
    );
  }
  late Future<List<Todo>> todoList;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoList = getTodos();
  }
  @override
  Widget build(BuildContext context) {

    void _insertTodo(Todo todo)async{
      final Database database = await widget.db;
      await database.insert("todos", todo.toMap(),
      //id값 충돌시를 대비함
      conflictAlgorithm: ConflictAlgorithm.replace);
      setState((){
        todoList = getTodos();
      });
    }



    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          final todo = await Navigator.of(context).pushNamed("/add");
          _insertTodo(todo as Todo);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(title: Text("dataBaseTodo"),),
      body: Container(
        child: Center(
          child: FutureBuilder(
              future: todoList,
              builder: (context,AsyncSnapshot snapshot){
            switch(snapshot.connectionState){
              case ConnectionState.none:
                return CircularProgressIndicator();
              case ConnectionState.waiting:
                return CircularProgressIndicator();
              case ConnectionState.active:
                return CircularProgressIndicator();
              case ConnectionState.done:
                if(snapshot.hasData){
                  return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder:(ctx,idx){
                    Todo todo = snapshot.data[idx];
                    return Card(
                      child: Column(children: [
                        Text(todo.title.toString()),
                        Text(todo.content.toString()),
                        Text(todo.active.toString()),
                      ],),
                    );
                  });
                }
                return CircularProgressIndicator();
            }
          }),
        ),
      ),
    );
  }
}
