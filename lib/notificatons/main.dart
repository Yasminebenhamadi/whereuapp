import 'package:flutter/material.dart';
import'msg1.dart' ; 
import'msg2.dart' ; 
import'msg3.dart' ; 
import'msg4.dart' ; 

class SettingPage extends StatefulWidget {
  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  
  

 
    
  

  Widget _code() {
        return Positioned(
          top: 100, // hint text + code + en bas un autre bouton send
          child: Column (crossAxisAlignment: CrossAxisAlignment.center, children: <Widget>[ 
            
             
                  Container(child:Row ( children:<Widget> [
                    SizedBox( width:30.0),
                    Text(
                        " Envoyer un signalement ",
                        style: TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Color(0xff739D84)),
                            textAlign: TextAlign.center,)])),
                            SizedBox( height:40.0),
                          
                             
                           
    
         
  
          Row ( children : <Widget> [
         Image.asset('assets/road.png', height:90 , width:90 ),
         SizedBox( width: 15.0),
         ButtonTheme( minWidth: 170.0 , 
         height : 70 , child:            RaisedButton(  
                    onPressed: () =>
                              Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new Msg1Page(),
                          )),
                   padding :EdgeInsets.all(20.0),
                   color:  Colors.white,
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Color(0xffE8652D),
                  child: Text('Etat de la route ', style : TextStyle(fontSize:18.0,fontWeight:FontWeight.bold)),
                 
                 
                  
           ) )]), 
   SizedBox (height :15.0) ,
   Row( children: <Widget> [
          Image.asset('assets/speedometer.png', width:90, height:90 ),
          SizedBox(width: 15.0),
          ButtonTheme( minWidth: 170.0 , 
         height : 70 , child:
           RaisedButton(  
                      onPressed: () =>
                              Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new Msg2Page(),
                          )),
                   padding :EdgeInsets.all(20.0),
                   color:  Colors.white,
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Color(0xffE8652D),
                  child: Text('Vitesse ', style : TextStyle(fontSize:18.0,fontWeight:FontWeight.bold)),
                 
                 
                  
   ))]), 
           SizedBox( height: 15.0),
       Row( children: <Widget> [
               Image.asset('assets/atmospheric.png' ,width:90, height:90 ),
               SizedBox( width: 15.0),
            
            ButtonTheme( minWidth: 170.0 , 
         height : 70 , child:          
           RaisedButton(  
padding :EdgeInsets.all(20.0),                      onPressed: () =>
                            Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new Msg3Page(),
                          )),
                  
                   color:  Colors.white,
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Color(0xffE8652D),
                  child:Text('météo ', style : TextStyle(fontSize:18.0,fontWeight:FontWeight.bold)),
                 
                 
                  
        ) )]), 
   SizedBox( height: 15.0),
          Row( children : <Widget> [
                 Image.asset('assets/617822.png', width:90, height:90 ),
                 SizedBox( width:15.0),
                 ButtonTheme( minWidth: 170.0 , 
         height : 70 , child:    
          RaisedButton(  
                    onPressed: () =>
                              Navigator.of(context).push(new MaterialPageRoute(
                            builder: (BuildContext context) => new Msg4Page(),
                          )),
                   padding :EdgeInsets.all(20.0),
                   color:  Colors.white,
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Color(0xffE8652D),
                  child: Text('autres ', style : TextStyle(fontSize:18.0,fontWeight:FontWeight.bold)),
                 
                  
          ))]), 
          ],
          ),
     
     
    );
  }
 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2E9DB),
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
           
            _code(),
           
          ],
        ),
      ),
    );
  }
}
