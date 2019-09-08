import 'package:flutter/material.dart';
import '../functions/login_functions.dart' as loginFunctions;
import 'package:firebase_auth/firebase_auth.dart';
import '../database/databaseReferences.dart' as databaseReference;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:strings/strings.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

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
          color: Colors.black,
        ),
        child: StreamBuilder<QuerySnapshot>(
            stream: databaseReference.DatabaseReferences()
                .users
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
                return SafeArea(
                  child: Scaffold(
                    body: Center(
                      child: Column(
                        children: <Widget>[
                          userDetail(context, snapshot),
                          userBio(),
                          socialIcons(),
                          flowWidget(),
                          editProfileButton(),
                          logoutButton(),
                        ],
                      ),
                    ),
                  ),
                );
              }
            }),
      );
    }
  }

  Container socialIcons() {
    return Container(
      margin: EdgeInsets.only(bottom: 20.0),
      width: 150,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          IconButton(
            icon: Icon(FontAwesomeIcons.facebookF),
            color: Colors
                .blueAccent, //TODO Gray icon if user is not connected to Facebook
            onPressed: () {
              //TODO Connection/Disconnection button for Facebook
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.twitter),
            color: Colors
                .lightBlue, //TODO Gray icon if user is not connected to Twitter
            onPressed: () {
              //TODO Connection/Disconnection for Twitter
            },
          ),
          IconButton(
            icon: Icon(FontAwesomeIcons.instagram),
            color: Colors
                .red, //TODO Gray icon if user is not connected to Instagram
            onPressed: () {
              //TODO Connection/Disconnection for Instagram
            },
          ),
        ],
      ),
    );
  }

  Container userDetail(BuildContext context, DocumentSnapshot snapshot) {
    return Container(
      width: MediaQuery.of(context).size.width,
      padding: EdgeInsets.only(top: 80, bottom: 20),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: CircleAvatar(
              radius: 50,
              backgroundImage: NetworkImage(
                snapshot["profilePictureUrl"],
              ),
            ),
            onTap: () {
              //TODO Clicking will allow user to change their display picture
            },
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            child: Text(
              camelize(snapshot["name"]),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(0, 0, 0, 0.8),
                letterSpacing: 1,
              ),
            ),
          ),
          /*Loaction*/
          Container(
            child: Text(
              //TODO User location should come from user profile
              'Oran, Algeria',
              style: TextStyle(
                  fontSize: 18,
                  color: Color.fromRGBO(0, 0, 0, 0.6),
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Container userBio() {
    return Container(
        margin: EdgeInsets.only(top: 20.0, bottom: 20.0),
        width: 300,
        child: Center(
          child: Text(
            //TODO User bio should be fetched from user profile
            'I am a Computer Science Student and a Flutter Developer',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18,
                color: Color.fromRGBO(0, 0, 0, 0.8),
                fontWeight: FontWeight.bold),
          ),
        ));
  }

  Container editProfileButton() {
    return Container(
      width: 200,
      margin: EdgeInsets.only(
        top: 3,
        bottom: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(0, 168, 107, 1),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: FlatButton(
        child: Text(
          "Edit Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onPressed: () => {
          //TODO Clicking on this button will open edit profile page
        },
      ),
    );
  }

  Container logoutButton() {
    return Container(
      width: 200,
      margin: EdgeInsets.only(
        top: 3,
        bottom: 3,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Color.fromRGBO(234, 60, 83, 1),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
      ),
      child: FlatButton(
        child: Text(
          "Logout",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        onPressed: () => loginFunctions.LoginFunctions().logout(),
      ),
    );
  }

  Container flowWidget() {
    var textStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: Color.fromRGBO(0, 0, 0, 0.8),
    );
    var iconsColor = Color.fromRGBO(0, 0, 0, 0.7);
    return Container(
      height: 100,
      margin: EdgeInsets.only(top: 20.0, bottom: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width / 2.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        //TODO Fetch number of followers from user profile
                        '12 Followers',
                        style: textStyle,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        FontAwesomeIcons.userTie,
                        color: iconsColor,
                      ),
                    ],
                  ),
                  onTap: () {
                    //TODO: Opens a list of all followers
                  },
                ),
                GestureDetector(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        //TODO Fetch number of blogs from user profile
                        '12 Blogs',
                        style: textStyle,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Icon(
                        FontAwesomeIcons.solidStickyNote,
                        color: iconsColor,
                      ),
                    ],
                  ),
                  onTap: () {
                    //TODO: Opens a list of all blogs by user
                  },
                )
              ],
            ),
          ),
          Container(
            height: 80,
            child: VerticalDivider(
              width: 3.0,
              color: Colors.black87,
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width / 2.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.userNinja,
                        color: iconsColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        //TODO Fetch number of followings from user profile
                        '125 Following',
                        style: textStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    //TODO: Opens a list of users followerd by current user
                  },
                ),
                GestureDetector(
                  child: Row(
                    children: <Widget>[
                      Icon(
                        FontAwesomeIcons.penNib,
                        color: iconsColor,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        //TODO Fetch number of posts from user profile
                        '10 Posts',
                        style: textStyle,
                      ),
                    ],
                  ),
                  onTap: () {
                    //TODO: Opens a list of all posts by user
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
