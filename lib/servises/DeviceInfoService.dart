import 'dart:async';
import 'package:firebase_database/firebase_database.dart';
class DeviceInfoService {
  final  DatabaseReference _infoConnected = FirebaseDatabase.instance.reference().child('.info/connected');
  final DatabaseReference _userStatus = FirebaseDatabase.instance.reference().child('status');
  //TODO bool getBatteryLevel ;

  DeviceInfoService(bool getBatteryLevel){
    //this.getBatteryLevel = getBatteryLevel;
  }

  void listenToChangeStatus (String uid){
    _infoConnected.onValue.listen((event){
      bool status = event.snapshot.value ;
      if(status){
        _userStatus.child(uid).onDisconnect().set({
          'online' : false ,
          'LastSeen' : ServerValue.timestamp ,
        });
        _userStatus.child(uid).set({
          'online' : true ,
        });
      }
    });
  }
}

