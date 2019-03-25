import 'dart:convert';
import 'models/favs.dart';
import 'package:codefest/FavPage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/Conference.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

import 'files.dart';

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
  str.then((s)  async{
  
  var allSpeaches = stringeToConference(s);
  
    //Load favs. Set to Items
      try { 
      var favs = await LoadFavs();
       
        for (var i = 0; i < items.length; i++) {
          for (var j = 0; j < items[i].speaches.length; j++) {
            var speach = items[i].speaches[j];
            try {
              
            var favExist = favs.favs.firstWhere((x){
              return DateTime.parse(x.startTime) == speach.startTime
              && x.areaName == speach.section.areaName 
              && x.areaType == speach.section.areaType;
            });
            if(favExist != null)
            {
              speach.isBookMarked = true;
            }
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        }
         
      } catch (e) {
              debugPrint(e.toString());
      }
  
    runApp(MaterialApp(
    title: 'Navigation Basics',
    home: MyApp(allSpeaches),
    )); 
   });
  str.catchError((err) => debugPrint("fail"));
  str.timeout(const Duration(seconds: 5), onTimeout: () => _onTimeout());

  
}

Future<Favs> LoadFavs() async
{ 
  var file = await getFile("favs.json");
  var favsText = await file.readAsString();
  try {
    
  var decode = jsonDecode(favsText);
  return Favs.fromJson(decode);
  } catch (e) {
    return null;
  }
}

Future<void> SaveFavs() async
{
  var favs = SpeachesToFavs(items);
  var str = jsonEncode(favs.toJson());
  await writeFile("favs.json", str);
}

Favs SpeachesToFavs(List<SpeachTimeItem> items)
{
  var favs = new List<Fav>();
  for (var i = 0; i < items.length; i++) {
      for (var j = 0; j < items[i].speaches.length; j++) {
        var speach = items[i].speaches[j];
         if(speach.isBookMarked)
         {
           favs.add(new Fav(areaName: speach.section.areaName,
           areaType: speach.section.areaType,
           startTime: speach.startTime.toString()));
         }
      }
    }
    return new Favs(favs: favs);
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
  return allSpeaches;
}



double itemHeight = 160;


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

var lastDate = 0;
var count = 0;
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

if(lastDate != items[firstVisibleVerticalItem].startTime.day)
{
    for (var i = 0; i < headerSections.length; i++) {
      headerSections[i].name = listSections[i].name;
      headerSections[i].areaName = listSections[i].areaName;
    }
  setState(() {
  });
  lastDate = items[firstVisibleVerticalItem].startTime.day;
}
  }

  MyAppState(this.items);

  @override
  Widget build(BuildContext context) {

  _verticalScrollController.addListener(verticalScrollListener);
 lv= ListView.builder(
                physics: const AlwaysScrollableScrollPhysics (),
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
       theme: ThemeData(
   primaryColor: Colors.red,
     ),
      home: new Scaffold(
        backgroundColor: Colors.white, 
      body: new CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics (),
        controller: _verticalScrollController,
        slivers: <Widget>[
          new SliverAppBar(
            expandedHeight: 100.0,
            floating: true,
            pinned: true,
            backgroundColor: Colors.white,
            leading: new FlexibleSpaceBar(
              title: getIconWidget(),
            ),
            flexibleSpace:  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 40), child: FlexibleSpaceBar(
                  centerTitle: true,
                  title:Text("Collapsing Toolbar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.0,
                      )),
                  background: Image.network(
                    "https://images.pexels.com/photos/396547/pexels-photo-396547.jpeg?auto=compress&cs=tinysrgb&h=350",
                    fit: BoxFit.cover,
                  ))),
            bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40.0),
            child: Theme(
              data: Theme.of(context).copyWith(accentColor: Colors.white),
              child: Container(
                height: 40.0,
                alignment: Alignment.center,
                child: Stack(children: <Widget>[
                  lv ,
                  Align(alignment: Alignment.centerRight , child:Container(
                alignment: Alignment.bottomRight,
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => FavPage(items)));
                  },
                  tooltip: "Избранное",
                  icon:Image.asset('resources/fav_on.png'))))
                  
                ]),
              ),
            ),
          ),
          ),
          new SliverFixedExtentList(
            
            itemExtent: itemHeight+30,
            delegate:
                new SliverChildBuilderDelegate((context, index) 
                { 
                  if(index < items.length)
                  return _buildHorizontalList(items[index],index);
                }),
          )
        ],
      ),
    ),
    );
  }


   
Widget _buildItem(List<SpeachItem> speach, int index) {

  
  var text = new Text(speach[index].section.areaName);
  debugPrint(speach[index].isEnableShowHeader.toString());
  if(speach[index].isEnableShowHeader)
  {
    text = new Text("");
  }
  
  var favImage = Align(alignment: Alignment.topRight ,child:
       new Container(
        width: 50,
      child:  new IconButton( 
        icon: speach[index].isBookMarked? 
        Image.asset('resources/fav_on.png')
       :Image.asset('resources/fav_off.png'),
       onPressed: (){
         setState(() { 
             speach[index].isBookMarked = !speach[index].isBookMarked;  
             SaveFavs();
         });
       },
      )));

  if(speach[index].speakers == null)
  {
    if(index != 0)
    favImage = new Align(alignment: Alignment.topRight);
  }
  var card = new Card(
      color: Color(0xFFf2f2f2),
      child: 
      
      Padding(
    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
    child:Column(
        mainAxisAlignment:  MainAxisAlignment.start,
         children: <Widget>[ 
      Stack( children: 
        <Widget>[
      Align(alignment: Alignment.topLeft ,child:  
      createSpeakers(speach[index].speakers)),
      favImage
      ]),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0),child: Align(alignment: Alignment.topLeft , 
      child:Text(speach[index].tesis))),
      ]))
      );
  return new SizedBox( 
    width: 260,
    height: itemHeight,
    child: card);
}


Widget _buildHorizontalList(SpeachTimeItem speach, int index) {
  
  debugPrint(index.toString());
 var formatter = new DateFormat('HH:mm');
 var time = formatter.format(speach.startTime);
 
  return Column(
    children: <Widget>[
      new Text(time, textScaleFactor: 1.3),
      new Container(
          height: itemHeight,
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

}


Widget getIconWidget()
{
  return new Image.network("https://pbs.twimg.com/profile_images/1069836563964678145/SflnPD2C_400x400.jpg");
}

ScrollController _scrollController = new ScrollController();
ScrollController _verticalScrollController = new ScrollController();

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

    list.add(new Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
        child: speaker));
  }
  return new Column(
    children: list
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
  bool isBookMarked = false;
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