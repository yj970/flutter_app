import 'package:flutter/material.dart';
import 'package:flutter_app/bean/FoodResponse.dart'
    as FoodResponse;
import 'package:shared_preferences/shared_preferences.dart'; // 使用别名，因为Material类名冲突
import 'dart:convert';


FoodResponse.Food food;
Size size;
Map<String,dynamic> starMap;

class FoodDetailWidget extends StatefulWidget {
  FoodDetailWidget(FoodResponse.Food f) {
    food = f;
  }

  @override
  FoodDetailState createState() {
    return new FoodDetailState();
  }
}

class FoodDetailState extends State<FoodDetailWidget> {
  String foodName;
  FoodDetailState() {
    foodName = food.name;
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;

    return new Scaffold(
      appBar: new AppBar(
        title: new Text('$foodName'),
        leading: new Container(
          padding: EdgeInsets.all(10),
          child: new GestureDetector(
            child: new Image.asset(
              'images/back.png',
              fit: BoxFit.fill,
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: new Column(
        children: <Widget>[new FoodHeadWidget(), new FoodBodyWidget()],
      ),
    );
  }
}

class FoodHeadWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[new FoodIntroduceWidget(), new FoodMaterialWidget()],
    );
  }
}

class FoodIntroduceWidget extends StatelessWidget {
  String introduce;
  @override
  Widget build(BuildContext context) {
    return new Container(
      child: Column(
        children: <Widget>[
          new Text(
            '$introduce',
            style: new TextStyle(fontSize: 17),
          ),
          new StarWidget()
        ],
      ),
      padding: const EdgeInsets.all(10),
      decoration:
          new UnderlineTabIndicator(borderSide: new BorderSide(width: 0.1)),
    );
  }

  FoodIntroduceWidget() {
    introduce = food.content;
  }
}

class StarWidget extends StatefulWidget {
  @override
  StarState createState() {
    return new StarState();
  }
}


// 保存、移除收藏的菜
saveStarIds(bool isStar, String id) async {
  if (starMap == null) {
    starMap = new Map();
  }
  if (!isStar) {
    starMap['$id']=null;
  } else {
    starMap['$id']=food;
  }
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
  await sharedPreferences.setString("stars", json.encode(starMap));
}




class StarState extends State<StarWidget> {
  bool star = false;

  @override
  void initState() {
    getStar();
    super.initState();
  }

  // 获取收藏菜的id列表
  getStar() async{
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("stars") != null) {
      String stars = sharedPreferences.getString("stars");
      if (stars != null) {
          starMap = json.decode(stars);
          if (starMap[food.id.toString()]!=null) {
            star = true;
          }
      }
      setState(() {
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(padding: EdgeInsets.only(top: 10),child: new GestureDetector(
        onTap: () {
          setState(() {
            star = !star;
            saveStarIds(star, food.id.toString());
          });
        },
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            new Text(
              '收藏',
              style: new TextStyle(fontSize: 20),
            ),
            new Icon(
              Icons.star,
              color: star ? Colors.pink : Colors.grey,
            )
          ],
        )),);
  }
}

class FoodMaterialWidget extends StatelessWidget {
  StringBuffer material = new StringBuffer();

  FoodMaterialWidget() {
    List<FoodResponse.Material> m = food.material;
    for (int i = 0; i < m.length; i++) {
      material.write(m[i].mname + '(' + m[i].amount + ')' + '  ');
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            '材料',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          new Text(
            '$material',
            style: new TextStyle(fontSize: 17),
          ),
        ],
      ),
      padding: const EdgeInsets.all(10),
    );
  }
}

class FoodBodyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Expanded(
        child: new Container(
      padding: EdgeInsets.all(10),
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Text(
            '做法',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
          ),
          new Expanded(
              child: new ListView.builder(
                  itemCount: food.process.length,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int position) {
                    return new ProcessWidget(food.process[position]);
                  })),
        ],
      ),
    ));
  }
}

class ProcessWidget extends StatelessWidget {
  FoodResponse.Process process;

  ProcessWidget(this.process);

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: EdgeInsets.only(top: 5),
      child: new Row(
        children: <Widget>[
          new Image.network(
            process.pic,
            width: 200,
            height: 100,
          ),
          new Expanded(child: new Text(
            process.pcontent,
            style: new TextStyle(fontSize: 17),softWrap: true,overflow: TextOverflow.ellipsis,
          ))
        ],
      ),
    );
  }
}
