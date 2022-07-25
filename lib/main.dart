import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todolist_sqlite/page/DatabaseApp.dart';
import 'package:todolist_sqlite/page/addTodo.dart';
import 'package:todolist_sqlite/page/clearList.dart';

import 'data/data.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //데이터 베이스를 열어서 반환해주는 함수
    //데이터 베이스는 getDatabasesPath경로에 todo_database.db로 저장되어있다.
    Future<Database> initDatabase()async{
      return openDatabase(
        join(await getDatabasesPath(), "todo_database.db"),
        onCreate: (db,version){
          return db.execute(
            "CREATE TABLE todos(id INTEGER PRIMARY KEY AUTOINCREMENT,"
                "title TEXT,content TEXT, activity BOOL)",
          );
        },
        version: 1,
      );
    }
    Future<Database> database = initDatabase();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity
      ),
      initialRoute: "/",
      routes: {
        "/": (context) => DataBaseApp(db: database,),
        "/add":(context) => AddTodoPage(db: database),
        "/clear":(context)=> ClearList(db:database),
      },
      //home: DataBaseApp(),
    );
  }
}
