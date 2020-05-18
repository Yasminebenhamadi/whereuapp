import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/groupe/createcercle.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:whereuapp/settings/gestion_cercle_admin.dart';
import 'package:provider/provider.dart';
import 'joincercle.dart';
import 'gestion_cercle.dart' ;

// ignore: camel_case_types
class cercleUser extends StatefulWidget {
  @override
  _cercleUserState createState() => _cercleUserState();
}

// ignore: camel_case_types
class _cercleUserState extends State<cercleUser> {

  final FirestoreService _firestoreService = FirestoreService();
  final StorageService _storageService = StorageService();
  Utilisateur utilisateur ;
  @override
  void initState() {
    super.initState();
    utilisateur = Provider.of<User>(context, listen: false).utilisateur;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF2E9DB),
        appBar: AppBar(
          elevation: 0,
          brightness: Brightness.light,
          iconTheme: IconThemeData(color: Color(0xffF2E9DB)),
          backgroundColor: Color(0xff739D84),
          title: Text(
            'Gestion de cercle',
            style: TextStyle(
                color: Color(0xffF2E9DB),
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {
            moveToLastSreen() ;
          }),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                SizedBox( width: 10,) ,
                FlatButton(
                  onPressed:() => Navigator.of(context).push(new MaterialPageRoute( builder :
                      (BuildContext context ) => new Join(),)),
                  padding :EdgeInsets.all(7.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.group , color: Color(0xffF2E9DB),) ,
                      Text(" Rejoindre", style : TextStyle(fontSize:15.0,fontWeight:FontWeight.bold)),
                    ],
                  ) ,
                  color:  Color(0xffF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Color(0xffF2E9DB),
                ),
                SizedBox(width: 10.0,),
                FlatButton(
                  onPressed:() => Navigator.of(context).push(new MaterialPageRoute( builder :
                      (BuildContext context ) => new CreatePage(),)),
                  padding :EdgeInsets.all(7.0),
                  child: Row(
                    children: <Widget>[
                      Icon(Icons.group_add , color: Color(0xffF2E9DB),) ,
                      Text(" Créer", style : TextStyle(fontSize:15.0,fontWeight:FontWeight.bold)),
                    ],
                  ) ,
                  color:  Color(0xffF1B97A),
                  shape:RoundedRectangleBorder(borderRadius:BorderRadius.circular(30.0),),
                  textColor: Color(0xffF2E9DB),
                ),
                SizedBox( width: 30,) ,
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Row(
              children: <Widget>[
                SizedBox(
                  width: 30.0,
                ),
                Container(
                  alignment: Alignment.center,
                  height: 290.0,
                  width: 350,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.0),
                     color: Colors.white,
                      boxShadow : [BoxShadow (color:Colors.black12,
                          blurRadius:20.0,
                          offset:new Offset(10.0,10.0)),]),

                  child: Center(
                    child: StreamBuilder<List<GroupHeader>>(
                      stream : utilisateur.usersInfoDoc.collection('groupes').snapshots().asyncMap((querySnapshot) async  {
                        List<GroupHeader> groups = List<GroupHeader> ();
                        for ( DocumentSnapshot documentSnapshot in  querySnapshot.documents) {
                          print('documments--------------------'+querySnapshot.documents.length.toString());
                          GroupHeader groupHeader = await _firestoreService.getGroupHeader(documentSnapshot.documentID);
                          groups.add(groupHeader);
                        }
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
                            return ListView.builder(
                                  itemCount: asyncSnapshot.data.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    GroupHeader groupHeader = asyncSnapshot.data[index];
                                    return new ListTile(
                                      trailing:  Icon (Icons.chevron_right,color:  Color(0xffE8652D), ) ,
                                      onTap : ()async {
                                        await _firestoreService.getGroupInfo(groupHeader.gid).then((group) {
                                          Provider.of<User>(context, listen: false).setGroup(group);
                                          if(group.adminID == utilisateur.sharableUserInfo.id)
                                          {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => gestionCercleAdmin (group : group )));
                                          }
                                          else
                                          {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => gestionCercle (group : group )));
                                          }
                                        });
                                      },
                                      leading: new Hero(
                                        tag: index,
                                        child: FutureBuilder(
                                          future :_storageService.groupsImage(groupHeader.photo,groupHeader.groupPhoto),
                                          builder: (context,asyncSnapshot) => CircleAvatar(
                                            backgroundImage: asyncSnapshot.data,
                                          ),
                                        ),
                                      ),
                                      title: new Text(groupHeader.name),
                                    );
                                  }
                            );
                          }

                        }
                      },
                    ),
                  ),
                ),
              ],
            )
          ],
        ));
  }
  moveToLastSreen(){
    Navigator.pop(context) ;
  }
}
