import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/Conference.dart';

Future<String> loadSpeakers() async {
  try {
    return await rootBundle.loadString('resources/speaches.json');
  } catch (_) {
    debugPrint(_);
    return null;
  }
}

List<Speach> items;
_onTimeout() => print("Time Out occurs");

void main() {
  debugPrint("Started");
  var str = loadSpeakers();
  str.then((s) => stringeToConference(s));
  str.catchError((err) => debugPrint("fail"));
  str.timeout(const Duration(seconds: 5), onTimeout: () => _onTimeout());
}

Conference conf;
List<Speach> stringeToConference(String s) {
  var res = jsonDecode(s);
  conf = Conference.fromJson(res);

  var list = new List<Speach>();

  for (var i = 0; i < conf.speaches.length; i++) {
    var speach = conf.speaches[i];

    var url =
        "https://pbs.twimg.com/profile_images/1069836563964678145/SflnPD2C_400x400.jpg";
    if (speach.speakers != null) {
      var speaker = speach.speakers.first;
      url = speaker?.faceImageSource;
    }
    list.add(new Speach(speach.speachTesis,
        DateTime.parse(speach.speachStartTime), speach.speakers));
  }
  items = list;
  runApp(MyApp(
    items: items,
  ));

  _verticalScrollController.addListener(verticalScrollListener);

  _scrollController.addListener(scrollListener);
  return list;
}

void verticalScrollListener() {
  for (var i = 0; i < _scrollController.positions.length; i++) {
    try {
      if (lastPixels != _scrollController.positions.elementAt(i).pixels) {
        _scrollController.positions.elementAt(i).moveTo(lastPixels);
      }
    } catch (e) {}
  }
}

double lastPixels;
void scrollListener() {
  var pixels = _scrollController.positions.first.pixels;

  var index = 0;
  for (var i = 0; i < _scrollController.positions.length; i++) {
    if (_scrollController.positions.elementAt(i).isScrollingNotifier.value ==
        true) {
      pixels = _scrollController.positions.elementAt(i).pixels;
      index = i;
      lastPixels = pixels;
      break;
    }
  }

  for (var i = 0; i < _scrollController.positions.length; i++) {
    if (i != index) {
      _scrollController.positions.elementAt(i).moveTo(pixels);
    }
  }
}

class MyApp extends StatelessWidget {
  List<Speach> items;

  MyApp({Key key, @required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = 'Mixed List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: ListView.builder(
          controller: _verticalScrollController,
          physics: ClampingScrollPhysics(),
          // Let the ListView know how many items it needs to build
          itemCount: 54,
          // Provide a builder function. This is where the magic happens! We'll
          // convert each item into a Widget based on the type of item it is.
          itemBuilder: (context, index) {
            return _buildHorizontalList(items[index]);
          },
        ),
      ),
    );
  }
}

ScrollController _scrollController = new ScrollController();
ScrollController _verticalScrollController = new ScrollController();

Widget _buildItem(Speach speach) {
  var card = new Card(
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
    children: <Widget>[
      createSpeakers(speach.speakers),
      new Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0), child: 
      new SizedBox(
        width: 200.0,
        child: new Text(speach.tesis),
      ))

    ],
  ));
  return card;
}

Widget createSpeakers(List<Speakers> speakers) {
  if (speakers == null) {
    var container = new Container(
        width: 40.0,
        height: 40.0,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image:
                    new NetworkImage("https://pbs.twimg.com/profile_images/1069836563964678145/SflnPD2C_400x400.jpg"))));
    return container;
  }

  List<Widget> list = new List<Widget>();
  for (var i = 0; i < speakers.length; i++) {
    var container = new Container(
        width: 40.0,
        height: 40.0,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image:
                    new NetworkImage(speakers.elementAt(i).faceImageSource))));

    var row = new Row(
      children: <Widget>[
        container,
        new Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
            child: new SizedBox(
              width: 150.0,
              child: new Text(speakers[i].name),
            )),
      ],
    );
    list.add(row);
  }
  return new Column(
    children: list,
  );
}

Widget _buildHorizontalList(Speach speach) {
  double height = 150;
  return Column(
    children: <Widget>[
      new Text(
          speach.startTime.hour.toString() +
              ":" +
              speach.startTime.minute.toString(),
          textScaleFactor: 2),
      new Container(
          height: height,
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: 9,
              itemBuilder: (BuildContext content, int index) {
                return _buildItem(speach);
              }))
    ],
  );
}

// The base class for the different types of items the List can contain
abstract class ListItem {}

// A ListItem that contains data to display a heading
class HeadingItem implements ListItem {
  final String heading;

  HeadingItem(this.heading);
}

// A ListItem that contains data to display a message
class MessageItem implements ListItem {
  final String sender;
  final String body;

  MessageItem(this.sender, this.body);
}

class Speach {
  final String tesis;
  final DateTime startTime;
  final List<Speakers> speakers;

  Speach(this.tesis, this.startTime, this.speakers);
}
