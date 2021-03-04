import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:voluntario/ui/widgets/finish_request_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:android_intent/android_intent.dart';
import 'package:voluntario/ui/widgets/dot_loader.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class RequestBottomSheet extends StatefulWidget {
  final DocumentSnapshot document;
  Function homeVisibility;

  RequestBottomSheet(this.document, this.homeVisibility);

  @override
  _RequestBottomSheetState createState() =>
      _RequestBottomSheetState(document, this.homeVisibility);
}

class _RequestBottomSheetState extends State<RequestBottomSheet> {
  Firestore _db = Firestore.instance;
  final DocumentSnapshot document;
  Function _homeVisibility;
  String donorName;
  bool _visible = false;
  Widget icon;

  _RequestBottomSheetState(this.document, this._homeVisibility);

  Future<String> _getUserLocation() async {
    var position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
    String initialPosition =
        position.latitude.toString() + "," + position.longitude.toString();
    return initialPosition;
  }

  @override
  void initState() {
    _db.collection('donors').document(document['donorId']).get().then((doc) {
      setState(() {
        donorName = doc['name'];
      });
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          _visible = true;
        });
      });
    });
    //print("notification: " + widget.notificationHandler.toString());
    super.initState();
  }

  void openChat(BuildContext context) {
    Map request = {
      'pickerId': document['pickerId'],
      'donorId': document['donorId'],
      'requestId': document.documentID,
    };

    Navigator.of(context).pushNamed('/chat', arguments: request);
  }

  void openForm(BuildContext context) {
    Map request = {
      'pickerId': document['pickerId'],
      'donorId': document['donorId'],
      'requestId': document.documentID,
    };

    Navigator.of(context).pushNamed('/form', arguments: request);
  }

  @override
  Widget build(BuildContext context) {
    int notifications = document['pickerChatNotification'];
    if (notifications != null && notifications != 0)
      icon = Icon(FontAwesomeIcons.commentDots, color: Colors.orangeAccent);
    else
      icon = Icon(FontAwesomeIcons.comment);
    return Container(
      child: Wrap(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(top: 12.0),
            child: Center(
                child: Column(
              children: <Widget>[
                donorName == null
                    ? FadingText('- - - - -',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900))
                    : AnimatedOpacity(
                        child: Text(
                          donorName,
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        opacity: _visible ? 1.0 : 0.0,
                        duration: Duration(milliseconds: 750),
                      ),
                FadingText(
                  '. . .',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
              ],
            )),
          ),
          Container(
            height: 0.5,
            margin: EdgeInsets.only(top: 8),
            width: double.infinity,
            color: Colors.grey,
          ),
          ListTile(
            leading: Container(
              width: 16,
              child: Icon(
                Icons.format_align_justify,
                color: Theme.of(context).primaryColor,
              ),
            ),
            title: Text('FORMULÁRIO'),
            onTap: () async {
              Navigator.of(context).pop();
              openForm(context);
            },
          ),
          ListTile(
            leading: Container(
              width: 16,
              child: icon,
            ),
            title: Text('CHAT'),
            onTap: () async {
              Navigator.of(context).pop();
              openChat(context);
            },
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.arrowAltCircleUp,
              color: Colors.blue,
            ),
            title: Text('ROTA'),
            onTap: () async {
              if (await _verifyConnection(context)) {
                _homeVisibility();
                Navigator.pop(context);

                String origin = await _getUserLocation();
                print(origin);
                String destination = document['location'].latitude.toString() +
                    "," +
                    document['location'].longitude.toString();
                print(destination);

                if (Platform.isAndroid) {
                  final AndroidIntent intent = AndroidIntent(
                      action: 'action_view',
                      data: Uri.encodeFull(
                          "https://www.google.com/maps/dir/?api=1&origin=" +
                              origin +
                              "&destination=" +
                              destination +
                              "&travelmode=driving&dir_action=navigate"),
                      package: 'com.google.android.apps.maps');
                  _homeVisibility();
                  intent.launch();
                } else {
                  /* Implementar direcionamento para IOS
                  String url = "https://www.google.com/maps/dir/?api=1&origin=" +
                      origin +
                      "&destination=" +
                      destination +
                      "&travelmode=driving&dir_action=navigate";
                  if (await canLaunch(url)) {
                    await launch(url);
                  } else {
                    throw 'Could not launch $url';
                  }*/
                }
              }
            },
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.checkSquare,
              color: Theme.of(context).primaryColor,
            ),
            title: Text('FINALIZAR'),
            onTap: () async {
              Navigator.of(context).pop();
              _finishRequestDialog(document, context);
            },
          ),
          ListTile(
            leading: Icon(
              FontAwesomeIcons.timesCircle,
              color: Colors.redAccent,
            ),
            title: Text('DISPENSAR'),
            onTap: () async {
              if (_verifyIfRequestCanBeDismissed(
                document['periodDays'],
                document['periodStart'].toDate(),
                document['periodEnd'].toDate(),
                context,
              )) {
                Navigator.of(context).pop();
                _dismissRequestDialog(document, context);
              }
            },
          ),
        ],
      ),
    );
  }

  _dismissRequestDialog(DocumentSnapshot document, BuildContext context) async {
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
                  child: Icon(Icons.delete_forever,
                      color: Colors.black54, size: 64),
                  margin: EdgeInsets.only(bottom: 6.0),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                  child: Text(
                    "DISPENSAR COLETA?",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(32.0, 4.0, 32.0, 20.0),
                  child: Text(
                    "AVISE O DOADOR ANTES DE DISPENSA-LO!",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                ),
                //nao
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withAlpha(200),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4.0)),
                          ),
                          child: Icon(FontAwesomeIcons.timesCircle,
                              color: Colors.white),
                        ),
                      ),
                    ),
                    //chat
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (await _verifyConnection(context)) {
                            Navigator.of(context).pop();
                            openChat(context);
                          } else {
                            Navigator.of(context).popUntil((route) {
                              if (route.settings.name == '/')
                                return true;
                              else
                                return false;
                            });
                            Flushbar(
                              message: "Falha de Conexão",
                              duration: Duration(seconds: 3),
                              isDismissible: false,
                            )..show(context);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent.withAlpha(200),
                          ),
                          child: Icon(Icons.chat, color: Colors.white),
                        ),
                      ),
                    ),
                    //sim
                    Expanded(
                      child: InkWell(
                        onTap: () async {
                          if (await _verifyConnection(context)) {
                            var dismissedPickers = document['dismissedPickers'];
                            if (dismissedPickers == null)
                              dismissedPickers = [document['pickerId']];
                            else {
                              dismissedPickers =
                                  document['dismissedPickers'].toList();
                              dismissedPickers.add(document['pickerId']);
                            }

                            Navigator.of(context).pop();
                            await document.reference.updateData({
                              'pickerId': null,
                              'state': 1,
                              'dismissedByDonor': false,
                              'dismissedPickers': dismissedPickers,
                              'pickerChatNotification': 0
                            }).then((onValue) {
                              document.reference
                                  .collection('messages')
                                  .getDocuments()
                                  .then((snapshot) {
                                for (DocumentSnapshot ds
                                    in snapshot.documents) {
                                  ds.reference.delete();
                                }
                              });
                              _db
                                  .collection('donors')
                                  .document(document['donorId'])
                                  .updateData({
                                'requestNotification': true,
                                'chatNotification': 0,
                              });
                            }).catchError((error) {
                              Flushbar(
                                message: "Não foi possível dispensar a coleta",
                                duration: Duration(seconds: 3),
                                isDismissible: false,
                              )..show(context);
                            });
                          } else {
                            Navigator.of(context).popUntil((route) {
                              if (route.settings.name == '/')
                                return true;
                              else
                                return false;
                            });
                            Flushbar(
                              message: "Falha de Conexão",
                              duration: Duration(seconds: 3),
                              isDismissible: false,
                            )..show(context);
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.green[300],
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
          ),
        );
      },
    );
  }

  _finishRequestDialog(DocumentSnapshot document, BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(4.0))),
            contentPadding: EdgeInsets.only(top: 12.0),
            content: FinishRequestDialog(document, context));
      },
    );
  }

  _verifyIfRequestCanBeDismissed(var weekDays, DateTime periodStart,
      DateTime periodEnd, BuildContext context) {
    DateTime now = DateTime.now();
    DateTime periodStartMinus1 = DateTime(now.year, now.month, now.day,
        periodStart.hour - 1, periodStart.minute, 0, 0, 0);
    DateTime realperiodEnd = DateTime(now.year, now.month, now.day,
        periodEnd.hour, periodEnd.minute, 0, 0, 0);

    int currentWeekDay = now.weekday;
    if (currentWeekDay == 7) currentWeekDay = 0;

    if (weekDays[currentWeekDay]) {
      if ((now.isBefore(periodStartMinus1) || now.isAfter(realperiodEnd)))
        return true;
      else {
        Flushbar(
          message:
              "Só é possível dispensar uma coleta com uma hora de antecedência ou após o Horário de Coleta.",
          duration: Duration(seconds: 4),
          isDismissible: false,
        )..show(context);
        return false;
      }
    } else
      return true;
  }

  Future<bool> _verifyConnection(BuildContext context) async {
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
}
