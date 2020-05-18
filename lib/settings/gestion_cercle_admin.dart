import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/classes/Utilisateur.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:whereuapp/settings/cercles_user.dart';
import 'package:provider/provider.dart';
import 'inviter.dart';
import 'nomcercle.dart';
import 'typegroupe.dart';
import 'package:flutter/cupertino.dart';
// ignore: camel_case_types
class gestionCercleAdmin extends StatefulWidget {
  final Group group;
  gestionCercleAdmin ({this.group});
  @override
  _gestionCercleAdminState createState() => _gestionCercleAdminState();
}

// ignore: camel_case_types
class _gestionCercleAdminState extends State<gestionCercleAdmin> {

  Utilisateur utilisateur;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    utilisateur = Provider.of<User>(context, listen: false).utilisateur;
    widget.group.getMembers();
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    Member member = widget.group.members[index];

    return new ListTile(
      trailing:  Icon (Icons.expand_more,color:  Color(0xffE8652D), ) ,
      onTap : (){showDialog(barrierDismissible:false ,
        context: context ,
        builder : (context){ return AlertDialog( title: Text("Supprimer le membre", style: TextStyle( color: Color(0xff739D84),)),
          actions: <Widget> [
            FlatButton ( child: Text ('Oui', style: TextStyle( color:  Color(0xffE8652D),)), onPressed:(){
              widget.group.removeMember(member);
              Navigator.pop(context);
            }),
            FlatButton ( child: Text ('Non',
                style: TextStyle( color:  Color(0xffE8652D),)),
                onPressed:(){Navigator.pop(context);}),
          ],
        );
        },) ; } ,

      leading: new Hero(
        tag: index,
        child: FutureBuilder(
          future: _storageService.usersPhoto(
              member.membersInfo.photo,member.membersInfo.photoPath,member.membersInfo.gender), //Photo
          builder : (context,asyncSnapshot) => CircleAvatar(
            backgroundImage: asyncSnapshot.data,
          ),
        ),
      ),
      title: new Text(member.membersInfo.displayName ),
      subtitle: new Text(member.membersInfo.username),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xffF2E9DB),
        appBar: AppBar(
          elevation: 0,
          brightness: Brightness.light,
          iconTheme: IconThemeData( color:Color(0xffF2E9DB) ),
          backgroundColor: Color(0xff739D84),
          title: Text(widget.group.nom , style: TextStyle(
              color: Color(0xffF2E9DB),
              fontSize: 18.0,
              fontWeight: FontWeight.bold
          ),),
          leading: IconButton(
              icon: Icon(Icons.clear),
              onPressed: () {
                moveToLastSreen();
              }),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(
                height: 30.0,
              ),
              Container(
                alignment: Alignment.center,
                height: 200.0,
                width: 350,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.white,
                    boxShadow : [BoxShadow (color:Colors.black12,
                        blurRadius:20.0,
                        offset:new Offset(10.0,10.0)),]),

                child: Center(
                  child: ListView.builder(
                    itemCount: widget.group.members.length,
                    itemBuilder: _buildFriendListTile,
                  ),
                ),
              ),
              SizedBox(
                height: 50.0,
              ),

              Card(

                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  margin: const EdgeInsets.only(left: 18.0, right: 18.0),
                  color: Colors.white ,
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () =>  Navigator.of(context)
                            .pushReplacement(new MaterialPageRoute(
                            builder: (BuildContext context) =>
                            new NamecerclePage(/*group: widget.group*/))),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.group),
                                iconSize: 30.0,
                                color: Color(0xffE8652D),
                                onPressed: () {}),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Modifier le nom de cercle',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(
                              width: 25.0,
                            ),
                            IconButton(
                              icon: Icon(Icons.edit),
                              iconSize: 30.0,
                              color: Color(0xffF1B97A),
                              onPressed: () => Navigator.of(context)
                                  .pushReplacement(new MaterialPageRoute(
                                builder: (BuildContext context) =>
                                new NamecerclePage(/*group: widget.group*/),
                              )),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 350.0,
                        height: 1.0,
                        color: Colors.grey.shade400,
                      ),
                      GestureDetector(
                        onTap: ( ) => Navigator.of(context)
                            .pushReplacement(new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new RadioButtonExample(/*group: widget.group*/),
                        )),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.tag_faces),
                                iconSize: 30.0,
                                color: Color(0xffE8652D),
                                onPressed: () {}),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Modifier le type de cercle',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(
                              width: 25.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.edit),
                                iconSize: 30.0,
                                color: Color(0xffF1B97A),
                                onPressed: () => Navigator.of(context)
                                    .pushReplacement(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  new RadioButtonExample(/*group: widget.group*/),
                                ))
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: 350.0,
                        height: 1.0,
                        color: Colors.grey.shade400,
                      ),
                      GestureDetector(
                        onTap:  () => Navigator.of(context)
                            .pushReplacement(new MaterialPageRoute(
                          builder: (BuildContext context) =>
                          new InvitePage(/*group: widget.group*/)
                        )),
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.group_add),
                                iconSize: 30.0,
                                color: Color(0xffE8652D),
                                onPressed: () {}),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Inviter des gens',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(
                              width: 110.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.chevron_right),
                                iconSize: 30.0,
                                color: Color(0xffF1B97A),
                                onPressed: ()  => Navigator.of(context)
                                    .pushReplacement(new MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                  new InvitePage(/*group: widget.group*/),
                                )))
                          ],
                        ),
                      ),
                      Container(
                        width: 350.0,
                        height: 1.0,
                        color: Colors.grey.shade400,
                      ),
                      GestureDetector(
                        onTap:  () {showDialog(barrierDismissible:false ,
                          context: context ,
                          builder : (context){ return AlertDialog( title: Text("êtes vous sure de quitter ce cercle ?", style: TextStyle( color: Color(0xff739D84),)),
                            actions: <Widget> [
                              FlatButton ( child: Text ('Quitter', style: TextStyle( color:  Color(0xffE8652D),)),
                                  onPressed:(){
                                    utilisateur.leaveGroup(widget.group);
                                    Navigator.pushReplacement(context , MaterialPageRoute (builder: (context)=> cercleUser()));
                                  }
                              ),
                              FlatButton ( child: Text ('Annuler',
                                  style: TextStyle( color:  Color(0xffE8652D),)),
                                  onPressed:(){Navigator.pop(context);}),
                            ],
                          );
                          },) ; },
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.call_missed_outgoing),
                                iconSize: 30.0,
                                color: Color(0xffE8652D),
                                onPressed: () {}),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text(
                              'Quitter le cercle',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18.0,
                              ),
                            ),
                            SizedBox(
                              width: 112.4,
                            ),
                            IconButton(
                                icon: Icon(Icons.chevron_right),
                                iconSize: 30.0,
                                color: Color(0xffF1B97A),
                                onPressed: () {showDialog(barrierDismissible:false ,
                                  context: context ,
                                  builder : (context){ return AlertDialog( title: Text("êtes vous sure de quitter ce cercle ?", style: TextStyle( color: Color(0xff739D84),)),
                                    actions: <Widget> [
                                      FlatButton ( child: Text ('Quitter', style: TextStyle( color:  Color(0xffE8652D),)),
                                          onPressed:(){
                                            utilisateur.leaveGroup(widget.group);
                                            Navigator.pushReplacement(context , MaterialPageRoute (builder: (context)=> cercleUser()));
                                          }
                                      ),
                                      FlatButton ( child: Text ('Annuler',
                                          style: TextStyle( color:  Color(0xffE8652D),)),
                                          onPressed:(){Navigator.pop(context);}),
                                    ],
                                  );
                                  },) ; }  )
                          ],
                        ),
                      ),Container(
                        width: 350.0,
                        height: 1.0,
                        color: Colors.grey.shade400,
                      ),
                      GestureDetector(
                        onTap: (){showDialog(barrierDismissible:false ,
                          context: context ,
                          builder : (context){ return AlertDialog( title: Text("êtes vous sure de supprimer ce cercle ?", style: TextStyle( color: Color(0xff739D84),)),
                            actions: <Widget> [
                              FlatButton ( child: Text ('Supprimer', style: TextStyle( color:  Color(0xffE8652D),)), onPressed:(){
                                widget.group.delete();
                                Navigator.pop(context);
                              }),
                              FlatButton ( child: Text ('Annuler',
                                  style: TextStyle( color:  Color(0xffE8652D),)),
                                  onPressed:(){Navigator.pop(context);}),
                            ],
                          );
                          },) ; },
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 10.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.delete),
                                iconSize: 30.0,
                                color:Color(0xffE8652D),
                                onPressed: () {}),
                            SizedBox(
                              width: 10.0,
                            ),
                            Text('Supprimer le cercle', style: TextStyle(
                              color: Colors.black,
                              fontSize: 18.0,

                            ),),
                            SizedBox(
                              width:81.0,
                            ),
                            IconButton(
                                icon: Icon(Icons.chevron_right),
                                iconSize: 30.0,
                                color: Color(0xffF1B97A),
                                onPressed: () {showDialog(barrierDismissible:false ,
                                  context: context ,
                                  builder : (context){ return AlertDialog( title: Text("êtes vous sure de supprimer ce cercle ?", style: TextStyle( color: Color(0xff739D84),)),
                                    actions: <Widget> [
                                      FlatButton ( child: Text ('Supprimer', style: TextStyle( color:  Color(0xffE8652D),)), onPressed:(){
                                         widget.group.delete();
                                        Navigator.pop(context);
                                      }),
                                      FlatButton ( child: Text ('Annuler',
                                          style: TextStyle( color:  Color(0xffE8652D),)),
                                          onPressed:(){Navigator.pop(context);}),
                                    ],
                                  );
                                  },) ; } )
                          ],
                        ),
                      ),
                    ],
                  )
              ),
            ],
          ),
        )
    );
  }
  moveToLastSreen() {
    Navigator.pop(context);
  }
}

class ProfileImageAsset extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AssetImage assetImage = AssetImage(
      'profile.gif',);
    Image image = Image(image: assetImage, fit: BoxFit.cover);
    return Container(
      child: image,
    );
  }
}
