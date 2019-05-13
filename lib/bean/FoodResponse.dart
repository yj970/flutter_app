class FoodResponse {
  String code;
  bool charge;
  String msg;
  Result result;

  FoodResponse({this.code, this.charge, this.msg, this.result});

  FoodResponse.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    charge = json['charge'];
    msg = json['msg'];
    result =
    json['result'] != null ? new Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['code'] = this.code;
    data['charge'] = this.charge;
    data['msg'] = this.msg;
    if (this.result != null) {
      data['result'] = this.result.toJson();
    }
    return data;
  }
}

class Result {
  int status;
  String msg;
  _Result result;

  Result({this.status, this.msg, this.result});

  Result.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    msg = json['msg'];
    result =
    json['result'] != null ? new _Result.fromJson(json['result']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['status'] = this.status;
    data['msg'] = this.msg;
    if (this.result != null) {
      data['result'] = this.result.toJson();
    }
    return data;
  }
}

class _Result {
  int num;
  List<Food> list;

  _Result({this.num, this.list});

  _Result.fromJson(Map<String, dynamic> json) {
    num = json['num'];
    if (json['list'] != null) {
      list = new List<Food>();
      json['list'].forEach((v) {
        list.add(new Food.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['num'] = this.num;
    if (this.list != null) {
      data['list'] = this.list.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Food {
  int id;
  int classid;
  String name;
  String peoplenum;
  String preparetime;
  String cookingtime;
  String content;
  String pic;
  String tag;
  List<Material> material;
  List<Process> process;

  Food(
      {this.id,
        this.classid,
        this.name,
        this.peoplenum,
        this.preparetime,
        this.cookingtime,
        this.content,
        this.pic,
        this.tag,
        this.material,
        this.process});

  Food.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    classid = json['classid'];
    name = json['name'];
    peoplenum = json['peoplenum'];
    preparetime = json['preparetime'];
    cookingtime = json['cookingtime'];
    content = json['content'];
    pic = json['pic'];
    tag = json['tag'];
    if (json['material'] != null) {
      material = new List<Material>();
      json['material'].forEach((v) {
        material.add(new Material.fromJson(v));
      });
    }
    if (json['process'] != null) {
      process = new List<Process>();
      json['process'].forEach((v) {
        process.add(new Process.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['classid'] = this.classid;
    data['name'] = this.name;
    data['peoplenum'] = this.peoplenum;
    data['preparetime'] = this.preparetime;
    data['cookingtime'] = this.cookingtime;
    data['content'] = this.content;
    data['pic'] = this.pic;
    data['tag'] = this.tag;
    if (this.material != null) {
      data['material'] = this.material.map((v) => v.toJson()).toList();
    }
    if (this.process != null) {
      data['process'] = this.process.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Material {
  String mname;
  int type;
  String amount;

  Material({this.mname, this.type, this.amount});

  Material.fromJson(Map<String, dynamic> json) {
    mname = json['mname'];
    type = json['type'];
    amount = json['amount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['mname'] = this.mname;
    data['type'] = this.type;
    data['amount'] = this.amount;
    return data;
  }
}

class Process {
  String pcontent;
  String pic;

  Process({this.pcontent, this.pic});

  Process.fromJson(Map<String, dynamic> json) {
    pcontent = json['pcontent'];
    pic = json['pic'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pcontent'] = this.pcontent;
    data['pic'] = this.pic;
    return data;
  }
}