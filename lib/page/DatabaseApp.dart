import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist_sqlite/data/sqclass.dart';

import '../data/data.dart';

class DataBaseApp extends StatefulWidget {
  final Future<Database> db;

  DataBaseApp({Key? key, required this.db}) : super(key: key);

  @override
  State<DataBaseApp> createState() => _DataBaseAppState();
}

class _DataBaseAppState extends State<DataBaseApp> {
  late Future<List<Todo>> todoList;
  DBClass dbClass = DBClass();

  void deleteTodo(int id)async{
    Database database = await widget.db;
    await database.delete("todos",where: "id = ?",whereArgs: [id]);
    setState((){
      todoList = dbClass.getTodos();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoList = dbClass.getTodos();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final todo = await Navigator.of(context).pushNamed("/add");
          dbClass.insertTodo(todo as Todo);
          setState((){
            todoList = dbClass.getTodos();
          });
          //_insertTodo(todo as Todo);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("dataBaseTodo"),
        actions: [
          TextButton(onPressed: ()async{
              await Navigator.of(context).pushNamed("/clear");
              setState((){
                todoList = dbClass.getTodos();
              });
          }, child: Text("완료한 일",style: TextStyle(color: Colors.white),),),
        ],
      ),
      body: Container(
        child: Center(
          child: FutureBuilder(
              future: todoList,
              builder: (context, AsyncSnapshot snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return CircularProgressIndicator();
                  case ConnectionState.waiting:
                    return CircularProgressIndicator();
                  case ConnectionState.active:
                    return CircularProgressIndicator();
                  case ConnectionState.done:
                    if (snapshot.hasData) {
                      return ListView.builder(
                          itemCount: snapshot.data.length,
                          itemBuilder: (ctx, idx) {
                            Todo todo = snapshot.data[idx];
                            return ListTile(
                              onLongPress: ()async{
                                   Todo result = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                        Text("${todo.id} : ${todo.title}"),
                                        content:  Text("${todo.content}를 삭제하시겠습니까?"),
                                        actions: [
                                          FlatButton(
                                            onPressed: () {
                                              dbClass.deleteTodo(todo.id!);
                                              setState((){
                                                todoList = dbClass.getTodos();
                                              });
                                              Navigator.of(context).pop(todo);
                                            },
                                            child: Text("예"),
                                          ),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(todo);
                                              },
                                              child: Text("아니요"))
                                        ],
                                      );
                                    });
                                  if(result != null){
                                  //deleteTodo(result);
                                  }
                              },
                              onTap: () async {
                                TextEditingController controller =
                                    TextEditingController(
                                        text: todo.content); // 기존 내용 남기기
                                Todo result = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title:
                                            Text("${todo.id} : ${todo.title}"),
                                        content: TextField(
                                          controller: controller,
                                          keyboardType: TextInputType.text,
                                        ),
                                        actions: [
                                          FlatButton(
                                            onPressed: () {
                                              todo.active == true
                                                  ? todo.active = false
                                                  : todo.active = true;
                                              todo.content = controller.text;
                                              Navigator.of(context).pop(todo);
                                            },
                                            child: Text("예"),
                                          ),
                                          FlatButton(
                                              onPressed: () {
                                                Navigator.of(context).pop(todo);
                                              },
                                              child: Text("아니요"))
                                        ],
                                      );
                                    });
                                if (result != null) {
                                  dbClass.updateTodo(result);
                                  setState((){
                                    todoList = dbClass.getTodos();
                                  });
                                }
                              },
                              title: Text(
                                todo.title.toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                              subtitle: Container(
                                child: Column(
                                  children: [
                                    Text(todo.content.toString()),
                                    Text("체크 : ${todo.active.toString()}"),
                                    Container(
                                      height: 1,
                                      color: Colors.blue,
                                    )
                                  ],
                                ),
                              ),
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
