import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../widgets/homeTab.dart';
import '../widgets/SearchTab.dart';
import '../widgets/blogTab.dart';
import '../widgets/userProfileTab.dart';
import '../widgets/writeTab.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = new PageController();
  }

  @override
  void dispose() {
    super.dispose();
    _pageController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      bottomNavigationBar: bottomNavigator(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        child: Icon(
          FontAwesomeIcons.penNib,
          size: 20,
        ),
        backgroundColor: Theme.of(context).accentColor,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WriteTab(),
          ),
        ),
      ),
      body: PageView(
        onPageChanged: onPageChanged,
        controller: _pageController,
        children: <Widget>[
          HomeTab(),
          SearchTab(),
          BlogTab(),
          UserProfileTab(),
        ],
      ),
    );
  }

  Widget bottomNavigator() {
    return BottomNavigationBar(
      selectedItemColor: Theme.of(context).accentColor,
      backgroundColor: Theme.of(context).backgroundColor,
      unselectedItemColor: Theme.of(context).accentColor,
      iconSize: 20,
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          title: Text("Home"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          title: Text("Discover"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat),
          title: Text("Blog"),
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          title: Text("Profile"),
        ),
      ],
      currentIndex: _selectedIndex,
      type: BottomNavigationBarType.fixed,
      onTap: itemTapped,
    );
  }

  void itemTapped(int index) {
    _pageController.jumpToPage(index);
  }

  void onPageChanged(int value) {
    setState(() {
      this._selectedIndex = value;
    });
  }
}
