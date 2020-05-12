import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/classes/Message.dart';
import 'dart:async';

import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/firestore.dart';


class SosPage extends StatefulWidget {
  @override
  _SosPageState createState() => _SosPageState();
}

class _SosPageState extends State<SosPage> with TickerProviderStateMixin {
  Utilisateur utilisateur;
  AnimationController _controller;
  Timer _timer;
  int _start = 10;

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    _timer = new Timer.periodic(
      oneSec,
          (Timer timer) => setState(
            () {
          if (_start < 1) {
            sendAlert();
            timer.cancel();
          } else {
            _start = _start - 1;
          }
        },
      ),
    );
  }
  final FirestoreService _firestoreService = FirestoreService();

  Future<void> sendAlert ()async {
    List<GroupHeader> activeGroupes = await utilisateur.getUsersGroupsHeaders ();
    for(GroupHeader group in activeGroupes){
      Group g = await _firestoreService.getGroupInfo(group.gid);
      g.addMesssage('${utilisateur.sharableUserInfo.displayName} is having an emergency try to contact them as fast as possible',
          TypeMessage.Alert, utilisateur.sharableUserInfo.id, utilisateur.sharableUserInfo.displayName);
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      lowerBound: 0.5,
      duration: Duration(seconds: 13),
    )..repeat();
  }

  Widget _buildContainer(double radius) {
    return Container(
      width: radius,
      height: radius,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.orange[800].withOpacity(1 - _controller.value),
      ),
    );
  }
  Widget _sos() {
    return Column(

      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        SizedBox(height: 110.0),
        Text(
          " Restez calme !",
          style: TextStyle(
              fontSize: 50.0,
              fontWeight: FontWeight.bold,
              color: Colors.orange[800]),
          textAlign: TextAlign.center,),
        SizedBox( height:50.0),
        Text("Votre  message d'alerte va étre envoyé à votre cercle dans 10 s ." , style: TextStyle(
            fontSize:18.0,
            fontWeight:FontWeight.bold,

            color: Colors.white),
          textAlign: TextAlign.center,
        ),
        SizedBox( height:110.0),
        AnimatedBuilder(
            animation: CurvedAnimation(parent: _controller, curve: Curves.slowMiddle),
            builder: (context, child) {
              return Stack(
                alignment: Alignment.center,
                children: <Widget>[
                  _buildContainer(150 * _controller.value),
                  _buildContainer(200 * _controller.value),
                  _buildContainer(250 * _controller.value),
                  _buildContainer(300 * _controller.value),
                  _buildContainer(350 * _controller.value),

                  Align ( child : GestureDetector( child : Column(children: <Widget> [RawMaterialButton( fillColor: Colors.orange[800], shape: CircleBorder(),
                      onPressed:() {startTimer();}) ,Text( "$_start", style: TextStyle(fontSize:35.0 , color:Colors.white,fontWeight:FontWeight.bold )) ],))),
                ],


              );
            }



        ),
      ],

    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[200],
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            ),
            _sos(),

          ],
        ),
      ),
    );
  }
}