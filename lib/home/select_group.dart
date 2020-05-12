import 'package:whereuapp/Wrapper.dart';
import 'package:whereuapp/classes/Groupe.dart';
import 'package:whereuapp/servises/firestore.dart';
import 'package:whereuapp/servises/storage.dart';
import 'package:whereuapp/unknownError.dart';
import 'package:provider/provider.dart';
import 'direct_select_container.dart';
import 'direct_select_item.dart';
import 'direct_select_list.dart';
import 'package:flutter/material.dart';


class MyGroup extends StatefulWidget {
  MyGroup({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _MyGroupState createState() => _MyGroupState();
}

class _MyGroupState extends State<MyGroup> {

  final buttonPadding = const EdgeInsets.fromLTRB(0, 30, 0, 0);
  final StorageService _storageService = StorageService();
  final FirestoreService _firestoreService = FirestoreService() ;

  Group selectedGroup ;

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      key: scaffoldKey,
      body: DirectSelectContainer(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              verticalDirection: VerticalDirection.down,
              children: <Widget>[
                SizedBox(height: 20.0),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      //---------------------------------------GroupSelector------------------------------------------------------
                      FutureBuilder<List<GroupHeader>>(
                          future: Provider.of<User>(context).utilisateur.getUsersGroupsHeaders(),
                          builder: (buildContext,asyncSnapshot)
                          {
                            if (asyncSnapshot.hasError){
                              return Center(child: Text('Something went wrong'));
                            }
                            else if (!asyncSnapshot.hasData){
                              return Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            else  {
                              List<GroupHeader> groups = asyncSnapshot.data ;
                              return Column(
                                children: [
                                  Padding(
                                    padding: buttonPadding,
                                    child: Container(
                                      decoration: _getShadowDecoration(),
                                      child: Card(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.max,
                                            children: <Widget>[
                                              Expanded(
                                                  child: Padding(
                                                      child: DirectSelectList<GroupHeader>(
                                                        values: groups,
                                                        defaultItemIndex: 0,
                                                        onItemSelectedListener: (groupHeader, int, context) async {
                                                          try {
                                                            Group group = await _firestoreService.getGroupInfo(groupHeader.gid);
                                                            setState(() {
                                                              selectedGroup = group ;
                                                            });
                                                          } catch (e) {
                                                            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> unknownError (context)));
                                                            print(e);
                                                          }
                                                        },
                                                        itemBuilder: (GroupHeader value) => getDropDownMenuItem(value), focusedItemDecoration: _getDslDecoration(),
                                                      ),
                                                      padding: EdgeInsets.only(left: 12)
                                                  )
                                              ),
                                              Padding(
                                                padding: EdgeInsets.only(right: 8),
                                                child: _getDropdownIcon(),
                                              )
                                            ],
                                          )),
                                    ),
                                  ),
                                ],
                              );
                            }
                          }
                      ),
                      //----------------------------------------------------------------------------------------------------------
                      SizedBox(height: 20.0),
                      SizedBox(height: 15.0),
                      //------------------------------------------Where we should show the group's info------------------------------------------
                      //onGroupSelected(),
                      //-------------------------------------------------------------------------------------------------------------------------
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  //Function to check whether there's a selected group or not
  /*Widget onGroupSelected () {
    if (selectedGroup == null)
      return Text ('Hello , select a group to start tracking');
    else
      return StreamBuilder <Group> (
        initialData: selectedGroup,
        stream: selectedGroup.snapShots.map((snapshot){
          selectedGroup.updateGroupe(snapshot.data);
          return selectedGroup ;
        }),
        builder: (buildContext,asyncSnapshot) {
          Group group = asyncSnapshot.data;
          return Container ();
        } ,
      );
  }*/

  //-------------------------------------Group selector ---------------------------------------------
  DirectSelectItem<GroupHeader> getDropDownMenuItem(GroupHeader value) {
    ImageProvider image;
    return DirectSelectItem<GroupHeader>(
        itemHeight: 45,
        value: value,
        itemBuilder: (context, value) {
          return Row(
            children: <Widget>[
              CircleAvatar(
                //backgroundImage: _storageService.groupsImage(value.photo, value.groupPhoto),
              ),
              Text(value.name,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                ),
              ),
            ],
          );
          /*return Text(value,
            style: TextStyle(
              color: Colors.black,
              fontSize: 15,
            ),
          );*/
        });
  }

  _getDslDecoration() {
    return BoxDecoration(
        border: BorderDirectional(
          bottom: BorderSide(width: 1, color: Colors.orangeAccent),
          top: BorderSide(width: 1, color: Colors.orangeAccent),
        ));
  }

  BoxDecoration _getShadowDecoration() {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      boxShadow: <BoxShadow>[
        new BoxShadow(
          color: Colors.black45.withOpacity(0.06),
          spreadRadius: 4,
          offset: new Offset(0.0, 0.0),
          blurRadius: 10.0,
        ),
      ],
    );
  }

  Icon _getDropdownIcon() {
    return Icon(
      Icons.unfold_more,
      color: Colors.orangeAccent,
    );
  }
}