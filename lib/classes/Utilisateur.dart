import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enum_to_string/enum_to_string.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/classes/Request.dart';
import 'package:whereuapp/classes/TimePlace.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:whereuapp/classes/Message.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:whereuapp/servises/DeviceInfoService.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/classes/transport.dart';
import 'package:location/location.dart';

class Utilisateur {
  //************************************* Attributs ***************************************************//
  SharableUserInfo _sharableUserInfo ;
  //Private info
  List<Vehicle>_listVehicles;
  List<TimePlace> _historique;
  Map<GroupHeader, bool> _groupes;
  DeviceInfoService _deviceInfoService ;
  Location _locationTracker = Location();
  //Boite de reception
  List<Request> _invitations ;
  Map<TypeMessage,List<String>> _messagesPersonalisees ;
  bool geolocalisation  ;
  bool batteryNotification ;
  bool speedNotification ;
  bool trajet ;
  //DB
  final Firestore _firestore = Firestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  DocumentReference _usersInfoDoc;


  //*****************************************Constructors*********************************************************//
  //Creer un nouveau utilisateur
  Utilisateur(String id,String displayName,String username,Gender gender,DateTime dateOfBirth) {
    //this._id = id;
    this._sharableUserInfo = SharableUserInfo(id,username, displayName,gender,dateOfBirth);
    //this._active = true;
    this._historique = new List<TimePlace>();
    this._groupes = new Map<GroupHeader, bool>();
    this._listVehicles = new List<Vehicle>();
    this._invitations = new List<Request>();
    this._messagesPersonalisees = new Map<TypeMessage,List<String>> ();
    this._deviceInfoService = DeviceInfoService(false);
    this._usersInfoDoc = _firestore.collection('users').document(id);
    onLocationChanged();
  }

  //Creer un utilisateur a partir d'un doc Firestore
  Utilisateur.old (String uid ,SharableUserInfo userInfo)
  {
    //this._id = uid ;
    this._usersInfoDoc = _firestore.collection('users').document(userInfo.id);
    this._sharableUserInfo = userInfo;
    this._groupes = new Map<GroupHeader,bool> ();
    this._listVehicles = new List<Vehicle> ();
    //TODO this._deviceInfoService = DeviceInfoService(getBatteryLevel);
    //TODO boite de reception
    this._invitations = new List<Request>();
    this._historique = new List<TimePlace>();
    onLocationChanged();
  }

  //*********************************************Methods*****************************************************//
  //------------------------------------------Online status --------------------------------------------

  //Change display name
  void listenToChanges() async {
    //final DeviceInfoService deviceInfoService =
    DeviceInfoService(true).listenToChangeStatus(this._sharableUserInfo.id);
  }
  //------------------------------------------Display name--------------------------------------------
  //Change display name
  Future<void> setDisplayName(String newDisplayName) async {
    await _firestore.collection('usernames').document(this.sharableUserInfo.username).updateData({
      'DisplayName' : newDisplayName,
    }).then((_){
      this._sharableUserInfo.displayName = newDisplayName;
    });
  }
  //------------------------------------------Photo--------------------------------------------
  Future<void> setPhoto(File file) async {
    await _uploadPhoto(file).then((_) async  {
      await _firestore.collection('usernames').document(this.sharableUserInfo.username).updateData({
        'Photo' : true ,
      }).then((_){
        _sharableUserInfo.photo = true;
        print('photo set');
      });
    }).catchError((error) {
      print('could\'nt set photo');
    });
  }

  Future<void> _uploadPhoto(File file) async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(this._sharableUserInfo.photoPath);
    final StorageUploadTask uploadTask = storageReference.putFile(file);
    final StorageTaskSnapshot downloadUrl = (await uploadTask.onComplete);
    final String url = (await downloadUrl.ref.getDownloadURL());
    print('photo url'+url);
  }

  Future<void> deletePhoto() async {
    StorageReference storageReference = FirebaseStorage.instance.ref().child(this._sharableUserInfo.photoPath);
    storageReference.delete().whenComplete(() {
      _sharableUserInfo.photo = false;
      print('Profile photo deleted');
    }).catchError((error) {
      print('Could\'t delete profile photo');
    });
  }
  //------------------------------------------Date of Birth--------------------------------------------
  void setDateOfBirth(DateTime dateOfBirth) async {
    await this._usersInfoDoc.updateData(
        {
          'DateOfBirth' : Timestamp.fromDate(dateOfBirth),
        }
    ).then((result) {
      this._sharableUserInfo.dateOfBirth=  dateOfBirth;
      print("DateOfBirth changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }
  //------------------------------------------Gender--------------------------------------------
  void setGender(Gender gender) async {
    await this._usersInfoDoc.updateData(
        {
          'Gender' : gender.toString(),
        }
    ).then((result) {
      this.sharableUserInfo.gender = gender;
      print("gender changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }

  //------------------------------------------Phone--------------------------------------------
  Future<void> setPhone(String phone) async {
    await this._usersInfoDoc.updateData(
        {
          "Phone": phone,
        }
    ).then((result) {
      this._sharableUserInfo.phone =  phone;
      print("phone number changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }

  Future<void> removePhone() async {
    await this._usersInfoDoc.updateData(
        {
          "Phone": FieldValue.delete(),
        }
    ).then((result) {
      this._sharableUserInfo.phone = null;
      print("phone number removed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }

  //------------------------------------------ActiveStatus--------------------------------------------
  //Change active status
  void changeActiveStatus() {
    bool b = !_sharableUserInfo.active;
    this._usersInfoDoc.updateData(
        {
          "Active": b,
        }
    ).then((result) {
      _sharableUserInfo.active = b;
      print("Status changed");
    }).catchError((error) {
      print("Error" + error.code);
    });
  }

  //---------------------------------------BatteryLevel------------------------------------------------
  void setBatteryLevel () async {
    while (true) {//_deviceInfoService.getBatteryLevel) {
      int bl = await _deviceInfoService.batteryLevel();
      this._usersInfoDoc.updateData({
        'BatteryLevel' : bl,
      }).then((_){
        _sharableUserInfo.batteryLevel = bl;
      });
      await Future.delayed(Duration(minutes: 1));
    }
  }

  void removeBatteryLevel () async {
    //_deviceInfoService.getBatteryLevel = false ;
    this._sharableUserInfo.batteryLevel = null;
    this._usersInfoDoc.updateData({
      'BatteryLevel' : FieldValue.delete(),
    });
  }

  //------------------------------------------Location--------------------------------------------
  Future<void> saveLocationToFirestore (LocationData locationData){
    this._sharableUserInfo.location = LatLng( locationData.latitude , locationData.longitude );
    print('we got cuurent position');
    print(this._usersInfoDoc.path);
    this._usersInfoDoc.updateData(
        {
          'Position': GeoPoint( locationData.latitude , locationData.longitude),
        }
    ).then((result) {
      print('position set');
    }).catchError((error) {
      print('Error : couldn\'t set position' + error.toString());
    });
  }
  Future<void> setLocation() async {
    //LocationData locationData =
    await _locationTracker.getLocation()
        .then((locationData) {
            saveLocationToFirestore(locationData);
    }).catchError((error) {
      print('Error : Couldn\'t get cuurent position' + error);
    });
  }
  void onLocationChanged () {
    _locationTracker.onLocationChanged.listen((newLocationData) async {
      await saveLocationToFirestore(newLocationData);
    });
  }

  Future<void> removeLocation() async {
    await this._usersInfoDoc.updateData(
        {
          "Position": FieldValue.delete(),
        }
    ).then((result) {
      print('Position removed');
      //this._sharableUserInfo.location = null;
    }).catchError((error) {
      print('Error : couldn\'t remove Position' + error.toString());
    });
  }
  //------------------------------------------Vitesse--------------------------------------------
  /*void setVitesse() async {
    Geolocator geolocator = Geolocator();
    Position location = await geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    double v = location.speed;
    this._usersInfoDoc.updateData(
        {
          'Vitesse': v,
        }
    ).then((result) {
      print('speed set');
      this._sharableUserInfo.vitesse = v;
    }).catchError((error) {
      print('Error : couldn\'t set speed' + error.toString());
    });
  }*/

  //------------------------------------------Transport --------------------------------------------
  void setTransport(Transport transport) {
    this._usersInfoDoc.updateData(
        {
          'Transport': transport.toString(),
        }
    ).then((result) {
      print('transport set');
      this._sharableUserInfo.transport = transport;
    }).catchError((error) {
      print('Error : couldn\'t set transport' + error.toString());
    });
  }

  void removeTransport() {
    this._usersInfoDoc.updateData(
        {
          "Transport": FieldValue.delete(),
        }
    ).then((result) {
      print('Transport removed');
      this._sharableUserInfo.transport = null;
    }).catchError((error) {
      print('Error : couldn\'t remove transport' + error.toString());
    });
  }

  //------------------------------------------Vehicles--------------------------------------------
  Future<void> getVehicles ()async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('vehicules').getDocuments();
    querySnapshot.documents.forEach((documentSnapshot){
      this._listVehicles.add(Vehicle.fromMap(documentSnapshot.data));
    });
  }
  Future<void> addVehicule(Vehicle v) async {
    await this._usersInfoDoc.collection('vehicules')
        .document(v.matricule).setData(v.vehicleToMap())
        .then((_) {
      this._listVehicles.add(v);
      print('vehicule added');
    }).catchError((error) {
      print('Couldn\'t add vehicule' + error.toString());
    });
  }

  Future<void> removeVehicule(Vehicle v) async {
    await this._usersInfoDoc.collection('vehicules')
        .document(v.matricule).delete()
        .then((_) {
      this._listVehicles.remove(v);
      print('Vehicule removed');
    }).catchError((error) {
      print('Couldn\'t remove vehicule' + error.toString());
    });
  }

  //------------------------------------------Historique--------------------------------------------
  void getHistorique () async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('historique').getDocuments();
    querySnapshot.documents.forEach((doc){
      _historique.add(TimePlace.fromMap(doc.data));
    });
  }
  void addToHistorique() {
    TimePlace timePlace = TimePlace(_sharableUserInfo.location, DateTime.now());
    Map<String, dynamic> data = timePlace.TimePlaceToMAp();
    data.putIfAbsent('Groupes', () => this.activeGroups());
    this._usersInfoDoc.collection('historique')
        .add(data)
        .whenComplete(() {
      print('Added to history');
    }).catchError((error) {
      print('could\'nt add to history');
    });
  }

  void supprimerHistorique() {
    //TODO _historique.supprimer();
  }

  void deleteGroupHistory(String groupe) async {
    QuerySnapshot querySnapshot = await this.getGroupHistory(groupe);
    querySnapshot.documents.forEach((doc) {
      List<String> groupes = doc.data['Groupes'];
      groupes.remove(groupe);
      doc.reference.updateData({
        'Groupes': groupes,
      });
    });
  }
  Future<QuerySnapshot> getGroupHistory(String groupe) async {
    return await _usersInfoDoc.collection('historique').where(
        'Groupes', arrayContains: groupe)
        .getDocuments();
  }



  //------------------------------------------Groupes--------------------------------------------
  Future<void> getUsersGroups() async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('groupes').getDocuments();
    for(DocumentSnapshot documentSnapshot in querySnapshot.documents){
      bool active = documentSnapshot.data['active'];
      //Groupe groupe = await _firestoreService.getGroupInfo(documentSnapshot.documentID);
      GroupHeader groupeHeader = await _firestoreService.getGroupHeader(documentSnapshot.documentID);
      this._groupes.putIfAbsent(groupeHeader, ()=> active);
    }
  }

  Future<List<GroupHeader>> getUsersGroupsHeaders () async {
    if (_groupes.isEmpty)
      await getUsersGroups();
    return List<GroupHeader>.from(_groupes.keys);
  }
  /*Stream<List<Groupe>> groupsStream () {
    Stream<QuerySnapshot> querySnapshotStream = this._usersInfoDoc.collection('groupes').getDocuments().asStream();
    return  querySnapshotStream.map((querySnapshot){
      List<Groupe> groupes = new List<Groupe> ();
      querySnapshot.documents.forEach((documentSnapshot) async {
        bool active = documentSnapshot.data['active'];
        Groupe groupe = await _firestoreService.getGroupInfo(documentSnapshot.documentID);
        this._groupes.putIfAbsent(groupe, ()=> active);
        groupes.add(groupe);
      });
      return groupes;
    });
  }*/
  //Adds a group to the user's groups list
  Future<void> addGroupe(String gid) async {
    DocumentReference doc = this._usersInfoDoc.collection('groupes').document(gid);
    doc.setData({
      'active': true,
    }).then((_) async {
      print('Group added');
      //Groupe groupe = await _firestoreService.getGroupInfo(gid);
      GroupHeader groupeHeader = await _firestoreService.getGroupHeader(gid);
      _groupes.putIfAbsent(groupeHeader, () => true);
    });
  }

  //Changes the user's active status for a specific groupe
  Future<void> changeActiveGroupe(GroupHeader groupHeader) async {
    DocumentReference doc = this._usersInfoDoc.collection('groupes').document(groupHeader.gid);
    bool b = _groupes[groupHeader];
    doc.updateData({
      'active': !b,
    }).then((_) {
      print('Active status for group changed');
      _groupes.update(groupHeader, (v) => !b);
    }).catchError(() {
      print('Couldn\'t change active status for group');
    });
  }

  Future<void> leaveGroup (Group group) async {
    if(group.members.length == 1){
      group.delete();
    }
    else
      await _firestoreService.removeFromGroup(group.gid, this.sharableUserInfo.id);
  }

  //Returns the list of groupes in which the user is active
  Future<List<GroupHeader>> activeGroups() async {
    if(_groupes.isEmpty){
      await getUsersGroups();
    }
    List<GroupHeader> activeGroupes = new List<GroupHeader> ();
      _groupes.forEach((groupe, active) {
        if (active) {
          activeGroupes.add(groupe);
        }
      });
    return activeGroupes;
  }

  //------------------------------------------Boite de reception--------------------------------------------
  //------------------------------------------Messages personalisées----------------------------------------
  void addCustomMessage (String type, String message){
    this._usersInfoDoc.collection('MessagesPersonalisees').document(type).updateData({
      'Messages' : FieldValue.arrayUnion([message]),
    }).then((_){
      _messagesPersonalisees[type].add(message);
    });
  }
  void deleteCustomMessage (String type , String message){
    this._usersInfoDoc.collection('MessagesPersonalisees').document(type).updateData({
      'Messages' : FieldValue.arrayRemove([message]),
    }).then((_){
      _messagesPersonalisees[type].remove(message);
    });
  }
  Future<void> getCustomMessages () async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('MessagesPersonalisees').getDocuments();
    querySnapshot.documents.forEach((documentSnapshot){
      if(documentSnapshot.data.isNotEmpty)
        _messagesPersonalisees.putIfAbsent(EnumToString.fromString(TypeMessage.values, documentSnapshot.documentID),
                                                           () => documentSnapshot.data[['Messages']]);
    });
  }
  Future<void> delete () async {
    QuerySnapshot querySnapshot = await this._usersInfoDoc.collection('groupes').getDocuments();
    WriteBatch deleteBatch = Firestore.instance.batch();
    querySnapshot.documents.forEach((document){
      deleteBatch.delete(document.reference);
    });
    querySnapshot = await this._usersInfoDoc.collection('tokens').getDocuments();
    querySnapshot.documents.forEach((document){
      deleteBatch.delete(document.reference);
    });
    deleteBatch.delete(_usersInfoDoc);
    deleteBatch.delete(_firestore.collection('usernames').document(this.sharableUserInfo.username));
    deleteBatch.commit();
  }
  //Getter
  DocumentReference get usersInfoDoc => _usersInfoDoc;

  Map<GroupHeader, bool> get groupes => _groupes;



  SharableUserInfo get sharableUserInfo => _sharableUserInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is Utilisateur &&
              runtimeType == other.runtimeType &&
              _sharableUserInfo.id == other._sharableUserInfo.id;

  @override
  int get hashCode => _sharableUserInfo.id.hashCode;

}





