import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../database/databaseReferences.dart' as databaseReference;
import '../pages/UserProfilePage.dart';

class PostBody extends StatefulWidget {
  final DocumentSnapshot snapshot;

  PostBody(this.snapshot);

  @override
  PostBodyState createState() => PostBodyState();
}

class PostBodyState extends State<PostBody> {
  double containerHeight;
  bool showFull = false;
  FirebaseUser currentUser;
  IconData upIcon = EvaIcons.arrowCircleUpOutline;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) => currentUser = user);
  }

  Widget build(BuildContext context) {
    containerHeight =
        showFull ? double.infinity : MediaQuery.of(context).size.width - 80;
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            child: Container(
              margin: EdgeInsets.only(bottom: 15.0),
              constraints: BoxConstraints(
                maxHeight: containerHeight,
              ),
              child: Text(
                widget.snapshot.data['writeup'],
                style: TextStyle(
                    color: Colors.white,
                    letterSpacing: 0.2,
                    height: 1.1,
                    fontSize: 20),
                textAlign: TextAlign.left,
                softWrap: true,
                overflow: TextOverflow.fade,
              ),
            ),
            onTap: () {
              print("tap");
              setState(() {
                showFull = !showFull;
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Container(
                    child: GestureDetector(
                      child: Text(
                        widget.snapshot.data['name'],
                        style: TextStyle(
                          color: Colors.teal,
                          letterSpacing: 0.5,
                          fontSize: 12.0,
                          height: 1.0,
                        ),
                      ),
                      onTap: () {
                        openUserProfile();
                      },
                    ),
                  ),
                  Text(
                    " | ",
                    style: TextStyle(color: Colors.teal),
                  ),
                  Container(
                    child: Text(
                      DateFormat.yMMMd()
                          .format(widget.snapshot.data['createdAt'].toDate())
                          .toString(),
                      style: TextStyle(
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                        letterSpacing: 0.5,
                        fontSize: 12.0,
                        height: 1.0,
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      child: getUpIcon(widget.snapshot.documentID),
                      onTap: () => {
                            upVote(widget.snapshot.documentID),
                            updateUpvotedUserList(widget.snapshot.documentID),
                          },
                    ),
                    SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                      child: Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 18,
                      ),
                      onTap: () => showModalBottomSheet<void>(
                          context: context,
                          builder: (BuildContext context) {
                            return new Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                new ListTile(
                                  leading: new Icon(Icons.warning),
                                  title: new Text('Report'),
                                  onTap: () => print(""),
                                ),
                                new ListTile(
                                  leading: new Icon(Icons.share),
                                  title: new Text('Share'),
                                  onTap: () => print(""),
                                ),
                              ],
                            );
                          }),
                    )
                  ],
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  FutureBuilder getUpIcon(String documentID) {
    List userIds;
    return new FutureBuilder(
      future: getUpvotedUserList(documentID),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data['upvotedUsers'] != null) {
            userIds = snapshot.data['upvotedUsers'];
            if (userIds.contains(currentUser.uid))
              upIcon = EvaIcons.arrowCircleUp;
            else
              upIcon = EvaIcons.arrowCircleUpOutline;
          }
        }
        return Icon(
          upIcon,
          color: Colors.white,
          size: 18,
        );
      },
      initialData: Icon(
        EvaIcons.arrowCircleUpOutline,
        color: Colors.white,
        size: 18,
      ),
    );
  }

  Future<DocumentSnapshot> getUpvotedUserList(String documentID) {
    return databaseReference.DatabaseReferences()
        .postDatabaseReference
        .document(documentID)
        .get();
  }

  void upVote(String documentID) async {
    DocumentSnapshot snapshot = await getUpvotedUserList(documentID);
    List userIds = snapshot.data["upvotedUsers"];
    if (userIds.contains(currentUser.uid)) {
      databaseReference.DatabaseReferences()
          .postDatabaseReference
          .document(documentID)
          .updateData({
        "upvotes": FieldValue.increment(-1),
      });
    } else {
      databaseReference.DatabaseReferences()
          .postDatabaseReference
          .document(documentID)
          .updateData({
        "upvotes": FieldValue.increment(1),
      });
    }
  }

  void updateUpvotedUserList(String documentID) async {
    DocumentSnapshot snapshot = await getUpvotedUserList(documentID);
    List userIds = snapshot.data["upvotedUsers"];
    if (userIds.contains(currentUser.uid)) {
      databaseReference.DatabaseReferences()
          .postDatabaseReference
          .document(documentID)
          .updateData({
        "upvotedUsers": FieldValue.arrayRemove([currentUser.uid]),
      });
    } else {
      databaseReference.DatabaseReferences()
          .postDatabaseReference
          .document(documentID)
          .updateData({
        "upvotedUsers": FieldValue.arrayUnion([currentUser.uid]),
      });
    }
  }

  void openUserProfile() {
    String uid = widget.snapshot.data["uid"];
    databaseReference.DatabaseReferences()
        .userDatabaseReference
        .where("uid", isEqualTo: uid)
        .getDocuments()
        .then((query) => {
              print("Data" + query.documents[0].documentID),
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserProfilePage(query.documents[0].documentID),
                ),
              ),
            });
  }
}
