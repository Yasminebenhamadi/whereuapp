import 'package:flutter/material.dart';

AlertDialog unknownError (BuildContext context){
  return AlertDialog(
    title: Text("Uknown Error",
        style: TextStyle(
          color: Color(0xff739D84),
        )),
    content: Text(
        "Something went wrong please check your internet connection or try again later"),
    actions: <Widget>[
      FlatButton(
          child: Text('Okay',
              style: TextStyle(
                color: Color(0xffE8652D),
              )),
          onPressed: () {
            Navigator.pop(context);
          }),
    ],
  );
}