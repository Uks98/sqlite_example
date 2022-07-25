
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'data.dart';

class DBClass{
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
  Future<Database> get database => initDatabase();

  Future<List<Todo>> getTodos() async {
    final Database database = await initDatabase();
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
  Future<List<Todo>> insertTodo(Todo todo) async {
    final Database database = await initDatabase();
    await database.insert("todos", todo.toMap(),
        //id값 충돌시를 대비함
        conflictAlgorithm: ConflictAlgorithm.replace);
    return getTodos();
  }
  Future<List<Todo>> updateTodo(Todo todo) async {
    final Database database = await initDatabase();
    await database.update(
      "todos", todo.toMap(),
      where: "id = ?", // ?는 whereArgs 입력값 대응
      whereArgs: [todo.id],
    );
    return getTodos();
  }

  Future<List<Todo>> deleteTodo(int id)async{
    final Database database =  await initDatabase();
    await database.delete("todos",where: "id = ?",whereArgs: [id]);
     return getTodos();
  }
}