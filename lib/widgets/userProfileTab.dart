import 'package:flutter/material.dart';
import '../functions/login_functions.dart' as loginFunctions;
import 'package:firebase_auth/firebase_auth.dart';
import '../database/databaseReferences.dart' as databaseReference;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strings/strings.dart';
import '../pages/tutorial_page.dart';

class UserProfileTab extends StatefulWidget {
  UserProfileTab();

  UserProfileTabState createState() => UserProfileTabState();
}

class UserProfileTabState extends State<UserProfileTab> {
  FirebaseUser currentUser;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    FirebaseUser user = await FirebaseAuth.instance.currentUser();
    setState(() {
      currentUser = user;
    });
  }

  double rowHeight = 45;

  Widget build(BuildContext context) {
    if (currentUser == null) {
      return new Container(
        width: MediaQuery.of(context).size.width,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ),
        child: StreamBuilder<QuerySnapshot>(
            stream: databaseReference.DatabaseReferences()
                .userDatabaseReference
                .where("uid", isEqualTo: currentUser.uid)
                .limit(1)
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> query) {
              if (query.connectionState == ConnectionState.waiting) {
                return new Container(
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              } else {
                DocumentSnapshot snapshot = query.data.documents[0];
                return new ListView(
                  children: <Widget>[
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        border: Border.all(color: Colors.black),
                        color: Colors.red,
                        image: new DecorationImage(
                          image:
                              new NetworkImage(snapshot["profilePictureUrl"]),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20),
                      child: Column(
                        children: <Widget>[
                          Container(
                            height: 30,
                            child: Center(
                              child: Text(
                                camelize(snapshot["name"]),
                                style: TextStyle(
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 10.0),
                      height: rowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "username",
                          ),
                          Text(
                            "Change",
                            style: TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: rowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "posts",
                          ),
                          Text(
                            snapshot["posts"] == null
                                ? "0"
                                : snapshot["posts"].toString(),
                            style: TextStyle(),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: rowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "followers",
                          ),
                          Text(
                            snapshot["followers"] == null
                                ? "0"
                                : snapshot["followers"].toString(),
                            style: TextStyle(),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: rowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "followings",
                          ),
                          Text(
                            snapshot["followings"] == null
                                ? "0"
                                : snapshot["followings"].toString(),
                            style: TextStyle(),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: rowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Email",
                          ),
                          Text(
                            snapshot["email"],
                            style: TextStyle(),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: rowHeight,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(
                            "Location",
                          ),
                          Text(
                            "Delhi",
                            style: TextStyle(),
                            textAlign: TextAlign.right,
                          ),
                        ],
                      ),
                    ),
                    RaisedButton(
                      child: Text("Logout"),
                      onPressed: () => loginFunctions.LoginFunctions()
                          .logout()
                          .then((_) => Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TutorialPage()),
                                (Route<dynamic> route) => false,
                              )),
                    ),
                  ],
                );
              }
            }),
      );
    }
  }

  Widget logoutButton() {
    return RaisedButton(
      child: Text("Logout"),
      onPressed: () => loginFunctions.LoginFunctions().logout(),
    );
  }
}
