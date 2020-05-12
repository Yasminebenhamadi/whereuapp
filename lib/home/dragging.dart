import 'package:flutter/material.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/servises/storage.dart';

class Dragging extends StatefulWidget {
  final Group group;
  Dragging ({this.group});
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<Dragging> {
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    if(widget.group != null )
      widget.group.getMembers();
  }

  Widget _buildFriendListTile(BuildContext context, int index) {
    Member member = widget.group.members[index];
    return new ListTile(
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
      //subtitle: new Text(friend.location),
    );
  }

  @override
  Widget build(BuildContext context) {
    return
      Container(
          child: DraggableScrollableSheet(
            initialChildSize: 0.1,
            minChildSize: 0.1,
            maxChildSize: 0.8,
            builder: (BuildContext context, myscrollController) {
              return
                Stack(children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.0),
                          topRight: Radius.circular(24.0)),
                    ),
                    margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0),
                    child:  ListView.builder(
                      controller: myscrollController,
                      itemCount: widget.group == null ? 0 : widget.group.members.length,
                      itemBuilder: _buildFriendListTile,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(left: 160,top: 5),
                    child:Container(
                      height: 6,
                      width: 36,
                      decoration: BoxDecoration(
                        color:Colors.black26,
                        borderRadius: BorderRadius.circular(20),
                      ),),),


                ]);
              },
          ),

      );
  }
  Widget button( IconData icon, Color color1 , Color color2) {
    return Container(
        height: 45,
        width: 45,
        child: FittedBox(
          child:
          FloatingActionButton(
            materialTapTargetSize: MaterialTapTargetSize.padded,
            backgroundColor: color1,
            child: Icon(
                icon,
                size: 30.0,
                color:color2
            ),
          ),
        )
    );
  }
}