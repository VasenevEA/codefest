import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/Conference.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';


Future<String> loadSpeakers() async {
  try {
    return await rootBundle.loadString('resources/speaches.json');
  } catch (_) {
    debugPrint(_);
    return null;
  }
}

List<SpeachTimeItem> items;
List<Section> headerSections = new List<Section>();

_onTimeout() => print("Time Out occurs");

void main() {
  debugPrint("Started");
  var str = loadSpeakers();
  str.then((s) => stringeToConference(s));
  str.catchError((err) => debugPrint("fail"));
  str.timeout(const Duration(seconds: 5), onTimeout: () => _onTimeout());
}

Conference conf;
List<SpeachTimeItem> stringeToConference(String s) {
  var res = jsonDecode(s);
  conf = Conference.fromJson(res);
  for (var i = 0; i < conf.sectionsFirstDay.length; i++) {
    headerSections.add(new Section(conf.sectionsFirstDay[i].name, conf.sectionsFirstDay[i].areaName));
  }


 
  var list = new List<SpeachItem>();

  for (var i = 0; i < conf.speaches.length; i++) {
    var speach = conf.speaches[i];

    var url =
        "https://pbs.twimg.com/profile_images/1069836563964678145/SflnPD2C_400x400.jpg";
    if (speach.speakers != null) {
      var speaker = speach.speakers.first;
      url = speaker?.faceImageSource;
    }
    list.add(new SpeachItem(speach.speachTesis,
        DateTime.parse(speach.speachStartTime), speach.speakers, new SectionItem("", "")));
  }


  _scrollController.addListener(scrollListener);

  var times = getAllTimes(conf.speaches);
  var allSpeaches = getAllSpeachesPerDay(conf.speaches, times, conf.sectionsFirstDay, conf.sectionsSecondDay);

  
  items = allSpeaches;
  runApp(MyApp(allSpeaches));
  return allSpeaches;
}



double itemHeight = 150;


int firstVisibleVerticalItem = 0;

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
ListView lv;
class MyApp extends StatefulWidget {
  
 List<SpeachTimeItem> items; 
  MyApp(this.items);
   final title = 'Mixed List';

  @override
  MyAppState createState() => new MyAppState(items);
}



class MyAppState extends   State<MyApp>
{
List<SpeachTimeItem> items;

void Test()
{
  
}

void verticalScrollListener() {
  for (var i = 0; i < _scrollController.positions.length; i++) {
    try {
      if (lastPixels != _scrollController.positions.elementAt(i).pixels) {
        _scrollController.positions.elementAt(i).moveTo(lastPixels);
      }
    } catch (e) {}
  }
  
  firstVisibleVerticalItem = (_verticalScrollController.position.pixels/ itemHeight).round();

 var listSections = new List<Section>();
    if (items[firstVisibleVerticalItem].startTime.day == 30) {
      
    listSections = conf.sectionsFirstDay;
    }
    else  
    {
    listSections = conf.sectionsSecondDay;
    } 

    for (var i = 0; i < headerSections.length; i++) {
      headerSections[i].name = listSections[i].name;
      headerSections[i].areaName = listSections[i].areaName;
    }
  setState(() {
    
  });

  }

  MyAppState(this.items);

  @override
  Widget build(BuildContext context) {

  _verticalScrollController.addListener(verticalScrollListener);
 lv= ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: headerSections.length,
                controller: _scrollController,
                itemBuilder: (context, index) {

                  return new Container(
                    width: 215,
                    child: new Column(children: <Widget>[
                      
                      Text(headerSections[index].name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
                      new Container( 
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFEAC2C9),
        shape: BoxShape.rectangle),
        child: new Padding(child: Text(headerSections[index].areaName), padding: EdgeInsetsDirectional.fromSTEB(5,0,5,0)),
        )
        ]
                    ));
                },
              );
    return MaterialApp(
      title: widget.title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          backgroundColor: Colors.white,
          leading:  new Container(
        width: 40.0,
        height: 40.0,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fill,
                image:
                    new NetworkImage("https://pbs.twimg.com/profile_images/1069836563964678145/SflnPD2C_400x400.jpg")))),
        ),
        body: new Column(
          children: <Widget>[
             new Container (
                height: 40,
                child:
              lv),
            new Expanded(
              child: ListView.builder(
          controller: _verticalScrollController,
          physics: ClampingScrollPhysics(),
          // Let the ListView know how many items it needs to build
          itemCount: items.length,
          // Provide a builder function. This is where the magic happens! We'll
          // convert each item into a Widget based on the type of item it is.
          itemBuilder: (context, index) {
            return _buildHorizontalList(items[index],index);
          },
        ),
            )
          ],
        ),
      ),
    );
  }
}




ScrollController _scrollController = new ScrollController();
ScrollController _verticalScrollController = new ScrollController();
 
Widget _buildItem(List<SpeachItem> speach, int index) {

  
  var text = new Text(speach[index].section.areaName);
  debugPrint(speach[index].isEnableShowHeader.toString());
  if(speach[index].isEnableShowHeader)
  {
    text = new Text("");
  }
  var card = new Card(
      child: Column(
        mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
    children: <Widget>[
    text,
      createSpeakers(speach[index].speakers),
      new Padding(padding: EdgeInsets.fromLTRB(5, 0, 0, 0), child: 
      new SizedBox(
        width: 200.0,
        child: new Text(speach[index].tesis),
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

    var speaker = new Row(
      children: <Widget>[
        container,
        new Padding(
            padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
        child: new Column(
           children: <Widget>[
          new SizedBox(
              width: 150.0,
              child: new Text(speakers[i].name),
            ),
          new SizedBox(
              width: 150.0,
              child: new Text(speakers[i].company, style: TextStyle(color: Color(0xFFC0C0C0)))),
             
          ],
        ))
        
      ],
    );

    list.add(speaker);
  }
  return new Column(
    children: list,
  );
}

Widget _buildHorizontalList(SpeachTimeItem speach, int index) {
  
  debugPrint(index.toString());
  double height = itemHeight;
 var formatter = new DateFormat('HH:mm');
 var time = formatter.format(speach.startTime);
 
  return Column(
    children: <Widget>[
      new Text(time, textScaleFactor: 1.3),
      new Container(
          height: height,
          child: ListView.builder(
              physics: ClampingScrollPhysics(),
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              itemCount: speach.speaches.length,
              itemBuilder: (BuildContext content, int index) {
                return _buildItem(speach.speaches, index);
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

class SpeachItem {
  final String tesis;
  bool isEnableShowHeader = false;
  final DateTime startTime;
  final List<Speakers> speakers;
  final SectionItem section;
  SpeachItem(this.tesis, this.startTime, this.speakers, this.section);
}

class SpeachTimeItem
{
  DateTime startTime;
  List<SpeachItem> speaches;

  SpeachTimeItem(this.speaches, this.startTime);
}



List<DateTime> getAllTimes(List<Speaches> speaches)
{
  var times = List<DateTime>();

  for (var i = 0; i < speaches.length; i++) {
    var time =speaches[i].speachStartTime;

try {
  
    if(times.length == 0)
    {
      times.add(DateTime.parse(time));
    }
    else if (!times.contains(DateTime.parse(time))) {
      times.add(DateTime.parse(time));
    }
} catch (e) {
}   
  }

  times.sort((a,b)=>a.compareTo(b));
  debugPrint(times.toString());
  return times;
}


List<SpeachTimeItem> getAllSpeachesPerDay(List<Speaches> speaches, List<DateTime> times, List<Section> firstDaySections, List<Section> secondDaySections)
{
  var items = List<SpeachTimeItem>();
 
  for (var i = 0; i < times.length; i++) {
    var itemByTime = speaches.where((x)=>DateTime.parse(x.speachStartTime) == times[i]).toList();

    List<SpeachItem> _speaches =  new List<SpeachItem>();
    var daySections = times[i].day == 30? firstDaySections:secondDaySections;
    for (var j = 0; j < daySections.length; j++) {
      
    var sectionItem = new SectionItem(daySections[j].areaName, daySections[j].name);
      try {
          var speachPerSection = itemByTime.firstWhere((x)=>x.areaName ==sectionItem.areaName && x.areaType ==sectionItem.areaType);

          _speaches.add(new SpeachItem(speachPerSection.speachTesis, DateTime.parse(speachPerSection.speachStartTime),speachPerSection.speakers, sectionItem));
          } catch (e) {
            _speaches.add(new SpeachItem("",times[i], null, sectionItem));
          }
        }
         items.add(new SpeachTimeItem(_speaches, times[i]));  
  }
  return items;
}
class SectionItem
{
  String areaName;
  String areaType;

  SectionItem(this.areaName, this.areaType);
}