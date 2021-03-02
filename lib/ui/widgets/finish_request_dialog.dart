import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class FinishRequestDialog extends StatefulWidget {
  final DocumentSnapshot document;
  final BuildContext context;

  FinishRequestDialog(this.document, this.context);

  @override
  _FinishRequestDialogState createState() =>
      _FinishRequestDialogState(document, context);
}

class _FinishRequestDialogState extends State<FinishRequestDialog> {
  final DocumentSnapshot document;
  final BuildContext context;
  Firestore _db = Firestore.instance;

  _FinishRequestDialogState(this.document, this.context);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            child: Icon(FontAwesomeIcons.checkCircle,
                color: Colors.black54, size: 64),
            margin: EdgeInsets.only(bottom: 16.0),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 0.0),
            child: Text(
              "COLETA FINALIZADA?",
              style: TextStyle(
                fontSize: 18,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 12,
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
                    child:
                        Icon(FontAwesomeIcons.timesCircle, color: Colors.white),
                  ),
                ),
              ),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    if (await _verifyConnection()) {
                      Navigator.of(context).pop();

                      await document.reference.updateData({
                        'state': 3,
                        'endTime': Timestamp.fromDate(DateTime.now()),
                        'notification': null
                      }).then((onValue) {
                        _db
                            .collection('donors')
                            .document(document['donorId'])
                            .get()
                            .then((DocumentSnapshot donor) async {
                          print(donor.data.toString());
                          await donor.reference.updateData({
                            'finishedRequests': FieldValue.increment(1),
                            'chatNotification': 0,
                            'requestNotification': null,
                            'finishedRequestNotification': true
                          });
                        });

                        document.reference
                            .collection('messages')
                            .getDocuments()
                            .then((snapshot) {
                          for (DocumentSnapshot ds in snapshot.documents) {
                            ds.reference.delete();
                          }
                        });
                      }).catchError((onError) {
                        Flushbar(
                          message: "Não foi possível finalizar a coleta",
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
                      color: Theme.of(context).primaryColor.withAlpha(200),
                      borderRadius:
                          BorderRadius.only(bottomRight: Radius.circular(4.0)),
                    ),
                    child: Icon(
                      FontAwesomeIcons.checkCircle,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
}
