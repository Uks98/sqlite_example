
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import '../data/data.dart';

class ClearList extends StatefulWidget {
  Future<Database> db;
   ClearList({Key? key,required this.db}) : super(key: key);

  @override
  State<ClearList> createState() => _ClearListState();
}

class _ClearListState extends State<ClearList> {
  late Future<List<Todo>> clearList;

  Future<List<Todo>> getClearList()async{
    final Database database = await widget.db;
    final List<Map<String, dynamic>> maps = await database.rawQuery('select title,content,id from todos where active = 1');
    print(maps);
    return List.generate(maps.length, (i) {
      return Todo(
          title: maps[i]["title"].toString(),
          content: maps[i]["content"].toString(),
          id: maps[i]["id"]
      );
    });
  }
  void deleteAllTodo()async{
    final Database database = await widget.db;
    database.rawDelete("delete from todos where id = 15");
    setState((){
      clearList = getClearList();
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    clearList = getClearList();
  }
  @override

  Widget build(BuildContext context) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title:
                    Text("완료한 일 삭제"),
                    content:  Text("완료한 일을 모두 삭제하시겠습니까?"),
                    actions: [
                      FlatButton(
                        onPressed: () {
                         deleteAllTodo();
                         Navigator.of(context).pop();
                        },
                        child: Text("예"),
                      ),
                      FlatButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("아니요"))
                    ],
                  );
                });

          },child: Icon(Icons.delete),
      ),
      appBar: AppBar(title: Text("완료한 일"),),
      body: Container(
        child: Center(
          child: FutureBuilder(
              future: clearList,
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
