
class Todo{
  String? title;
  String? content;
  bool? active;
  int? id;
  Todo({this.title,this.content,this.active,this.id});

  //데이터를 map형태로 변환해준다.
  Map<String,dynamic> toMap(){
    return {
      "id": id,
      "title":title,
      "activity":active,
      "content" : content,
    };
  }
}