import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import '../database/databaseReferences.dart' as databaseReference;
import '../pages/UserProfilePage.dart';
import '../animations/fadeInAnimation.dart';

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
  bool hasUpvotedPost = false;
  IconData upIcon = EvaIcons.arrowCircleUpOutline;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      if (widget.snapshot.data['upvotedUsers'] != null) {
        List userIds = widget.snapshot.data['upvotedUsers'];
        if (userIds.contains(user.uid))
          hasUpvotedPost = true;
        else
          hasUpvotedPost = false;
      }
      currentUser = user;
    });
  }

  Widget build(BuildContext context) {
    containerHeight =
        showFull ? double.infinity : MediaQuery.of(context).size.width - 80;
    return FadeIn(
      delay: 0,
      child: Container(
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
                    )
                  ],
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            child: getUpIcon(widget.snapshot.documentID),
                            onTap: () => {
                              upVote(widget.snapshot.documentID),
                            },
                          ),
                          Text(
                            widget.snapshot.data["upvotes"].toString(),
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 4,
                      ),
                      Column(
                        children: <Widget>[
                          GestureDetector(
                            child: Icon(
                              Icons.info,
                              color: Colors.white,
                              size: 24,
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
                          ),
                          Text(""),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getUpIcon(String documentID) {
    IconData upIcon;
    if (currentUser != null) {
      if (hasUpvotedPost)
        upIcon = EvaIcons.arrowCircleUp;
      else
        upIcon = EvaIcons.arrowCircleUpOutline;
      return Icon(
        upIcon,
        color: Colors.white,
        size: 24,
      );
    } else {
      return FutureBuilder(
        future: getUpvotedUserList(documentID),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data['upvotedUsers'] != null) {
              List userIds = snapshot.data['upvotedUsers'];
              if (userIds.contains(currentUser.uid))
                upIcon = EvaIcons.arrowCircleUp;
              else
                upIcon = EvaIcons.arrowCircleUpOutline;
            }
          }else{
            upIcon = EvaIcons.arrowCircleUpOutline;
          }
          return Icon(
            upIcon,
            color: Colors.white,
            size: 24,
          );
        },
      );
    }
  }

  Future<DocumentSnapshot> getUpvotedUserList(String documentID) {
    return databaseReference.DatabaseReferences()
        .posts
        .document(documentID)
        .get();
  }

  void upVote(String documentID) async {
    // DocumentSnapshot snapshot = await getUpvotedUserList(documentID);
    // List userIds = snapshot.data["upvotedUsers"];
    // if (userIds.contains(currentUser.uid)) {
    //   databaseReference.DatabaseReferences()
    //       .posts
    //       .document(documentID)
    //       .updateData({
    //     "upvotes": FieldValue.increment(-1),
    //   });
    // } else {
    //   databaseReference.DatabaseReferences()
    //       .posts
    //       .document(documentID)
    //       .updateData({
    //     "upvotes": FieldValue.increment(1),
    //   });
    // }
    DocumentReference postRef =
        databaseReference.DatabaseReferences().posts.document(documentID);
    if (hasUpvotedPost) {
      hasUpvotedPost = false;
      postRef.updateData({
        "upvotes": FieldValue.increment(-1),
        "upvotedUsers": FieldValue.arrayRemove([currentUser.uid]),
      }).then((value) {
        print('Downvoted Successfully.');
        return true;
      }).catchError((error) {
        print('Failed to Downvote: $error');
        return false;
      });
    } else {
      hasUpvotedPost = true;
      postRef.updateData({
        "upvotes": FieldValue.increment(1),
        "upvotedUsers": FieldValue.arrayUnion([currentUser.uid]),
      }).then((value) {
        print('Upvoted Successfully.');
        return true;
      }).catchError((error) {
        print('Failed to Upvote: $error');
        return false;
      });
    }
  }

  // void updateUpvotedUserList(String documentID) async {
  //   DocumentSnapshot snapshot = await getUpvotedUserList(documentID);
  //   List userIds = snapshot.data["upvotedUsers"];
  //   if (userIds.contains(currentUser.uid)) {
  //     databaseReference.DatabaseReferences()
  //         .posts
  //         .document(documentID)
  //         .updateData({
  //       "upvotedUsers": FieldValue.arrayRemove([currentUser.uid]),
  //     });
  //     updateLikeDB(documentID, false);
  //   } else {
  //     databaseReference.DatabaseReferences()
  //         .posts
  //         .document(documentID)
  //         .updateData({
  //       "upvotedUsers": FieldValue.arrayUnion([currentUser.uid]),
  //     });
  //     updateLikeDB(documentID, true);
  //   }
  // }

  void updateLikeDB(String documentID, bool status) {}

  void openUserProfile() {
    String uid = widget.snapshot.data["uid"];
    databaseReference.DatabaseReferences()
        .users
        .where("uid", isEqualTo: uid)
        .getDocuments()
        .then(
          (query) => {
            print("Data" + query.documents[0].documentID),
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    UserProfilePage(query.documents[0].documentID),
              ),
            ),
          },
        );
  }
}
