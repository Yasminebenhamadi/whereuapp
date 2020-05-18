
import 'package:flutter/material.dart';
import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:provider/provider.dart';

class Members extends StatefulWidget {
  final Group group ;
  Members({Key key, @required this.group}) : super(key: key);
  @override
  _MembersState createState() => _MembersState();
}

class _MembersState extends State<Members> {
  final StorageService _storageService = StorageService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: FutureBuilder<List<Member>>(
          future: widget.group.getMembers(),
          builder: (BuildContext context,AsyncSnapshot asyncSnapshot){
            if(asyncSnapshot.data == null){
              return Container(
                child: Text('Loading....'),
              );
            }
            else {
              return Expanded(
                child: ListView.builder(
                  itemCount: asyncSnapshot.data.length,
                  itemBuilder: (BuildContext context,int index){
                    Member member = asyncSnapshot.data[index];
                    return ListTile(
                      title: Row(
                        children: <Widget>[
                          FutureBuilder(
                            future: _storageService.usersPhoto(member.membersInfo.photo,member.membersInfo.photoPath,member.membersInfo.gender),
                            builder: (context,asyncSnapshot) => CircleAvatar(
                              backgroundImage: asyncSnapshot.data,
                            ),
                          ),
                          Text(
                              Provider.of<User>(context).utilisateur.sharableUserInfo.id != member.membersInfo.id
                                                                      ? member.membersInfo.displayName
                                                                      : 'You'
                          ),
                        ],
                      ),
                      // TODO onTap: , ??
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
