import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';

class Message implements Comparable<Message>{
  String _messageID ;
  String _text;
  TypeMessage _type;
  DateTime _dateTime ;
  String _expediteurID;
  String _expediteurNom;
  bool _sent ;
  bool _delivered ;
  //Map<String,bool> _seenBy ; //.configure
  List<String> _seenBy;

  Message(/*String messageID,*/String text,TypeMessage type,DateTime datetime,String expediteurID,String expediteurNom,bool sent,bool delivered,List<String> seenBy){
    //_messageID = messageID;
    _text = text;
    _type = type;
    _expediteurNom = expediteurNom;
    _dateTime = datetime ;
    _expediteurID = expediteurID;
    _sent = sent;
    _delivered = delivered;
    _seenBy = seenBy ;
  }
  Message.from(String messageID ,Map<String,dynamic> message){
    _messageID = messageID;
    _text = message['Text'];
    _type = EnumToString.fromString(TypeMessage.values, message['Type']);
    Timestamp timestamp = message['DateTime'];
    _dateTime =  timestamp.toDate();
    _expediteurID = message['FromID'];
    _expediteurNom = message['From'];
    _delivered = message['Delivered'];
    _seenBy = List<String>.from(message['SeenBy']);
  }
   //Converting a Message to a Map<String,dynamic> for it to be added to firestore
  Map<String,dynamic> messageToMap (List<String> members) {
    return {
      'MessageID' : this._messageID,
      'Text' : this._text,
      'Type' : this._type.toString(),
      'DateTime' : Timestamp.fromDate(this._dateTime),
      'FromID' : this._expediteurID,
      'From' : this._expediteurNom,
      'Delivered' : this._delivered,
      'SeenBy' : this._seenBy,
      'ShowTo' : members,
    };
  }

  @override
  int compareTo(Message message){
    return - this._dateTime.compareTo(message.dateTime);
  }


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Message &&
              runtimeType == other.runtimeType &&
              _messageID == other._messageID;

  @override
  int get hashCode => _messageID.hashCode;
  
  //-------------------------Getters------------------------------
  String get messageID =>_messageID;

  bool get delivered => _delivered;

  List<String> get seenBy => _seenBy;

  bool get sent => _sent;

  DateTime get dateTime => _dateTime;

  String get text => _text;

  TypeMessage get type => _type;

  String get expediteurID => _expediteurID;

  String get expediteurNom => _expediteurNom;
  //-------------------------Setters------------------------------
  set sent(bool value) {
    _sent = value;
  }
  set delivered (bool value) {
    _delivered = true;
  }
  void setSeen(String username) {
    _seenBy.add(username);
  }
}
class Alerte extends Message {

  Alerte(String text,TypeMessage type,DateTime datetime,String expediteurID,String expediteurNom,bool sent,bool delivered,List<String> seenBy) :
        super (text,type,datetime,expediteurID,expediteurNom,sent,delivered,seenBy);
}
enum  TypeMessage {
  Meteo,Accident,EtatRoute,Vitesse,Distance,AboutGroupe,Alert,Photo
}