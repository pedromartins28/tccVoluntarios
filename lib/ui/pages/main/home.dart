import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:voluntario/ui/pages/request_list.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:voluntario/util/notification_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/ui/widgets/loading.dart';
import 'package:voluntario/util/state_widget.dart';
import 'package:voluntario/ui/pages/main/map.dart';
import 'package:voluntario/ui/pages/sign_in.dart';
import 'package:voluntario/models/state.dart';
import 'package:voluntario/models/user.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey<_HomePageState> homePageState = GlobalKey<_HomePageState>();

  final PanelController _panel = PanelController();
  bool _loadingVisibility = false, _isActive = false;
  NotificationHandler notificationHandler;
  String userId, name, email, photoUrl;
  TabController _tabController;
  SharedPreferences prefs;
  StateModel appState;
  User user;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  void initNotifications() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
    notificationHandler = NotificationHandler(
        tabController: _tabController,
        userId: user.userId,
        context: context,
        panel: _panel,
        homePageScaffoldKey: _scaffoldKey);
    await notificationHandler.setupNotifications();
    print("Configuração feita!");
  }

  Future readLocal() async {
    prefs = await SharedPreferences.getInstance();
    user = userFromJson(prefs.getString('user'));
  }

  _changeLoadingVisible() {
    setState(() {
      _loadingVisibility = !_loadingVisibility;
    });
  }

  Future<bool> _verifyConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {}
      return true;
    } on SocketException catch (_) {
      Flushbar(
        message: "Falha de Conexão",
        duration: Duration(seconds: 3),
        isDismissible: false,
      )..show(context);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    appState = StateWidget.of(context).state;
    if (!appState.isLoading &&
        (appState.authUser == null || appState.user == null)) {
      if (notificationHandler != null) {
        notificationHandler.dispose();
        notificationHandler = null;
      }
      return SignInPage();
    } else {
      if (appState.isLoading) {
        return Container();
      } else {
        readLocal();
        if (notificationHandler == null) initNotifications();
        email = appState.authUser.email;
        name = appState.user.name;
        userId = appState.user.userId;

        return Scaffold(
          key: _scaffoldKey,
          drawer: Drawer(
            child: ListView(
              children: <Widget>[
                DrawerHeader(
                  padding: EdgeInsets.symmetric(vertical: 0.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      StreamBuilder(
                        stream: Firestore.instance
                            .collection('pickers')
                            .where('userId', isEqualTo: userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            User user =
                                User.fromDocument(snapshot.data.documents[0]);
                            photoUrl = user.photoUrl;
                            return photoUrl != null
                                ? Padding(
                                    padding: EdgeInsets.only(
                                      bottom: 6.0,
                                      top: 8.0,
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                          '/user_information',
                                        );
                                      },
                                      child: Material(
                                        child: CachedNetworkImage(
                                          placeholder: (context, url) =>
                                              Container(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                Colors.grey,
                                              ),
                                              strokeWidth: 5.0,
                                            ),
                                            height: 84.0,
                                            width: 84.0,
                                          ),
                                          imageUrl: photoUrl,
                                          fit: BoxFit.cover,
                                          height: 84.0,
                                          width: 84.0,
                                        ),
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(42.0),
                                        ),
                                        clipBehavior: Clip.hardEdge,
                                      ),
                                    ),
                                  )
                                : GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).pushNamed(
                                        '/user_information',
                                      );
                                    },
                                    child: Icon(
                                      Icons.account_circle,
                                      size: 98.0,
                                      color: Colors.white,
                                    ),
                                  );
                          } else {
                            return GestureDetector(
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  '/user_information',
                                );
                              },
                              child: Icon(
                                Icons.account_circle,
                                size: 100.0,
                                color: Colors.white,
                              ),
                            );
                          }
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          name,
                          style: TextStyle(color: Colors.white, fontSize: 18),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 2.0),
                      Text(
                        email,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w300,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                ListTile(
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      '/user_information',
                    );
                  },
                  leading: Icon(
                    FontAwesomeIcons.userCircle,
                  ),
                  title: Text(
                    "PERFIL",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ),
                ListTile(
                  leading: Icon(
                    FontAwesomeIcons.questionCircle,
                    color: Colors.blue.withAlpha(200),
                  ),
                  title: Text(
                    "SOBRE",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed('/about');
                  },
                ),
                Divider(
                  indent: 6.0,
                  endIndent: 6.0,
                  color: Colors.grey,
                ),
                ListTile(
                  onTap: () async {
                    if (await _verifyConnection()) {
                      StateWidget.of(context).signOutUser();
                      Navigator.pop(context, true);
                    }
                  },
                  leading: Icon(
                    FontAwesomeIcons.timesCircle,
                    color: Colors.red.withAlpha(150),
                  ),
                  title: Text(
                    "SAIR",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w300),
                  ),
                ),
              ],
            ),
          ),
          body: LoadingPage(
            child: SlidingUpPanel(
              maxHeight: MediaQuery.of(context).size.height / 1.2,
              collapsed: _floatingCollapsed(),
              panel: _floatingPanel(),
              renderPanelSheet: false,
              controller: _panel,
              minHeight: 100,
              body: Container(
                child: MapPage(
                  userData: {'userId': userId, 'userName': name},
                  homeVisibility: _changeLoadingVisible,
                ),
              ),
            ),
            inAsyncCall: _loadingVisibility,
          ),
        );
      }
    }
  }

  Widget _floatingCollapsed() {
    return Container(
      margin: const EdgeInsets.fromLTRB(92.0, 8.0, 92.0, 36.0),
      child: RaisedButton.icon(
        label: Text(
          "SOLICITAÇÕES",
          style: TextStyle(
            fontSize: 18.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6.0),
        ),
        color: Theme.of(context).primaryColor,
        icon: Icon(FontAwesomeIcons.heart),
        onPressed: () => _panel.open(),
        textColor: Colors.white,
      ),
    );
  }

  Widget _floatingPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xfff8f8f8),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.grey,
          ),
        ],
      ),
      margin: const EdgeInsets.fromLTRB(0.0, 38.0, 0.0, 0.0),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.menu, size: 32.0),
                  onPressed: () {
                    _scaffoldKey.currentState.openDrawer();
                  },
                ),
                IconButton(
                  icon: Icon(Icons.history, size: 32.0),
                  onPressed: () {
                    Navigator.pushNamed(context, '/finished_requests');
                  },
                ),
              ],
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "SOLICITAÇÕES",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "CLIQUE EM UMA PARA VÊ-LA NO MAPA",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Expanded(
                        child: RequestList(
                          _panel,
                          1,
                          userId: userId,
                          userName: name,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        "SUAS COLETAS",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "CLIQUE EM UMA PARA VÊ-LA NO MAPA",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                      Expanded(
                          child: RequestList(
                        _panel,
                        2,
                        userId: userId,
                        userName: name,
                        homeVisibility: _changeLoadingVisible,
                      )),
                    ],
                  ),
                ],
              ),
            ),
            Stack(
              children: <Widget>[
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      border: Border.all(
                        color: Theme.of(context).primaryColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                TabBar(
                  controller: _tabController,
                  unselectedLabelColor: Colors.black54,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(2.0),
                      color: Theme.of(context).primaryColor),
                  tabs: [
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("DISPONÍVEIS"),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(vertical: 10.0),
                      child: Text("ACEITOS"),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              margin: EdgeInsets.only(top: 2.0),
              child: Card(
                elevation: 2.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Icon(Icons.notifications_active, size: 20.0),
                    Text(
                      "RECEBER NOTIFICAÇÕES",
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    StreamBuilder(
                      stream: Firestore.instance
                          .collection('pickers')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          _isActive = snapshot.data.documents[0]['isActive'];
                          return Switch(
                            value: _isActive,
                            activeTrackColor: Color(0xffC5E1A5),
                            activeColor: Theme.of(context).primaryColor,
                            onChanged: (value) {
                              snapshot.data.documents[0].reference.updateData(
                                {'isActive': _isActive ? false : true},
                              );
                            },
                          );
                        } else {
                          return Container();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
