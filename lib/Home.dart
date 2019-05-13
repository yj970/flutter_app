import 'package:flutter/material.dart';
import 'package:flutter_app/FoodDetail.dart';
import 'package:flutter_app/bean/FoodResponse.dart';
import 'package:flutter_app/event/FoodResponseEvent.dart';
import 'package:flutter_app/event/SearchEvent.dart';
import 'package:flutter_app/net/Net.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

EventBus eventBus = new EventBus();
String searchKey = "";
void main() {
  runApp(new App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      theme: new ThemeData(primarySwatch: Colors.yellow),
      home: new HomeWidget(),
    );
  }
}

class HomeWidget extends StatefulWidget {
  @override
  HomeState createState() {
    return new HomeState();
  }
}

class HomeState extends State<HomeWidget> {
  int selected = 0; // 0首页，1记录
  PageController pageController = new PageController();
  Size size;

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(selected == 0 ? '搜索' : '收藏'),
      ),
      body: new Container(
        color: Colors.white,
        child: new Column(
          children: <Widget>[
            new Expanded(
                child: new PageView.builder(
                    itemCount: 2,
                    controller: pageController,
                    onPageChanged: (position) => {
                          selected = position
//                          setState(() {
//                            selected = position;
//                          })
                        },
                    itemBuilder: (BuildContext context, int position) =>
                        position == 0
                            ? new MainWidget()
                            : new StarGirdWidget())),
            new Container(
              color: Colors.grey,
              width: size.width,
              height: 0.1,
            ),
            new Container(
              height: 50,
              width: size.width,
              child: new Row(
                children: <Widget>[
                  new Expanded(
                      child: new GestureDetector(
                    onTap: () {
                      pageController.jumpToPage(0);
                      selected = 0;
                    },
                    child: new Center(
                        child: new Icon(
                      Icons.home,
                      color: selected == 0 ? Colors.yellow : Colors.grey,
                    )),
                  )),
                  new Expanded(
                      child: new GestureDetector(
                    onTap: () {
                      pageController.jumpToPage(1);
                      selected = 1;
                    },
                    child: new Center(
                        child: new Icon(
                      Icons.list,
                      color: selected == 1 ? Colors.yellow : Colors.grey,
                    )),
                  )),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  @override
  MainState createState() {
    return new MainState();
  }
}

class MainState extends State<StatefulWidget> {
  @override
  Widget build(BuildContext context) {
    return new Column(
      children: <Widget>[new SearchWidget(), new FoodListWidget()],
    );
  }
}

class FoodListWidget extends StatefulWidget {
  @override
  FoodListState createState() {
    return new FoodListState();
  }
}

class FoodListState extends State<StatefulWidget> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  int itemCount = 0;
  List<Food> list;
  Map<String, dynamic> starMap;

  @override
  void initState() {
    eventBus.on<FoodResponseEvent>().listen((FoodResponseEvent event) => {
          setState(() {
            getStar(); // 耗时操作，可能会造成卡顿。
            itemCount = event.foodResponse.result.result.num;
            list = event.foodResponse.result.result.list;
          })
        });

    eventBus.on<SearchEvent>().listen((SearchEvent event) {
      switch (event.state) {
        case 0:
          // 部件构建完毕回调
          SchedulerBinding.instance.addPostFrameCallback((_) {
            _refreshIndicatorKey.currentState?.show();
          });
          break;
      }
    });

    super.initState();
  }

  // 获取收藏菜的id列表
  getStar() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("stars") != null) {
      String stars = sharedPreferences.getString("stars");
      starMap = json.decode(stars);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Expanded(
        child: new RefreshIndicator(
            key: _refreshIndicatorKey,
            child: new ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int position) =>
                    new FoodCardWidget(list[position], isStar(position))),
            onRefresh: onSearch));
  }

  bool isStar(int position) {
    return starMap[list[position].id.toString()] != null;
  }
}

class FoodCardWidget extends StatelessWidget {
  Food food;
  bool isStar;

  FoodCardWidget(this.food, this.isStar);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: new GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return new FoodDetailWidget(food);
          }));
        },
        child: new Card(
          elevation: 4,
          child: new Container(
            padding: const EdgeInsets.all(5),
            width: 200,
            height: 120,
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Image.network(
                  food.pic,
                  width: 180,
                  height: 70,
                  fit: BoxFit.fill,
                ),
                new Container(
                  padding: const EdgeInsets.only(top: 10, right: 5),
                  child: new Row(
                    children: <Widget>[
                      new Expanded(
                          child: new Text(
                        food.name,
                        style: new TextStyle(color: Colors.black),
                      )),
                      new Icon(Icons.star,
                          color: isStar ? Colors.pink : Colors.grey)
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SearchWidget extends StatefulWidget {
  @override
  SearchState createState() {
    return new SearchState();
  }
}

class SearchState extends State<SearchWidget> {
  @override
  Widget build(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    return new TextField(
        controller: _controller, // 控制器, 操控TextField
        textInputAction: TextInputAction.search, // 软键盘图标变为“查询”按钮
        decoration: InputDecoration(
            // 装饰输入框
            contentPadding: EdgeInsets.all(10), // 边距
            labelText: '输入菜名', // hint内容
            helperText: '点击软键盘查询按钮进行搜索', // 输入框下发内容
            icon: Icon(Icons.search, color: Colors.amber) // 输入框左边图案
            ),
        onChanged: (value) => {
              // 内容发生改变时触发
            },
        onSubmitted: (String value) {
          searchKey = value;
          eventBus.fire(SearchEvent(0));
        });
  }
}

// 查询菜名
Future<Null> onSearch() async {
  String value = searchKey;
  if (value.length == 0) {
    return null;
  }
  FoodResponse f = await new net().searchFood(value);
  if (f.code == '10000') {
    eventBus.fire(FoodResponseEvent(f));
  } else {
    String msg = f.msg;
    Fluttertoast.showToast(
        msg: "$msg",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.grey,
        textColor: Colors.white);
  }
}

class StarGirdWidget extends StatefulWidget {
  @override
  StarGirdState createState() {
    return new StarGirdState();
  }
}

class StarGirdState extends State<StarGirdWidget> {
  Map<String, dynamic> starMap;

  @override
  void initState() {
    getStar();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new GridView.count(
        crossAxisCount: 2,
        children: buildGirdItem(),
        crossAxisSpacing: 15, // 横向间隔
        mainAxisSpacing: 15, // 纵向间隔
      ),
      padding: EdgeInsets.all(10),
    );
  }

  // 获取收藏菜的id列表
  getStar() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getString("stars") != null) {
      String stars = sharedPreferences.getString("stars");
      starMap = json.decode(stars);
      setState(() {});
    }
  }

  List<Widget> buildGirdItem() {
    List<Widget> list = new List();

    if (starMap != null) {
      for (var value in starMap.values) {
        list.add(new GirdItemWidget(Food.fromJson(value)));
      }
    }
    return list;
  }
}

class GirdItemWidget extends StatelessWidget {
  Food food;

  GirdItemWidget(this.food);

  @override
  Widget build(BuildContext context) {
    return new GestureDetector(
        child: new Container(
            child: new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Image.network(
                  food.pic,
                  width: 200,
                  height: 150,
                ),
                new Text(
                  food.name,
                  style: new TextStyle(fontSize: 18),
                )
              ],
            ),
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.pink, width: 0.5), // 边色与边宽度
              shape: BoxShape.rectangle, // 默认值也是矩形
              borderRadius: new BorderRadius.circular((20.0)), // 圆角度
            )),
        onTap: () {
          Navigator.of(context)
              .push(new MaterialPageRoute(builder: (BuildContext context) {
            return new FoodDetailWidget(food);
          }));
        });
  }
}
