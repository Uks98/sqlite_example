import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/data.dart';

class DataBaseApp extends StatefulWidget {
  final Future<Database> db;

  DataBaseApp({Key? key, required this.db}) : super(key: key);

  @override
  State<DataBaseApp> createState() => _DataBaseAppState();
}

class _DataBaseAppState extends State<DataBaseApp> {
  late Future<List<Todo>> todoList;

  Future<List<Todo>> getTodos() async {
    final Database database = await widget.db;
    //query함수로 todos를 가져온다.
    final List<Map<String, dynamic>> maps = await database.query("todos");
    print(maps);
    return List.generate(
      maps.length,
      (index) {
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


  void updateTodo(Todo todo) async {
    final Database database = await widget.db;
    await database.update(
      "todos", todo.toMap(),
      where: "id = ?", // ?는 whereArgs 입력값 대응
      whereArgs: [todo.id],
    );
    setState(() {
      todoList = getTodos();
    });
  }
  void _insertTodo(Todo todo) async {
    final Database database = await widget.db;
    await database.insert("todos", todo.toMap(),
        //id값 충돌시를 대비함
        conflictAlgorithm: ConflictAlgorithm.replace);
    setState(() {
      todoList = getTodos();
    });
  }
  void deleteTodo(int id)async{
    Database database = await widget.db;
    await database.delete("todos",where: "id = ?",whereArgs: [id]);
    setState((){
      todoList = getTodos();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    todoList = getTodos();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final todo = await Navigator.of(context).pushNamed("/add");
          _insertTodo(todo as Todo);
        },
        child: Icon(Icons.add),
      ),
      appBar: AppBar(
        title: Text("dataBaseTodo"),
        actions: [
          TextButton(onPressed: ()async{
              await Navigator.of(context).pushNamed("/clear");
              setState((){
                todoList = getTodos();
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
                                              deleteTodo(todo.id!);
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
                                  updateTodo(result);
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
