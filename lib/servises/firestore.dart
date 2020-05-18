import  'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/classes/Request.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';

class FirestoreService {

  final Firestore _firestore = Firestore.instance;

  Firestore get firestore => _firestore;
  //-------------------------------------------Utilisateur--------------------------------------------
  //Create a new User doc of the user
  Future<void> createAccount(String uid,String username,String displayName,Gender gender,DateTime dateOfBirth) async
  {
    print('++++++'+(await userNameExists(username)).toString());
    print('uid : $uid , username : $username , displayname : $displayName , Gender : $gender , data : $dateOfBirth');
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging ();
    String fcmToken = await _firebaseMessaging.getToken();
    print(fcmToken);
        WriteBatch writeBatch = _firestore.batch();
        DocumentReference usernameDoc = _firestore.collection('usernames').document(username);
        writeBatch.setData(usernameDoc, usernameMap(uid,displayName));
        writeBatch.setData(_firestore.collection('users').document(uid),{
          'UID' : uid,
          //'Displayname' : _displayName ,
          'Username' : username,
          'Photo' : false,
          'Active' : true ,
          'Gender' : gender.toString(),
          'DateOfBirth' : Timestamp.fromDate(dateOfBirth),
          'Online' : true,
        });
        writeBatch.setData(_firestore.collection('users').document(uid).collection('tokens').document(fcmToken), {
          'token': fcmToken,
          'createdAt': FieldValue.serverTimestamp(), // optional
        });
        print('writiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiing');
        await writeBatch.commit();
  }
  Future<void> setToken (String uid) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging ();

    String fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      var tokens = _firestore
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);

      await tokens.setData({
        'token': fcmToken,
        'createdAt': FieldValue.serverTimestamp(), // optional
      });
    }
  }
  Future<void> removeToken (String uid) async {
    FirebaseMessaging _firebaseMessaging = FirebaseMessaging ();
    String fcmToken = await _firebaseMessaging.getToken();
    if (fcmToken != null) {
      var tokens = _firestore
          .collection('users')
          .document(uid)
          .collection('tokens')
          .document(fcmToken);

      await tokens.delete();
    }
  }
  Future<SharableUserInfo> getUserInfo(String id) async
  {
      Map<String,dynamic> data;
      Map<String,dynamic> publicData;
      DocumentSnapshot documentSnapshot = await _firestore.collection("users").document(id).get();
      if (documentSnapshot.exists) {
        data = documentSnapshot.data;
        publicData = await getPublicInfo(data['Username']);
        data.addAll(publicData);
        print(data);
        //await setToken(id);
        return SharableUserInfo.fromMap(id, data);
      }
      else
        throw CouldNotFoundUserData () ;
  }

  Future<Map<String,dynamic>> getPublicInfo(String username) async
  {
    Map<String,dynamic> publicData;
    DocumentSnapshot publicDocumentSnapshot = await _firestore.collection('usernames').document(username).get();
    if (publicDocumentSnapshot.exists){
      publicData = publicDocumentSnapshot.data;
      return publicData;
    }
    else
      throw CouldNotFoundUserData () ;
  }


  Future<void> addToGroupe (String gid,String uid) async {
    WriteBatch batch = _firestore.batch();
    /*await _firestore.collection('users').document(uid).collection('groupes').document('groupes').updateData({
      gid : true,
    }).then((_){
      print('Group added');
    }).catchError((){
      print('Couldn\'t add group');
    });
    await _firestore.collection("groups").document(gid).updateData({
      'Members' : FieldValue.arrayUnion([uid]),
    })
        .then((_){
      print('member added');
    })
        .catchError((error){
      print('Couldn\'t add member');
    });*/
    batch.setData(_firestore.collection('users').document(uid).collection('groupes').document(gid), {'active': true,});
    batch.updateData( _firestore.collection("groups").document(gid), {
      'Members.'+uid : Timestamp.now(),
    });
    batch.commit();
  }
  Future<void> removeFromGroup (String gid,String uid) async {
    WriteBatch batch = _firestore.batch();
    batch.delete(_firestore.collection('users').document(uid).collection('groupes').document(gid));
    DocumentSnapshot documentSnapshot = await _firestore.collection("groups").document(gid).get();
    Map<String,Timestamp> members = Map.from(documentSnapshot.data['Members']);
    members.remove(gid);
    batch.updateData( _firestore.collection("groups").document(gid), {
      'Members': members,
    });
    batch.commit();
  }

  //-------------------------------------------Groupes--------------------------------------------
  Future<Group> createGroupDoc (String nom,String adminID,bool photo) async
  {
    String code =  generateCode () ;
    print('cooooode'+code);
    //WriteBatch batch = _firestore.batch ();
    Group  group ;
    await _firestore.runTransaction( (transaction) async {
      DocumentReference invitationCodeDoc = _firestore.collection('invitationCodes').document(code);
      await transaction.get(invitationCodeDoc).then((documentSnapshot) async {
        if(documentSnapshot.exists)
           group = await  createGroupDoc(nom, adminID, photo);
        else {
          DocumentReference groupDoc = await _firestore.collection("groups")
              .add(Group.groupMap(nom, adminID, photo, code));
          transaction.set(invitationCodeDoc, {
            'GID': groupDoc.documentID,
          });
          /*await invitationCodeDoc.setData({
            'GID': groupDoc.documentID,
          });*/
          transaction.set(_firestore.collection('publicGroupes')
              .document(groupDoc.documentID), GroupHeader(groupDoc.documentID, nom, photo).groupHeaderToMap());
          /*await _firestore.collection('publicGroupes')
              .document(groupDoc.documentID)
              .setData(
              GroupHeader(groupDoc.documentID, nom, photo).groupHeaderToMap());*/
          print('hiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
          group =  new Group(groupDoc.documentID, nom, adminID, photo, code);
        }
      });
    });
    return group;
    /*List<String> membersUsernames = new List<String> ();
    DocumentReference groupDoc = await _firestore.collection("groups")
        .add(Group.groupMap(nom,adminID,photo,code));

    await _firestore.collection('publicGroupes').document(groupDoc.documentID).setData(GroupHeader(groupDoc.documentID,nom,photo).groupHeaderToMap()).then((_)=>print('Public groupppppppppppp'));
    */
  }
  Future<GroupHeader> getGroupHeader(String gid) async
  {
    try{
      GroupHeader g ;
      await _firestore.collection("groups").document(gid).get().then((grpData){
        if(grpData.exists)
        {
          Map<String,dynamic> data = grpData.data;
          g =GroupHeader.fromMap(gid, data);
          print(g.gid+' '+g.name+' '+g.photo.toString());
        }
        else
        {
          print('Couldn\'t find group\'s data');
          g = null;
        }
      }).catchError((error){
        print('Something went wrong'+error.toString());
      });
      return g;
    }
    catch(e){
      print('error while getting group\'s info'+e.code);
      return null;
    }
  }
  Future<Group> getGroupInfo(String gid) async
  {
    try{
      Group g;
      await _firestore.collection("groups").document(gid).get().then((grpData){
        if(grpData.exists)
        {
          Map<String,dynamic> data = grpData.data;
          g = Group.old(gid,data);
          print(g.gid+' '+g.nom+' '+g.adminUsename);
        }
        else
        {
          print('Couldn\'t find group\'s data');
          g = null;
        }
      }).catchError((error){
        print('Something went wrong'+error.toString());
      });
      return g;
    }
    catch(error){
      print('error while getting group\'s info'+toString());
      return null;
    }
  }
  //--------------------------------------------Invitations--------------------------------------------
  Future<bool> joinGroup (String invitationCode,String uid) async {
    QuerySnapshot querySnapshot = await _firestore.collection('groups').where('InvitationCode' , isEqualTo: invitationCode).getDocuments();
    if(querySnapshot.documents.isEmpty)
      return false ;
    else if (querySnapshot.documents.length ==1){
      await addToGroupe(querySnapshot.documents[0].documentID, uid);
      return true;
    }
    else
     {
       print('Something is offff this should not happen');
       return false;
     }
  }
  Future<DocumentSnapshot> groupFromCode (String invitationCode) async {
    QuerySnapshot querySnapshot = await _firestore.collection('groups').where('InvitationCode' , isEqualTo: invitationCode).getDocuments();
    if(querySnapshot.documents.isEmpty)
      return null ;
    else if (querySnapshot.documents.length == 1){
      return querySnapshot.documents[0];
    }
    else
    {
      print('Something is offff this should not happen');
      return null;
    }
  }
  Future<Request> sendInvitationFromGroup(String invitationCode,String toUID,String fromUID,String gid,String fromDisplayName) async {
    Request r ;
    String requestID;
    await _firestore.collection('invitationsFromGroup').add(RequestFromGroupe.requestToMap(toUID, fromUID, gid, fromDisplayName, invitationCode)).then((doc){
        requestID = doc.documentID;
        print('request added');
        r =  RequestFromGroupe(requestID, toUID, fromUID, gid ,fromDisplayName,invitationCode);
    }).catchError((e){
        print('Couldn\'t add invitation'+e.code);
    });
    return r;
  }
  Request sendInvitationFromUser(String toUID,String fromUID,String gid,fromDisplayName ){
    Request r ;
    String requestID;
    _firestore.collection('invitationsFromUser').add(RequestFromUser.requestToMap(toUID, fromUID, gid, fromDisplayName)).then((doc){
        print('request added');
        r =  RequestFromUser(requestID, toUID, fromUID, gid ,fromDisplayName);
    }).catchError((e){
      print('Couldn\'t add invitation'+e.code);
    });
    return r;
  }

  void deleteInvitation (Request request) async{
    await _firestore.collection('invitations').document(request.requestID).delete().then((_){
      print('Invitation deleted');
    }).catchError((e){
      print('Couldn\'t delete invitation');
    });
  }
  //----------------------------Usernames----------------------------------------------
  Map<String,dynamic> usernameMap (String uid,String displayName){
    return {
      'UID' : uid,
      'DisplayName' : displayName,
      'Photo' : false ,
    };
  }
   Future<bool> userNameExists (String username) async {
        DocumentSnapshot snapshot = await _firestore.collection('usernames').document(username).get() ;
        print(snapshot.exists) ;
        return snapshot.exists  ;
  }

  Future<void> addUsername (String uid,String displayName,String username)async {
    /*if (!await userNameExists(username)){
      await usernameDoc.setData(usernameMap(uid,displayName));
    }
    else
      throw UsernameExistsException();*/
    _firestore.runTransaction( (transaction){
      DocumentReference usernameDoc = _firestore.collection('usernames').document(username);
      return transaction.get(usernameDoc).then((documentSnapshot) async {
        if(documentSnapshot.exists)
          throw UsernameExistsException();
        else{
          await transaction.set(usernameDoc, usernameMap(uid,displayName));
          print('username added');
        }
      });
    });
  }
  //----------------------------Invitation codes--------------------------------------------
  Future<String> getGroupID (String code) async {
    DocumentSnapshot snapshot = await _firestore.collection('invitationCodes').document(code).get() ;
    if (snapshot.exists)
      return snapshot.data['GID'];
    else
      return null;
  }
  Future<void> addInvitationCode (String gid) async {
    String code =  generateCode () ;
    /*DocumentReference invitationCodeDoc = _firestore.collection('invitationCodes').document(code);
    if (await getGroupID(code)==null) {
      invitationCodeDoc.setData({
          'GID' : gid,
      });
      return code ;
    }
    else
      throw CodeExistsException();*/
    await _firestore.runTransaction( (transaction){
      DocumentReference invitationCodeDoc = _firestore.collection('invitationCodes').document(code);
      return transaction.get(invitationCodeDoc).then((documentSnapshot){
        if(documentSnapshot.exists)
          throw CodeExistsException();
        else{
          return invitationCodeDoc.setData({
            'GID' : gid,
          }).then((_) => code );
          //return code ;
        }
      });
    });
  }

  String generateCode (){
    List<String> chars =['0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F','G','H','I','J','K','L','M','N', 'O','P','Q', 'R', 'S', 'T','U',
                         'V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z'];
    Random random = Random ();
    String code = '';
    for(int i =0;i<5;i++){
      code = code + chars[random.nextInt(61)];
    }
    return code;
  }
    //----------------------------Public groupes----------------------------------------------
  Future<List<GroupHeader>> getPublicGroupes(Pattern pattern) async {
    List<GroupHeader> publicGroupes  = List<GroupHeader>();

    QuerySnapshot snapshot = await _firestore.collection('publicGroupes').where('Nom',isGreaterThanOrEqualTo: pattern)
                                                                              .where('Nom',isLessThan: next(pattern)).getDocuments();
    snapshot.documents.forEach((documentSnapshot){
      if(documentSnapshot.exists){
        String nom = documentSnapshot.data['Nom'];
        if(nom.startsWith(pattern)){
          publicGroupes.add(GroupHeader.fromMap(documentSnapshot.documentID,documentSnapshot.data));
        }
      }
    });
    return publicGroupes;
  }
  String next(String string){
    return  string.substring(0,string.length - 1) +
                    String.fromCharCode(string.codeUnitAt(string.length-1)+ 1);
  }
  //Others
  GeoPoint firestorePosition (Position position ){
    return GeoPoint(position.latitude, position.longitude);
  }
  Timestamp firestoreDateTime(DateTime date){
    return Timestamp.fromDate(date);
  }
}
class UsernameExistsException implements Exception {
  String _code ;
  UsernameExistsException(){this._code = 'USERNAME_EXISTS';}
  String get code => _code;
}
class CodeExistsException implements Exception {
  String _code ;
  CodeExistsException(){this._code = 'INVITATION_CODE_EXISTS';}
  String get code => _code;
}
class CouldNotFoundUserData implements Exception {
  String _code ;
  CouldNotFoundUserData(){this._code = 'USEDATA_NOT_FOUND';}
  String get code => _code;
}