import 'package:codefest/models/Conference.dart';
import 'package:flutter/material.dart';

Widget buildSection(String areaType, String areaName)
{
  return new Container(
                    width: 260,
                    child: new Column(children: <Widget>[ 
                      Text(areaType, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), 
                      new Container( 
        decoration: new BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Color(0xFFEAC2C9),
        shape: BoxShape.rectangle),
        child: new Padding(child: Text(areaName), padding: EdgeInsetsDirectional.fromSTEB(5,0,5,0)),
        )
        ]
                    ));
}