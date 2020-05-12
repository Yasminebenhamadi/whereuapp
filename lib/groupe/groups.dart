import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:provider/provider.dart';
import 'package:whereuapp/Wrapper.dart';
import 'createcercle.dart';
import 'discussion.dart';
class Groups extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<Groups> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  Utilisateur utilisateur ;

  @override
  Widget build(BuildContext context){
    print('*************************************************************************');
    setState(() {
      utilisateur = Provider.of<User>(context).utilisateur;
    });
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        brightness: Brightness.light,
        iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
        backgroundColor: Color(0xff739D84),
        title: Text(
          'Groupes',
          style: TextStyle(
              color: Color(0xffF2E9DB),
              fontSize: 18.0,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () { Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> CreatePage())) ;},
        ),
      ),
      backgroundColor: Color(0xffF2E9DB),
      body: Container(
        child : Column(
          children: <Widget>[
            TypeAheadField (
              suggestionsCallback: (pattern) async {
                try{
                  return await _firestoreService.getPublicGroupes(pattern);
                }
                catch(e){
                  return null;
                }
              },
              itemBuilder: (context,suggestion) {
                GroupHeader group = suggestion;
                return ListTile(
                  title: Row(
                    children: <Widget>[
                      FutureBuilder(
                        future :_storageService.groupsImage(group.photo,group.groupPhoto),
                        builder: (context,asyncSnapshot) => CircleAvatar(
                          backgroundImage: asyncSnapshot.data,
                        ),
                      ),
                      Text(group.name),
                    ],
                  ),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                GroupHeader publicGroupe = suggestion;
                //TODO show public group's info
              },
            ),

            StreamBuilder<List<GroupHeader>>(
              stream : utilisateur.usersInfoDoc.collection('groupes').snapshots().asyncMap((querySnapshot) async  {
                List<GroupHeader> groups = List<GroupHeader> ();
                print('documments--------------------'+querySnapshot.documents.length.toString());
                for ( DocumentSnapshot documentSnapshot in  querySnapshot.documents) {
                  GroupHeader groupHeader = await _firestoreService.getGroupHeader(documentSnapshot.documentID);
                  print('+++++++++++++++++++++++++');
                  groups.add(groupHeader);
                  print('----------------------');
                }
                print(groups.length);
                return groups;
              }),
              builder: (BuildContext context,asyncSnapshot) {
                if (asyncSnapshot.hasError){
                  print(asyncSnapshot.error);
                  return Center(child: Text('Something went wrong'));
                }
                else if (!asyncSnapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else {
                  if (asyncSnapshot.data.length == 0){
                    return Column (
                        children: <Widget>[
                          Text('You haven\'t joined any groups yet'),
                        ],
                    );
                  }
                  else {
                    return Expanded(
                        child: ListView.builder(
                          itemCount: asyncSnapshot.data.length,
                          itemBuilder: (BuildContext context,int index){
                            GroupHeader groupHeader = asyncSnapshot.data[index];
                            return ListTile(
                              onTap: () async {
                                await _firestoreService.getGroupInfo(groupHeader.gid).then((group) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => chat  (group : group )));
                                });
                              },
                              title: Row(
                                children: <Widget>[
                                  FutureBuilder(
                                    future :_storageService.groupsImage(groupHeader.photo,groupHeader.groupPhoto),
                                    builder: (context,asyncSnapshot) => CircleAvatar(
                                      backgroundImage: asyncSnapshot.data,
                                    ),
                                  ),

                                  Text(groupHeader.name),
                                ],
                              ),
                              //TODO onLongPress: , ??? delete conv , notofication  maybe
                            );
                          },
                        )
                    );
                  }

                }
              },
            ),
          ],
        ),
      ),
    );
  }

/*void getGroupsImageSearch (bool photo , String groupPhoto) async {
    _groupsImageSearch = await _storageService.groupsImage(photo,groupPhoto);
  }
  void getGroupsImageList (bool photo , String groupPhoto) async {
    _groupsImageList = await _storageService.groupsImage(photo,groupPhoto);
  }*/
}/*import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:ourwonderfullapp/classes/Groupe.dart';
import 'package:ourwonderfullapp/classes/Utilisateur.dart';
import 'package:ourwonderfullapp/groupe/groupMembers.dart';
import 'package:ourwonderfullapp/servises/firestore.dart';
import 'package:ourwonderfullapp/servises/storage.dart';
import 'package:provider/provider.dart';
import 'package:ourwonderfullapp/Wrapper.dart';

class Groups extends StatefulWidget {

  @override
  _State createState() => _State();
}

class _State extends State<Groups> {
  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  Utilisateur utilisateur ;

  @override
  Widget build(BuildContext context){
    print('*************************************************************************');
    setState(() {
      utilisateur = Provider.of<User>(context).utilisateur;
    });
    return Scaffold(

      body: Container(
        child : Column(
          children: <Widget>[
            TypeAheadField (
              suggestionsCallback: (pattern) async {
                try{
                  return await _firestoreService.getPublicGroupes(pattern);
                }
                catch(e){
                  return null;
                }
              },
              itemBuilder: (context,suggestion) {
                GroupHeader group = suggestion;
                return ListTile(
                  title: Row(
                    children: <Widget>[
                      FutureBuilder(
                        future :_storageService.groupsImage(group.photo,group.groupPhoto),
                        builder: (context,asyncSnapshot) => CircleAvatar(
                          backgroundImage: asyncSnapshot.data,
                        ),
                      ),
                      Text(group.name),
                    ],
                  ),
                );
              },
              transitionBuilder: (context, suggestionsBox, controller) {
                return suggestionsBox;
              },
              onSuggestionSelected: (suggestion) {
                GroupHeader publicGroupe = suggestion;
                //TODO show public group's info
              },
            ),

            FutureBuilder<List<GroupHeader>>(
              future: utilisateur.getUsersGroupsHeaders(),
              builder: (BuildContext context,asyncSnapshot) {
                if (asyncSnapshot.hasError){
                  print(asyncSnapshot.error);
                  return Center(child: Text('Something went wrong'));
                }
                else if (!asyncSnapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                else {
                  if (asyncSnapshot.data.length == 0){
                    return Center(child: Text('No groups found'));
                  }
                  else {
                    return Expanded(
                        child: ListView.builder(
                          itemCount: asyncSnapshot.data.length,
                          itemBuilder: (BuildContext context,int index){
                            GroupHeader groupHeader = asyncSnapshot.data[index];
                            return ListTile(
                              onTap: () async {
                                await _firestoreService.getGroupInfo(groupHeader.gid).then((group) {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => Members(group: group,)));
                                });
                              },
                              title: Row(
                                children: <Widget>[
                                  FutureBuilder(
                                    future :_storageService.groupsImage(groupHeader.photo,groupHeader.groupPhoto),
                                    builder: (context,asyncSnapshot) => CircleAvatar(
                                      backgroundImage: asyncSnapshot.data,
                                    ),
                                  ),

                                  Text(groupHeader.name),
                                ],
                              ),
                              //TODO onLongPress: , ??? delete conv , notofication  maybe
                            );
                          },
                        )
                    );
                  }

                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /*void getGroupsImageSearch (bool photo , String groupPhoto) async {
    _groupsImageSearch = await _storageService.groupsImage(photo,groupPhoto);
  }
  void getGroupsImageList (bool photo , String groupPhoto) async {
    _groupsImageList = await _storageService.groupsImage(photo,groupPhoto);
  }*/
}*/
