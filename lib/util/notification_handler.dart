import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/util/state_widget.dart';
import 'package:voluntario/models/state.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:convert';
import 'dart:io';

class NotificationHandler {
  BuildContext context;
  Firestore _db = Firestore.instance;
  final FirebaseMessaging firebaseMessaging = FirebaseMessaging();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String userId;
  StateModel appState;
  String occupation;
  PanelController panel;
  TabController tabController;
  GlobalKey<ScaffoldState> homePageScaffoldKey;

  NotificationHandler({
    this.context,
    this.userId,
    this.panel,
    this.tabController,
    this.homePageScaffoldKey,
  });

  setupNotifications() {
    appState = StateWidget.of(context).state;
    registerNotification();
    configLocalNotification();
  }

  dispose() {
    firebaseMessaging.deleteInstanceID();
    flutterLocalNotificationsPlugin.cancelAll();
  }

  void showNotification(message) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      Platform.isAndroid
          ? 'com.dfa.flutterchatdemo'
          : 'com.duytq.flutterchatdemo',
      'Flutter chat demo',
      'your channel description',
      playSound: true,
      enableVibration: true,
      importance: Importance.Max,
      priority: Priority.High,
    );

    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
        0,
        message['notification']['title'].toString(),
        message['notification']['body'].toString(),
        platformChannelSpecifics,
        payload: json.encode(message));
  }

  void hideLocalChatNotification(message) {}

  void registerNotification() async {
    firebaseMessaging.requestNotificationPermissions();

    firebaseMessaging.configure(onMessage: (Map<String, dynamic> notification) {
      print('onMessage: $notification');
      _localNotificationHandler(notification);
      return;
    }, onResume: (Map<String, dynamic> notification) {
      print('onResume: $notification');
      _notificationHandler(notification);
      return;
    }, onLaunch: (Map<String, dynamic> notification) {
      print('onLaunch: $notification');
      _notificationHandler(notification);
      return;
    });

    firebaseMessaging.getToken().then((token) {
      print('token: $token');
      _db
          .collection('pickers')
          .document(userId)
          .updateData({'pushToken': token});
    }).catchError((err) {
      Flushbar(
        message: err.message.toString(),
        duration: Duration(seconds: 3),
        isDismissible: false,
      )..show(context);
    });
  }

  Future onSelectNotification(String payload) async {
    if (appState.authUser != null) {
      if (payload != null) {
        Map notification = json.decode(payload);
        _notificationHandler(notification);
      }
    }
  }

  void configLocalNotification() {
    var initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
  }

  dismissNotificationDialog(Map<String, dynamic> notification) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            contentPadding: EdgeInsets.only(top: 12.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    child: Icon(Icons.cancel, color: Colors.black54, size: 64),
                    margin: EdgeInsets.only(bottom: 8.0),
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                    child: Text(
                      "SUA SOLICITAÇÃO FOI CANCELADA PELO USUÁRIO",
                      style: TextStyle(
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 20.0),
                    child: Text(
                      notification['data']['body'],
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                          },
                          child: Container(
                            padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).primaryColor.withAlpha(200),
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(4.0)),
                            ),
                            child: Icon(FontAwesomeIcons.checkCircle,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }

  _notificationHandler(Map<String, dynamic> notification) {
    if (appState.authUser != null) {
      String notificationType = notification['data']['type'];
      if (notificationType == 'message') {
        Map request = {
          'pickerId': notification['data']['pickerId'],
          'donorId': notification['data']['donorId'],
          'requestId': notification['data']['requestId']
        };

        bool isFromTheSameChat = false;
        Navigator.popUntil(context, (route) {
          if (route.settings.arguments == notification['data']['donorId']) {
            isFromTheSameChat = true;
            return true;
          } else if (route.settings.name == '/') return true;
          return false;
        });

        if (homePageScaffoldKey.currentState.isDrawerOpen)
          Navigator.pop(context);
        if (!isFromTheSameChat)
          Navigator.pushNamed(context, '/chat', arguments: request);
      } else if (notificationType == 'new') {
        Navigator.popUntil(context, (route) {
          if (route.settings.name == '/') {
            return true;
          }
          return false;
        });

        if (homePageScaffoldKey.currentState.isDrawerOpen)
          Navigator.pop(context);

        panel.open();
        tabController.animateTo(0);
      } else if (notificationType == 'dismiss') {
        dismissNotificationDialog(notification);
      }
    }
  }

  _localNotificationHandler(Map<String, dynamic> notification) {
    occupation = appState.user.occupation;
    String notificationType = notification['data']['type'];
    if (notificationType == 'message') {
      bool isFromTheSameChat = false;
      Navigator.popUntil(context, (route) {
        if (route.settings.arguments == notification['data']['donorId']) {
          isFromTheSameChat = true;
        }
        return true;
      });
      if (!isFromTheSameChat)
        showNotification(notification);
      else {
        _db
            .collection(occupation)
            .document(notification['data']['requestId'])
            .updateData({
          'pickerChatNotification': 0,
        });
      }
    } else if (notificationType == 'new') {
      showNotification(notification);
    } else if (notificationType == 'dismiss') {
      dismissNotificationDialog(notification);
    }
  }
}
