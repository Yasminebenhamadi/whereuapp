import 'package:flutter/material.dart';


class Msg4Page extends StatefulWidget {
  @override
  _Msg4PageState createState() => _Msg4PageState();
}

class _Msg4PageState extends State<Msg4Page> {
  

  Widget _text() {
    return Positioned(
      top: 200,
      child: Column(
       
       crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[ 
          
         
           Row( children :<Widget> [
             SizedBox( width:10.0),
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(40.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                 Column( children :<Widget>[ Text('Je ne peut pas vous rejoindre  ', style : TextStyle(fontSize:20.0), textAlign : TextAlign.center),
               Text(' dans notre prochain trajet.', style : TextStyle(fontSize:20.0), textAlign : TextAlign.center)
                  
          ])),
            ]),
            SizedBox( height:20.0),
            Row( children :<Widget> [
             SizedBox( width:10.0),
            
       
            RaisedButton( 
                  onPressed: () => print( ''),
                   padding :EdgeInsets.all(40.0),
                  
                color:  Color(0xFFF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Colors.white,
                  child:
                  Column( children :<Widget>[ Text("Que pensez vous d'un voyage    ", style : TextStyle(fontSize:20.0),  textAlign : TextAlign.center),
                   Text(" commun le weekend prochain ? ", style : TextStyle(fontSize:20.0),  textAlign : TextAlign.center),
                
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
