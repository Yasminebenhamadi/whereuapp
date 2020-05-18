import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/classes/Message.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:whereuapp/classes/TimePlace.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:whereuapp/servises/storage.dart';

class GroupHeader {
  String gid;
  String name;
  bool photo ;
  String groupPhoto ;
  GroupHeader.fromMap (String gid,Map<String,dynamic> data){
    this.gid = gid ;
    name = data['Nom'];
    photo = data['Photo'];
    groupPhoto = 'Groupes/'+ this.gid + "/" + 'photo';
  }
  GroupHeader(String gid,String nom,bool photo){
      this.gid = gid;
      this.name = nom;
      this.photo = photo ;
      groupPhoto = 'Groupes/'+ this.gid + "/" + 'photo';
  }
  Map<String,dynamic> groupHeaderToMap() => {
    'GID': gid,
    'Nom' : name,
    'Photo' :photo,
  } ;
}
class Group extends ChangeNotifier {
  //Public
  String _gid;
  String _nom;
  bool _photo ;
  bool _visible ;
  //Private
  String _adminID;
  List<Member> _members;
  List<Message> _discussion;
  DateTime _lastReadMessage;
  String _invitationCode;
  //Optional :
  LatLng _destination ;
  DateTime _dateDepart ;
  TypeGroupe _type;
  //-----------------------------BDD--------------------------------------------
  final Firestore _firestore = Firestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();

  DocumentReference _groupInfoDoc ;
  CollectionReference _discussionCollection;

  String _groupPhoto ;
  //-----------------------------Constructors-----------------------------
  Group (String id,String nom,String adminID,bool photo,String invitationCode){
    this._gid = id;
    this._adminID = adminID;
    this._nom = nom;
    this._visible = true;
    this._photo = photo ;
    this._invitationCode = invitationCode;
    this._members = new List<Member>();
    this._discussion = new List<Message>();
    this._lastReadMessage = DateTime.now();
    this._destination = null;
    this._dateDepart = null;
    this._type = null;
    this._groupInfoDoc = _firestore.collection("groups").document(this._gid);
    this._discussionCollection = this._groupInfoDoc.collection('Discussion');
    this._groupPhoto = 'Groupes/'+ this.gid + "/" + 'photo';
  }
  Group.old(String gid,Map<String,dynamic> groupeData){
    this._gid = gid;
    this._nom = groupeData['Nom'];
    this._photo = groupeData['Photo'];
    this._adminID = groupeData['Admin'];
    this._visible = groupeData['Visible'];
    this._invitationCode = groupeData['InvitationCode'];
    if(groupeData.containsKey('LieuArrive')){
      GeoPoint destination = groupeData['LieuArrive'];
      _destination = LatLng(destination.latitude, destination.longitude);
    }
    if(groupeData.containsKey('DateDepart')){
      Timestamp timestamp = groupeData['DateDepart'];
      this._dateDepart = timestamp.toDate();
    }
    if(groupeData.containsKey('Type')){
      String type = groupeData['Type'];
      this._type = EnumToString.fromString(TypeGroupe.values, type);
    }
    this._members = new List<Member>();
    this._discussion = new List<Message>();
    Timestamp timestamp = groupeData['LastReadMessage'];
    this._lastReadMessage = timestamp.toDate();
    this._groupInfoDoc = _firestore.collection("groups").document(this._gid);
    this._discussionCollection = this._groupInfoDoc.collection('Discussion');
    this._groupPhoto = 'Groupes/'+ this.gid + "/" + 'photo';
  }
  static Map<String,dynamic> groupMap (String nom,String adminID,bool photo,String invitationCode) {
    Map<String,Timestamp> members = new Map<String,Timestamp> ();
    members.putIfAbsent(adminID, () => Timestamp.now());
    return {
      'Nom' : nom,
      'Admin' : adminID,
      'LastReadMessage' : Timestamp.now() ,
      'Visible' : true,
      'Photo' : photo,
      'Members' : members,
      'InvitationCode' : invitationCode,
    };
  }

  void updateGroupe(Map<String,dynamic> groupeData){
    this._nom = groupeData['Nom'];
    this._photo = groupeData['Photo'];
    this._adminID = groupeData['Admin'];
    this._visible = groupeData['Visible'];
    if(groupeData.containsKey('LieuArrive')){
      GeoPoint destination = groupeData['LieuArrive'];
      _destination = LatLng(destination.latitude, destination.longitude);
    }
    if(groupeData.containsKey('DateDepart')){
      Timestamp timestamp = groupeData['DateDepart'];
      this._dateDepart = timestamp.toDate();
    }
    if(groupeData.containsKey('Type')){
      String type = groupeData['Type'];
      this._type = EnumToString.fromString(TypeGroupe.values, type);
    }
  }
  //-----------------------------Setters-----------------------------
  Future<void> setNom (String nom) async {
    await this._groupInfoDoc.updateData({
      'Nom' : nom,
    }).then((_){
      print('Group\'s name has been set');
      this._nom = nom;
      notifyListeners();
    }).catchError((error){
      print('couldn\'t set name');
    });
  }
  Future<void> setType (TypeGroupe type) async {
    await this._groupInfoDoc.updateData({
      'Type' : type.toString(),
    }).then((_){
      print('Group\'s type has been set');
      this._type = type;
    }).catchError((error){
      print('couldn\'t set type');
    });
  }
  Future<void> changeVisibility() async {
    bool b = !_visible;
    await this._groupInfoDoc.updateData(
        {
          "Visible": b,
        }
    ).then((result) {
      _visible = b;
      print("visibility changed");
      notifyListeners();
    }).catchError((error) {
      print("Error" + error.code);
    });
  }
  Future<void> setLieuArrive (LatLng destination) async {
    GeoPoint lieuArrive = GeoPoint(destination.latitude, destination.longitude);
      await this._groupInfoDoc.updateData({
        'LieuArrive' : lieuArrive,
      })
        .then((_){
            print('Destination set');
            this._destination = destination;
            notifyListeners();
         })
        .catchError((error){
            print('Couldn\'t set destination');
        });
  }
  Future<void> setDateDepart (DateTime dateDepart) async {
    await this._groupInfoDoc.updateData({
      'DateDepart' : _firestoreService.firestoreDateTime(dateDepart),
    })
        .then((_){
      print('time set');
      this._dateDepart = dateDepart;
      notifyListeners();
    })
        .catchError((error){
      print('Couldn\'t set time');
    });
  }

  //Remove
  Future<void> removeDateDepart () async {
    await this._groupInfoDoc.updateData({
      'DateDepart' : FieldValue.delete(),
    })
        .then((_){
      print('time deleted');
      this._dateDepart = null;
      notifyListeners();
    })
        .catchError((error){
      print('Couldn\'t delete time');
    });
  }
  Future<void> removeLieuArrive () async {
    await this._groupInfoDoc.updateData({
      'LieuArrive' : FieldValue.delete(),
    })
        .then((_){
      print('Destination removed');
      this._destination = null;
      notifyListeners();
    })
        .catchError((error){
      print('Couldn\'t remove destination');
    });

  }
  Future<void> removeType () async {
    await this._groupInfoDoc.updateData({
      'Type' : FieldValue.delete(),
    })
        .then((_){
      print('Type removed');
      this._type = null;

    })
        .catchError((error){
      print('Couldn\'t remove destination');
    });
  }
  Future<void> setLastReadMessage (DateTime dateTime) async {
    await this._groupInfoDoc.updateData({
      'LastReadMessage' : Timestamp.fromDate(dateTime),
    })
      .then((_){
      print('Last read message set');
      this._lastReadMessage = dateTime;
      notifyListeners();
    })
      .catchError((error){
    print('Couldn\'t set last read message');
    });
  }
  //------------------------------------Photo----------------------------------------
  Future<void> setPhoto(File file) async {
    await _uploadPhoto(file).then((_) {
      this._groupInfoDoc.updateData({
        'Photo' : true,
      }).then((_) => this._photo = true);
      print('photo set');
      notifyListeners();
    }).catchError((error) {
      print('could\'nt set photo');
    });
  }

  Future<String> _uploadPhoto(File file) async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(_groupPhoto);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print('photo url'+url);
  }

  Future<void> deletePhoto() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(_groupPhoto);
    storageReference.delete().whenComplete(() {
      this._groupInfoDoc.updateData({
        'Photo' : false,
      }).then((_) => this._photo = false);
      print('Profile photo deleted');
      notifyListeners();
    }).catchError((error) {
      print('Could\'t delete profile photo');
    });
  }

  //-----------------------------------Members----------------------------------------
  Member member(String uid){
    Member thisMember;
    _members.forEach((member){
      if(member.membersInfo.id==uid)
        thisMember = member;
    });
    return thisMember;
  }
  Future<void> addMember (String uid) async{
    DateTime dateTime = DateTime.now();
    SharableUserInfo sharableUserInfo = await _firestoreService.getUserInfo(uid);
    await this._groupInfoDoc.updateData({
      //'Members' : FieldValue.arrayUnion([member.membersInfo.id]),
      'Members.'+uid : Timestamp.fromDate(dateTime),
    })
        .then((_){
      print('member added');
      this._members.add(Member(gid,dateTime,sharableUserInfo,_firestore.collection('users').document(uid).collection('groupes').document(this.gid)));
      notifyListeners();
    })
        .catchError((error){
      print('Couldn\'t add member');
    });
  }
  Future<void> removeMember (Member member) async {
    if(member.membersInfo.id!=this.adminUsename){
      await _firestoreService.removeFromGroup(this._gid, member.membersInfo.id)
          .then((_){
        print('member deleted');
        this._members.remove(member);
        notifyListeners();
      })
          .catchError((error){
        print('Couldn\'t delete member');
      });
    }
    else
      print('You are the admin of this group please choose asign someone to replace u before leaving');
  }
  Future<bool> getActiveMember (String uid) async {
    DocumentSnapshot documentSnapshot = await _firestore.collection('users').document(uid).collection('groupes').document(_gid).get();
    if(documentSnapshot.exists)
      return  documentSnapshot.data['active'];
    else
      return false ;
  }
  Future<void> getMembersInfo (String memberID,DateTime dateTime) async {
    bool active = await getActiveMember(memberID);
    SharableUserInfo sharableUserInfo;
    if (active){
      sharableUserInfo = await _firestoreService.getUserInfo(memberID);
      _members.add(Member(memberID, dateTime, sharableUserInfo,_firestore.collection('users').document(memberID).collection('groupes').document(_gid)));
    }
  }
   Future<List<Member>> getMembers () async {
    if (_members.isEmpty){
      DocumentSnapshot documentSnapshot = await _groupInfoDoc.get();
      if (documentSnapshot.exists){
        Map<String,Timestamp> membersIDS = Map<String,Timestamp>.from(documentSnapshot.data['Members']);
        for  (String memberID in membersIDS.keys) {
          await getMembersInfo(memberID, membersIDS[memberID].toDate());
        }
        return _members;
      }
      else{
        print('Group\'s doc does not exist this should not happen ');
        return null;
      }
    }
    else
      return _members;
  }
  Future<Set<Marker>> addMarkers () async {
    Set<Marker> markers = new Set<Marker> ();
    if (_members.isNotEmpty) {
      for (int i = 0; i < this._members.length; i++) {
        if(_members[i].membersInfo.active){
          markers.add(
              Marker(
                markerId: MarkerId(_members[i].membersInfo.id),
                position: _members[i].membersInfo.location,
                draggable: false,
                zIndex: 2,
                infoWindow: InfoWindow(title: _members[i].membersInfo.displayName),
                flat: true,
                anchor: Offset(0.5, 0.5),)
          );
        }
      }
    }
    return markers;
  }
  Future <Set <Marker>>  syncroniser ()  async {
    for(Member member in _members){
      DocumentSnapshot documentSnapshot = await member.documentReference.get();
      member.membersInfo.setInfoGroup(documentSnapshot.data);
    }
    return addMarkers();
  }
  /*StreamSubscription _locationSubscription;
  Location _locationTracker = Location();*/

  void tracking_groupe ( GoogleMapController  _controller ) {
    //_locationSubscription = _locationTracker.onLocationChanged.listen((groupe) {
      if (_controller != null) {
        for (int m = 0 ; m< this._members.length ; m++)
        {
          listenToChanges(_members[m]);
          LatLng location = _members[m].membersInfo.location;
          _controller.animateCamera(
            CameraUpdate.newCameraPosition(
                new CameraPosition(
                  bearing: 192.8334901395799,
                  target: LatLng(location.latitude,location.longitude),
                  tilt: 0,
                  zoom: 18.00
                )
            )
          );
        }
    }
  }
  Future<List<TimePlace>> getHistoryMember(String memberID) async {
    List<TimePlace> historique = List<TimePlace>();
    QuerySnapshot querySnapshot = await  _firestore.collection('users').document(memberID).collection('historique').where(
        'Groupes', arrayContains: this._gid).getDocuments();
    querySnapshot.documents.forEach((doc){
      historique.add(TimePlace.fromMap(doc.data));
    });
    return historique;
  }

  //----------------------------------Admin-----------------------------------------
  Future<void> setAdminWith (String newAdminID) async {
    await this._groupInfoDoc.updateData({
      'Admin' : newAdminID,
    })
        .then((_){
      print('Admin set');
      this._adminID = newAdminID;
      notifyListeners();

    })
        .catchError((error){
      print('Couldn\'t set Admin');
    });
  }
  Future<void> setAdmin () async {
    if(this._type==null || this._type != TypeGroupe.Family)
      _members.sort();
    else
      _members.sort((member1,member2){
        return member1.membersInfo.compareTo(member2.membersInfo);
      });

    String newAdminID;
    if(_members[0].membersInfo.id == _adminID){
      newAdminID = _members[1].membersInfo.id;
    }
    else{
      newAdminID = _members[0].membersInfo.id;
    }
    await setAdminWith(newAdminID);
  }
  Future<void> removeAdminAndSet () async {
    String adminUsername = this._adminID;
    setAdmin()
        .then((_)=> removeMember(member(adminUsername))
                                .then((_)=>print('Member removed succesfully'))
                                    .catchError((error)=>print('Could\'nt remove member'))
          .catchError((error)=>print('Couldn\'t set admin plz try later')));
  }

  //------------------------------------Discussion-----------------------------------------------
  Future<void> sendPhoto (File file,String expediteurID,String expediteurNom) async {
    String photoPath = 'Groupes/'+ this.gid + "/" + 'discussion'+expediteurID+DateTime.now().toString();
    await _storageService.uploadPhoto(file, photoPath);
    await addMesssage(photoPath, TypeMessage.Photo, expediteurID, expediteurNom);
  }
 Future<void> addMesssage(String text,TypeMessage type,String expediteurID,String expediteurNom) async {
   List<String> seenBy = new List<String> ();
    seenBy.add(expediteurID);
    Message message = Message(text, type, DateTime.now(), expediteurID,expediteurNom, false, false, seenBy);
    List<String> showTo = List<String> ();
    if (_members.isEmpty){
      await getMembers();
    }
    _members.forEach((member){
      showTo.add(member.membersInfo.id);
    });
    await _discussionCollection.add(message.messageToMap(showTo)).then((messageDoc) async {
      WriteBatch batch = _firestore.batch();
      this._members.forEach((member){
        batch.setData(member._documentReference.collection('discussion')
            .document(messageDoc.documentID),
            {
              'messageID': messageDoc.documentID,
            });
      });
      //batch.setData(messageDoc,message.messageToMap());
      await batch.commit() //.then((_)=> message.setSent())
          .catchError((error) =>
          print('Message can\'t be sent '+error.toString()));
      /*await messageDoc.setData(message.messageToMap()).then((_)=>  message.setSent())
          .catchError((error){
        print('Message can\'t be sent '+error.toString());
      });*/
    });
  }
  Future<void> removeMessageForMe (String uid,Message message) async {
    await _discussionCollection.document(message.messageID).updateData({
      'ShowTo' : FieldValue.arrayRemove([uid]),
    });
  }
  Future<void> removeMessageForEveryone (String uid,Message message) async {
    if(uid == message.expediteurID){
      await _discussionCollection.document(message.messageID).delete()
          .then((_){
        _discussion.remove(message);
      })
          .catchError((error) => print('Could\'nt delete message'));
    }
  }
  Future<void> setMessageSeen (String uid,Message message) async{
    await _discussionCollection.document(message.messageID).updateData({
      'SeenBy' : FieldValue.arrayUnion([uid]),
    }).then((_){
      message.seenBy.add(uid) ;
    });
  }
  Future<void> setMessageDelivered (Message message) async{
    await _discussionCollection.document(message.messageID).updateData({
      'Delivered' : true,
    }).then((_) => message.delivered = true );
  }
  Future<void> deleteConversationFor(String uid) async {
    QuerySnapshot querySnapshot= await _discussionCollection.getDocuments () ;
    int i = 0;
    WriteBatch writeBatch = Firestore.instance.batch();
    querySnapshot.documents.forEach((document){
      if(i<400){
        writeBatch.updateData(document.reference ,{
          'ShowTo' : FieldValue.arrayRemove([uid]),
        });
        i++;
      }
      else{
        writeBatch.commit();
        writeBatch = Firestore.instance.batch();
        writeBatch.updateData(document.reference ,{
          'ShowTo' : FieldValue.arrayRemove([uid]),
        });
        i = 1;
      }
    });
    writeBatch.commit();
  }
  //-----------------------------Listening to changes -------------------------------
  void listenToChangesInGroup () {
    //Listen to changes in members info :
    _members.forEach((member){
      listenToChanges(member);
    });
    //Listen to changes on the groupInfoDoc :
  }
  void unsubscribeFromMembersSreams (){
    //_firestore.collection('users').where('UID' ,isEqualTo: '').snapshots().
  }
  Stream<DocumentSnapshot> groupsInfoStream (){
    return _groupInfoDoc.snapshots();
  }
  //On a member :
  void listenToChanges (Member member) {
    _firestore.collection('users').where('UID' ,isEqualTo: member.membersInfo.id).snapshots().listen((querySnapshot){
      querySnapshot.documentChanges.forEach((documentChange){
        switch(documentChange.type){
          case DocumentChangeType.modified :
            _onMemberGroupInfoModified(documentChange.document.data,member);
            break;
          case DocumentChangeType.removed :
            _onMemberRemoved(member);
            break;
          default :
            break;
        }
      });
    });
    _firestore.collection('usernames').where('UID' ,isEqualTo: member.membersInfo.id).snapshots().listen((querySnapshot){
      querySnapshot.documentChanges.forEach((documentChange){
        switch(documentChange.type){
          case DocumentChangeType.modified :
            _onMemberPublicInfoModified(documentChange.document.data,member);
            break;
          default :
            break;
        }
      });
    });
  }
  void _onMemberGroupInfoModified (Map<String,dynamic> data,Member member){
      member.membersInfo.setInfoGroup(data);
      notifyListeners();
  }
  void _onMemberPublicInfoModified(Map<String,dynamic> data,Member member){
    member.membersInfo.setInfoPublic(data);
    notifyListeners();
  }
  void _onMemberRemoved (Member member) {
    if(member.membersInfo.id == _adminID){
      removeAdminAndSet();
    }
    else
      removeMember(member);
    notifyListeners();
    addMesssage('This groupe has a new admin now : $_adminID', TypeMessage.AboutGroupe, '','') ;
  }
  Future<void> delete () async {
    await this._groupInfoDoc.delete();
    _members.forEach((member){
      _firestoreService.removeFromGroup(this._gid, member.membersInfo.id);
    });
  }

  //-----------------------------------------------------------------------------------------------

  //Getters
  String get nom => _nom;

  String get adminUsename => _adminID;

  String get gid => _gid;

  LatLng get lieuArrive => _destination;

  TypeGroupe get type => _type;

  DateTime get dateDepart => _dateDepart;

  List<Message> get discussion => _discussion;

  bool get visible => _visible;

  String get adminID => _adminID;

  bool get photo => _photo;

  String get groupPhoto => _groupPhoto;
  String get code => _invitationCode;

  Stream<DocumentSnapshot> get snapShots => _groupInfoDoc.snapshots();

  CollectionReference get discussionCollection => _discussionCollection;

  DateTime get lastReadMessage => _lastReadMessage;

  List<Member> get members => _members;


  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Group &&
              runtimeType == other.runtimeType &&
              _gid == other._gid;

  @override
  int get hashCode => _gid.hashCode;


}

enum TypeGroupe {
  Family,Friends,Work,Other
}
class Member implements Comparable<Member>{
    SharableUserInfo _membersInfo ;
    DateTime _dateTime ;
    DocumentReference _documentReference;
    Member.test(String id,DateTime dateTime,SharableUserInfo sharableUserInfo){
      _membersInfo = sharableUserInfo;
      _dateTime = dateTime;
    }
    Member (String id,DateTime dateTime,SharableUserInfo sharableUserInfo , DocumentReference documentReference){
      _membersInfo = sharableUserInfo;
      _dateTime = dateTime;
      _documentReference = documentReference;
    }
    @override
    int compareTo(Member member){
      return - dateTime.compareTo(member.dateTime);
    }

    DocumentReference get documentReference => _documentReference;
    DateTime get dateTime => _dateTime;
    SharableUserInfo get membersInfo => _membersInfo;

}
