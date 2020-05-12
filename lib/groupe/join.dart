import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/SharableUserInfo.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:whereuapp/settings/cercles_user.dart';
import 'package:provider/provider.dart';

// ignore: camel_case_types
class JoinConfirme extends StatefulWidget {
  final DocumentSnapshot groupInfo;
  JoinConfirme ({this.groupInfo});
  @override
  _JoinConfirmeState createState() => _JoinConfirmeState();
}

// ignore: camel_case_types
class _JoinConfirmeState extends State<JoinConfirme> {
  String name;
  List<String> members ;
  bool photo ;

  Utilisateur utilisateur;
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  final Firestore _firestore = Firestore.instance;
  @override
  void initState() {
    super.initState();
    name = widget.groupInfo.data['Nom'];
    photo = widget.groupInfo.data['Photo'];
    Map<String,Timestamp> membersMap = Map.from(widget.groupInfo.data['Members']);
    members = List<String>.from(membersMap.keys);
    //_loadFriends();
  }

  /*Future<void> _loadFriends() async {
    http.Response response =
    await http.get('https://randomuser.me/api/?results=25');

    setState(() {
      _friends = Friend.allFromResponse(response.body);
    });
  }*/

  Widget _buildFriendListTile(BuildContext context, int index) {
    //var friend = _friends[index];
    String uid = members[index];
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('usernames').where('UID' , isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {

        DocumentSnapshot documentSnapshot = snapshot.data.documents[0];
        return new ListTile(
          leading: new Hero(
            tag: index,

            child:  FutureBuilder(
              future: _storageService.usersPhoto(
                documentSnapshot.data['Photo'], 'users'+documentSnapshot.documentID + '/' + 'profilePhoto',Gender.Female), //Photo
              builder : (context,asyncSnapshot) => CircleAvatar(
                backgroundImage: asyncSnapshot.data,
              ),
            ),
          ),
          title: new Text(documentSnapshot.data['DisplayName']),
          subtitle: new Text(documentSnapshot.documentID), //Username
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      utilisateur = Provider.of<User>(context).utilisateur ;
    });
    return Scaffold(
        backgroundColor: Color(0xffF2E9DB),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 100.0,
            ),
            Text("Parfait ! Vous êtes sur le point de rejoindre le cercle $name" ,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20.0 ,
              fontWeight: FontWeight.bold,
              color: Color(0xff739D84)
            ),
            ),
            SizedBox(
              height: 15.0,
            ),
            Text("Voici ce qui vous attend" ,
            style: TextStyle(
              fontSize: 18.0 ,
              color: Color(0xff739D84)
            ),
            ),
            SizedBox(
              height: 40.0,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 20.0,
                ),
                Container(
                  alignment: Alignment.center,
                  height: 340.0,
                  width: 370,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                      color: Colors.white,
                      boxShadow : [BoxShadow (color:Color(0xFFF1B97A),
                          blurRadius:20.0,
                          offset:new Offset(2.0,2.0)),]),
                  child: Center(
                    child: ListView.builder(
                      itemCount: members.length,
                      itemBuilder: _buildFriendListTile,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 0.0,),
            Container(
              padding: EdgeInsets.symmetric(vertical: 25.0),
              width: 250.0,
              child: RaisedButton(
                elevation: 5.0,
                onPressed: () {
                  _firestoreService.addToGroupe(widget.groupInfo.documentID, utilisateur.sharableUserInfo.id);
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> cercleUser())) ;
                  },
                padding: EdgeInsets.all(15.0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0)),
                color: Color(0xffE8652D),
                child: Text(
                  '  Rejoindre  ',
                  style: TextStyle(
                      color: Color(0xffF1B97A),
                      letterSpacing: 1.5,
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              alignment: Alignment.bottomCenter,
              width: 250.0,
              child:  FlatButton(
                child:
                Text("Annuler",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color:Color(0xFFF1B97A),
                  ),
                ),
                onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> cercleUser())) ;},
              ),
            ),
          ],
        ));
  }
}
