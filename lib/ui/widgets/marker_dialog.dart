import 'dart:io';
import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MarkerDialog extends StatefulWidget {
  final DocumentSnapshot document;
  final BuildContext context;
  final String userId;

  MarkerDialog(this.document, this.context, this.userId);

  @override
  _MarkerDialogState createState() =>
      _MarkerDialogState(document, context, userId);
}

class _MarkerDialogState extends State<MarkerDialog> {
  Firestore _db = Firestore.instance;
  final DocumentSnapshot document;
  final BuildContext context;
  bool _visible = false;
  final String userId;

  _MarkerDialogState(this.document, this.context, this.userId);

  @override
  void initState() {
    _db.collection('donors').document(document['donorId']).get().then((doc) {
      setState(() {});
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          _visible = true;
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              decoration: BoxDecoration(
                border: Border.all(width: 0.4, color: Colors.grey),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.0),
                  topRight: Radius.circular(4.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(FontAwesomeIcons.mapMarkerAlt,
                      color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document['address'],
                      style: TextStyle(fontSize: 17),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              decoration: BoxDecoration(
                border: Border.all(width: 0.4, color: Colors.grey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(FontAwesomeIcons.paperclip,
                      color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${document['trashAmount']}",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
              decoration: BoxDecoration(
                border: Border.all(width: 0.4, color: Colors.grey),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(FontAwesomeIcons.newspaper,
                      color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "${document['trashType']}",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),
            Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
                decoration: BoxDecoration(
                  border: Border.all(width: 0.4, color: Colors.grey),
                ),
                child: _buildDayFieldRow(document, Colors.grey)),
            Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
              decoration: BoxDecoration(
                border: Border.all(width: 0.4, color: Colors.grey),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(4.0),
                  bottomRight: Radius.circular(4.0),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(FontAwesomeIcons.clock, color: Colors.grey, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      document['periodStart']
                              .toDate()
                              .toString()
                              .substring(11, 16) +
                          " até " +
                          document['periodEnd']
                              .toDate()
                              .toString()
                              .substring(11, 16),
                      style: TextStyle(fontSize: 18),
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
            ),
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
                        borderRadius:
                            BorderRadius.only(bottomLeft: Radius.circular(4.0)),
                      ),
                      child: Icon(FontAwesomeIcons.timesCircle,
                          color: Colors.white),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      if (await _verifyConnection(context)) {
                        Navigator.of(context).pop();

                        document.reference.updateData({
                          'state': 2,
                          'pickerId': userId,
                        }).then((onValue) {
                          _db
                              .collection('donors')
                              .document(document['donorId'])
                              .updateData({'requestNotification': true});

                          document.reference
                              .collection('messages')
                              .getDocuments()
                              .then((snapshot) {
                            for (DocumentSnapshot ds in snapshot.documents) {
                              ds.reference.delete();
                            }
                          });
                        }).catchError((error) {
                          Flushbar(
                            message: "Não foi possível aceitar a coleta",
                            duration: Duration(seconds: 3),
                            isDismissible: false,
                          )..show(context);
                        });
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
  }

  Widget _buildDayField(String text, bool day, Color mainColor) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: mainColor),
          color: day ? mainColor : Colors.white),
      child: Text(
        text,
        style: TextStyle(fontSize: 8, color: day ? Colors.white : mainColor),
      ),
    );
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

  Widget _buildDayFieldRow(DocumentSnapshot document, Color mainColor) {
    return Row(
      children: <Widget>[
        Icon(Icons.date_range, color: mainColor, size: 18),
        SizedBox(width: 6),
        Flexible(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _buildDayField("D", document['periodDays'][0], mainColor),
              SizedBox(
                width: 4,
              ),
              _buildDayField("S", document['periodDays'][1], mainColor),
              SizedBox(
                width: 4,
              ),
              _buildDayField("T", document['periodDays'][2], mainColor),
              SizedBox(
                width: 4,
              ),
              _buildDayField("Q", document['periodDays'][3], mainColor),
              SizedBox(
                width: 4,
              ),
              _buildDayField("Q", document['periodDays'][4], mainColor),
              SizedBox(
                width: 4,
              ),
              _buildDayField("S", document['periodDays'][5], mainColor),
              SizedBox(
                width: 4,
              ),
              _buildDayField("S", document['periodDays'][6], mainColor),
            ],
          ),
        ),
      ],
    );
  }
}
