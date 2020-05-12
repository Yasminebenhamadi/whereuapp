import 'package:flutter/material.dart';


class Msg1Page extends StatefulWidget {
  @override
  _Msg1PageState createState() => _Msg1PageState();
}

class _Msg1PageState extends State<Msg1Page> {
  

  Widget _text() {
    return Positioned(
      top: 80,
      child: Column(
       
       crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[ 
          
         
           Row( children :<Widget> [
             SizedBox( width:1.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(19.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text('un accident dans la route , évitez-la ', style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 5.0),
                  Image.asset('assets/transport.png', height:50 , width:50 ),
          ])),
            ]),
            SizedBox( height:20.0),
            Row( children :<Widget> [
             SizedBox( width:1.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(20.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text('une route encombrée,évitez-la ', style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 3.0),
                  Image.asset('assets/bridge.png', height:40 , width:40 ),
          ])),
            ]),
            
            
            SizedBox( height:20.0),
            Row( children :<Widget> [
             SizedBox( width:1.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(20.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text('la route est bloquée ', style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 5.0),
                  Image.asset('assets/barrier.png', height:50 , width:50 ),
          ])),
            ]), SizedBox( height:20.0),
            Row( children :<Widget> [
             SizedBox( width:1.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(22.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text(' une chaussée glissante ,attention ', style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 3.0),
                  Image.asset('assets/drifting.png', height:30 , width:30 ),
          ])),
            ]),
            SizedBox( height:20.0),
            Row( children :<Widget> [
             SizedBox( width:1.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(19.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text("un passage d'animaux, attendez un peu ", style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 0.0),
                  Image.asset('assets/cow.png', height:30 , width:30 ),
          ])),
            ])
          ]
         
      ),
    );
  }

  
           
     
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(0xffF2E9DB),
     
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            _text(),
          ],
        ),
      ),
    );
  }
}
