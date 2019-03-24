class Conference {
  List<Speaches> speaches;
  List<Section> sectionsFirstDay;
  List<Section> sectionsSecondDay;

  Conference({this.speaches, this.sectionsFirstDay, this.sectionsSecondDay});

  Conference.fromJson(Map<String, dynamic> json) {
    if (json['Speaches'] != null) {
      speaches = new List<Speaches>();
      json['Speaches'].forEach((v) {
        speaches.add(new Speaches.fromJson(v));
      });
    }
    if (json['SectionsFirstDay'] != null) {
      sectionsFirstDay = new List<Section>();
      json['SectionsFirstDay'].forEach((v) {
        sectionsFirstDay.add(new Section.fromJson(v));
      });
    }
    if (json['SectionsSecondDay'] != null) {
      sectionsSecondDay = new List<Section>();
      json['SectionsSecondDay'].forEach((v) {
        sectionsSecondDay.add(new Section.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.speaches != null) {
      data['Speaches'] = this.speaches.map((v) => v.toJson()).toList();
    }
    if (this.sectionsFirstDay != null) {
      data['SectionsFirstDay'] =
          this.sectionsFirstDay.map((v) => v.toJson()).toList();
    }
    if (this.sectionsSecondDay != null) {
      data['SectionsSecondDay'] =
          this.sectionsSecondDay.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Speaches {
  List<Speakers> speakers;
  String areaName;
  String areaType;
  String speachStartTime;
  String speachTesis;
  Null speachDescription;
  Null aboutUser;
  String speachUrl;

  Speaches(
      {this.speakers,
      this.areaName,
      this.areaType,
      this.speachStartTime,
      this.speachTesis,
      this.speachDescription,
      this.aboutUser,
      this.speachUrl});

  Speaches.fromJson(Map<String, dynamic> json) {
    if (json['Speakers'] != null) {
      speakers = new List<Speakers>();
      json['Speakers'].forEach((v) {
        speakers.add(new Speakers.fromJson(v));
      });
    }
    areaName = json['AreaName'];
    areaType = json['AreaType'];
    speachStartTime = json['SpeachStartTime'];
    speachTesis = json['SpeachTesis'];
    speachDescription = json['SpeachDescription'];
    aboutUser = json['AboutUser'];
    speachUrl = json['SpeachUrl'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.speakers != null) {
      data['Speakers'] = this.speakers.map((v) => v.toJson()).toList();
    }
    data['AreaName'] = this.areaName;
    data['AreaType'] = this.areaType;
    data['SpeachStartTime'] = this.speachStartTime;
    data['SpeachTesis'] = this.speachTesis;
    data['SpeachDescription'] = this.speachDescription;
    data['AboutUser'] = this.aboutUser;
    data['SpeachUrl'] = this.speachUrl;
    return data;
  }
}

class Speakers {
  String name;
  Null surName;
  String company;
  Null position;
  String faceImageSource;

  Speakers(
      {this.name,
      this.surName,
      this.company,
      this.position,
      this.faceImageSource});

  Speakers.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    surName = json['SurName'];
    company = json['Company'];
    position = json['Position'];
    faceImageSource = json['FaceImageSource'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['SurName'] = this.surName;
    data['Company'] = this.company;
    data['Position'] = this.position;
    data['FaceImageSource'] = this.faceImageSource;
    return data;
  }
}

class Section {
  String name;
  String areaName;

  Section(this.name, this.areaName);

  Section.fromJson(Map<String, dynamic> json) {
    name = json['Name'];
    areaName = json['AreaName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Name'] = this.name;
    data['AreaName'] = this.areaName;
    return data;
  }
}
