import 'dart:convert';

import 'package:codefest/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/Conference.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';


class FavPage extends StatefulWidget {
  
 List<SpeachTimeItem> items; 
  FavPage(this.items);
   final title = 'Mixed List';

  @override
  FavState createState() => new FavState(items);
}

class FavState extends State<FavPage> {
  List<SpeachTimeItem> items;

  FavState(this.items);
  
  @override
  Widget build(BuildContext context) {
    return  new Scaffold(
        backgroundColor: Colors.white, 
      body: new CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics (), 
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
                  Align(alignment: Alignment.centerLeft , child:Container(
                alignment: Alignment.bottomRight,
                width: 40,
                height: 40,
                child: IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  tooltip: "Избранное",
                  icon:Image.asset('resources/back.png'))))
                  
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
                  return  _buildHorizontalList(items[index], index);
                }),
          )
        ],
      ),
    );
  }



   
  Widget _buildItem(List<SpeachItem> speach, int index) {

  
  var text = new Text(speach[index].section.areaName);
  debugPrint(speach[index].isEnableShowHeader.toString());
   
  if(!speach[index].isBookMarked)
  {
    return  null;
  }
  var card = new Card(
      color: Color(0xFFf2f2f2),
      child: 
      
      Padding(
    padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
    child:Column(
        mainAxisAlignment:  MainAxisAlignment.start,
         children: <Widget>[ 
           text,
      Stack( children: 
        <Widget>[
      Align(alignment: Alignment.topLeft ,child:  
      createSpeakers(speach[index].speakers)),
      Align(alignment: Alignment.topRight ,child:
       new Container(
        width: 50,
      child:  new IconButton( 
        icon: speach[index].isBookMarked? 
        Image.asset('resources/fav_on.png')
       :Image.asset('resources/fav_off.png'),
       onPressed: (){
         setState(() {
             speach[index].isBookMarked = !speach[index].isBookMarked;
         });
       },
      )) )]),
      Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 0),child: Align(alignment: Alignment.topLeft , 
      child:Text(speach[index].tesis))),
      ]))
      );
  return new SizedBox( 
    width: 260, 
    child: card);
  }


Widget _buildHorizontalList(SpeachTimeItem speach, int index) {
  
  debugPrint(index.toString());
 var formatter = new DateFormat('HH:mm');
 var time = formatter.format(speach.startTime);

 List<SpeachItem> visibleSpeachItem = new List<SpeachItem>();
  var isHaveAny = false;
  for (var i = 0; i < speach.speaches.length; i++) {
    if(speach.speaches[i].isBookMarked)
     {
       isHaveAny = true;
       visibleSpeachItem.add(speach.speaches[i]);
     }
  }

Container container;
if(isHaveAny)
  { 
   container = new Container(
          height: itemHeight,
          child: ListView.builder(
              physics: ClampingScrollPhysics(), 
              scrollDirection: Axis.horizontal,
              itemCount: visibleSpeachItem.length,
              itemBuilder: (BuildContext content, int index) {
                return _buildItem(visibleSpeachItem, index);
              }));
  }
  else
  {
    var image = new Container(
        width: 100.0,
        decoration: new BoxDecoration(
            shape: BoxShape.circle,
            image: new DecorationImage(
                fit: BoxFit.fitHeight,
                image:
                    new NetworkImage("https://i.pinimg.com/originals/e7/a3/3a/e7a33a0483b49379869a93bb7ed053f6.gif"))));
    
    container = new Container(
          height: itemHeight,
          child: Align(alignment: Alignment.center,child:
          image));
  }
  return Column(
    children: <Widget>[
      new Text(time, textScaleFactor: 1.3),
      container
    ],
  );
  }
} 