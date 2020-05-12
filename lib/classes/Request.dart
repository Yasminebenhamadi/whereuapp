import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:whereuapp/servises/firestore.dart';

abstract class Request {
  String _requestID;
  String _toUID;
  String _fromUID;
  String _gid;
  String _text;
  DateTime _dateTime;
  bool _accepted ;
  FirestoreService firestoreService = FirestoreService();
  Firestore firestore = Firestore.instance;
  Request (String requestID, String toUID,String fromUID,String gid,String text){
    this._requestID = requestID;
    this._toUID = toUID;
    this._fromUID = fromUID;
    this._gid = gid;
    this._text = text;
    this._dateTime = DateTime.now();
  }
  Request.fromMap (String requestID, Map<String,dynamic> data){
    this._requestID = requestID;
    this._toUID = data['ToUID'];
    this._fromUID = data['FromUID'];
    this._gid = data['GID'];
    this._text = data['Text'];
    Timestamp timestamp = data['DateTime'];
    this._dateTime = timestamp.toDate();
  }
  static Map<String,dynamic> _requestToMap(String toUID,String fromUID,String gid,String text)=>
    {
      'ToUID' : toUID ,
      'FromUID' :fromUID,
      'GID' : gid,
      'Text' : text,
      'DateTime' : Timestamp.now() ,
    };

  //GETTERS :
  String get requestID => _requestID;

  String get toUID => _toUID;

  String get text => _text;

  bool get accepted => _accepted;

  String get gid => _gid;

  String get fromUID => _fromUID;

  DateTime get dateTime => _dateTime;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Request &&
              runtimeType == other.runtimeType &&
              _requestID == other._requestID;

  @override
  int get hashCode => _requestID.hashCode;

}

class RequestFromGroupe extends Request{

  String _invitationCode;
  RequestFromGroupe(String requestID, String toUID,String fromUID,String gid,String text,String invitationCode) : super(requestID,toUID,fromUID,gid,text);

  RequestFromGroupe.fromMap (String uid,Map<String,dynamic> data) : super.fromMap (uid,data){
    _invitationCode = data['InvitationCode'];
  }
  static Map<String,dynamic> requestToMap (String toUID,String fromUID,String gid,String text,String invitationCode){
    Map<String,dynamic> requestMap = Request._requestToMap(toUID, fromUID, gid, text);
    requestMap.addAll({
      'InvitationCode' : invitationCode,
    });
    return requestMap;
  }
  void setAccepted(bool value) async {
      await firestoreService.addToGroupe(gid, _toUID);
      firestore.collection('invitationFromGroup').document(this._requestID).updateData({
        'Accepted' : value ,
      }).then((_){
        print('Invitation accepted set');
        this._accepted = value ;
      }).catchError((e){
        print('Something went wrong clould\'nt accept invitation '+e.code);
      });
  }
  String get invitationCode => _invitationCode;
}

class RequestFromUser extends Request {

  RequestFromUser(String requestID, String toUID,String fromUID,String gid,String text) : super(requestID,toUID,fromUID,gid,text);
  RequestFromUser.fromMap (String uid,Map<String,dynamic> data) : super.fromMap (uid,data);

  static Map<String,dynamic> requestToMap(String toUID,String fromUID,String gid,String text)=> Request._requestToMap(toUID, fromUID, gid, text);
  void setAccepted(bool value){
    if(value){
      FirestoreService firestoreService = FirestoreService();
      firestoreService.addToGroupe(gid, _fromUID);
      firestore.collection('invitationFromUser').document(this._requestID).updateData({
        'Accepted' : value ,
      }).then((_){
        print('Invitation accepted set');
        this._accepted = value ;
      }).catchError((e){
        print('Something went wrong clould\'nt accept invitation '+e.code);
      });
    }
  }
}