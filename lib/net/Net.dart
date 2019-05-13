import 'dart:io';
import 'dart:convert';

import 'package:flutter_app/bean/FoodResponse.dart';

class net {
  final String _url = "way.jd.com";
  final String _searchFood = "/jisuapi/search";
  final String _key = "7421eacac1068d7d1206210ad988ddf8";
  final String _num = "20";
  // 搜索菜
  Future<FoodResponse> searchFood(String name) async{
    var httpClient = new HttpClient();
    // http用 Uri.http
    var uri = new Uri.https(
        _url, _searchFood, {'keyword':'$name','num':'$_num','appkey':'$_key'});
    var request = await httpClient.getUrl(uri);
    var response = await request.close();
    var responseBody = await response.transform(utf8.decoder).join();
    String j = responseBody.toString();
//    print('$j');
    FoodResponse res = await FoodResponse.fromJson(json.decode(responseBody.toString()));
    return res;
  }
}