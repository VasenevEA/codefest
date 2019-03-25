class Favs {
  List<Fav> favs;

  Favs({this.favs});

  Favs.fromJson(Map<String, dynamic> json) {
    if (json['favs'] != null) {
      favs = new List<Fav>();
      json['favs'].forEach((v) {
        favs.add(new Fav.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.favs != null) {
      data['favs'] = this.favs.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Fav {
  String areaName;
  String areaType;
  String startTime;

  Fav({this.areaName, this.areaType, this.startTime});

  Fav.fromJson(Map<String, dynamic> json) {
    areaName = json['areaName'];
    areaType = json['areaType'];
    startTime = json['startTime'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['areaName'] = this.areaName;
    data['areaType'] = this.areaType;
    data['startTime'] = this.startTime;
    return data;
  }
}