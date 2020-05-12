import 'package:flutter/material.dart';


class Msg3Page extends StatefulWidget {
  @override
  _Msg3PageState createState() => _Msg3PageState();
}

class _Msg3PageState extends State<Msg3Page> {
  

  Widget _text() {
    return Positioned(
      top: 200,
      child: Column(
       
       crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[ 
          
         
           Row( children :<Widget> [
             SizedBox( width:30.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(22.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text('il pleut,soyez prudents ', style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 20.0),
                  Image.asset('assets/rain.png', height:50 , width:50 ),
          ])),
            ]),
            SizedBox( height:20.0),
            Row( children :<Widget> [
             SizedBox( width:30.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(22.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Row( children :<Widget>[ Text("il y'a du brouillard, attention ", style : TextStyle(fontSize:20.0),),
                  SizedBox( width: 20.0),
                  Image.asset('assets/cloud.png', height:40 , width:40 ),
          ])),
            ]),
            
        
               
           
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
