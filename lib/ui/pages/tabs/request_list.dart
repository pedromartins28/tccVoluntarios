import 'dart:io';

import 'package:flushbar/flushbar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:voluntario/ui/widgets/request_bottom_sheet.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:voluntario/util/map_state.dart';
import 'package:voluntario/models/user.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class RequestList extends StatefulWidget {
  final PanelController panelController;
  final String userId, userName;
  final listType;
  final Function homeVisibility;

  RequestList(this.panelController, this.listType,
      {this.userId, this.userName, this.homeVisibility});

  @override
  _StateRequestList createState() =>
      _StateRequestList(panelController, listType, userId, userName);
}

class _StateRequestList extends State<RequestList>
    with AutomaticKeepAliveClientMixin<RequestList> {
  final PanelController panelController;
  final _db = Firestore.instance;
  final String userId, userName;
  String quantity;
  final listType;

  _StateRequestList(
      this.panelController, this.listType, this.userId, this.userName);

  @override
  void initState() {
    super.initState();
  }

  @override
  bool get wantKeepAlive => true;

  SharedPreferences prefs;
  String photoUrl = '';
  User user;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (listType == 1) {
      return StreamBuilder(
        stream:
            _db.collection('requests').where("state", isEqualTo: 1).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            if (snapshot.data.documents.isEmpty)
              return Center(child: Text("SEM COLETAS AQUI!"));
            else
              return ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  bool isPickerDismissed = false;
                  if (snapshot.data.documents[index]['dismissedPickers'] !=
                      null) {
                    if (snapshot.data.documents[index]['dismissedPickers']
                        .contains(userId)) isPickerDismissed = true;
                  }
                  if (!isPickerDismissed)
                    return availableRequests(
                        context, snapshot.data.documents[index]);
                  return Container();
                },
              );
          }
        },
      );
    } else if (listType == 2) {
      return StreamBuilder(
        stream: _db
            .collection('requests')
            .where("state", isEqualTo: 2)
            .where("pickerId", isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            if (snapshot.data.documents.isEmpty)
              return Center(child: Text("SEM COLETAS AQUI!"));
            else
              return ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return pickerRequests(
                      context, snapshot.data.documents[index]);
                },
              );
          }
        },
      );
    } else {
      return StreamBuilder(
        stream: _db
            .collection('requests')
            .where("state", isEqualTo: 3)
            .where('pickerId', isEqualTo: userId)
            .orderBy('endTime')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 5.0,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              ),
            );
          } else {
            if (snapshot.data.documents.isEmpty)
              return Center(child: Text("SEM COLETAS AQUI!"));
            else
              return ListView.builder(
                reverse: true,
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return finishedRequests(
                      context, snapshot.data.documents[index]);
                },
              );
          }
        },
      );
    }
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
              SizedBox(width: 4),
              _buildDayField("S", document['periodDays'][1], mainColor),
              SizedBox(width: 4),
              _buildDayField("T", document['periodDays'][2], mainColor),
              SizedBox(width: 4),
              _buildDayField("Q", document['periodDays'][3], mainColor),
              SizedBox(width: 4),
              _buildDayField("Q", document['periodDays'][4], mainColor),
              SizedBox(width: 4),
              _buildDayField("S", document['periodDays'][5], mainColor),
              SizedBox(width: 4),
              _buildDayField("S", document['periodDays'][6], mainColor),
            ],
          ),
        ),
      ],
    );
  }

  Widget availableRequests(BuildContext context, DocumentSnapshot document) {
    final mapState = Provider.of<MapState>(context);
    return Card(
      elevation: 3,
      child: ListTile(
        onTap: () {
          if (panelController != null) {
            panelController.close();
            mapState.animateToPosition(
              LatLng(
                document['location'].latitude,
                document['location'].longitude,
              ),
              17,
            );
          }
        },
        isThreeLine: true,
        trailing: FlatButton(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Icon(FontAwesomeIcons.recycle,
                  color: Theme.of(context).primaryColor),
              Text("ACEITAR"),
            ],
          ),
          onPressed: () {
            if (panelController != null) {
              panelController.close();
              mapState.animateToPosition(
                LatLng(
                  document['location'].latitude - 0.0045,
                  document['location'].longitude,
                ),
                16,
              );
              confirmation(document, context, panelController, userId);
            }
          },
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
        subtitle: Container(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(Icons.delete_outline, size: 18),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "${document['trashAmount']} DE ${document['trashType']}",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Icon(Icons.my_location, color: Colors.grey, size: 18),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      document['address'],
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4),
              _buildDayFieldRow(document, Colors.grey),
              SizedBox(
                height: 4,
              ),
              Row(
                children: <Widget>[
                  Icon(Icons.access_time, color: Colors.grey, size: 18),
                  SizedBox(width: 6),
                  Flexible(
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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget pickerRequests(BuildContext context, DocumentSnapshot document) {
    final mapState = Provider.of<MapState>(context);
    int notifications = document['pickerChatNotification'];
    if (notifications != null && notifications != 0) {
      if (notifications > 9)
        quantity = "+9";
      else
        quantity = notifications.toString();
    } else {
      quantity = null;
    }
    return Stack(
      children: <Widget>[
        Card(
          elevation: 3,
          child: ListTile(
            onTap: () {
              if (panelController != null) {
                panelController.close();
                mapState.animateToPosition(
                  LatLng(
                    document['location'].latitude,
                    document['location'].longitude,
                  ),
                  17,
                );
              }
            },
            isThreeLine: true,
            trailing: FlatButton(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Icon(FontAwesomeIcons.ellipsisH, color: Colors.black54),
                  Text("OPÇÕES"),
                ],
              ),
              onPressed: () {
                showModalBottomSheet(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(15.0)),
                  ),
                  context: context,
                  builder: (context) {
                    return RequestBottomSheet(document, widget.homeVisibility);
                  },
                );
              },
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
            subtitle: Column(
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(Icons.my_location, size: 18),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        document['address'],
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(Icons.fitness_center, size: 18),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        "${document['trashAmount']} DE ${document['trashType']}",
                        style: TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                _buildDayFieldRow(document, Colors.black.withAlpha(190)),
                SizedBox(height: 4),
                Row(
                  children: <Widget>[
                    Icon(Icons.access_time, size: 18),
                    SizedBox(width: 6),
                    Flexible(
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
                        style: TextStyle(color: Colors.black),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        quantity != null
            ? Positioned(
                top: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  constraints: BoxConstraints(
                    minWidth: 20,
                    minHeight: 20,
                  ),
                  child: Center(
                    child: Text(
                      quantity,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              )
            : Container(),
      ],
    );
  }

  Widget finishedRequests(BuildContext context, DocumentSnapshot document) {
    String day, month, year;
    var date = DateTime.fromMillisecondsSinceEpoch(
      document['endTime'].seconds * 1000,
    );
    if (date.day < 10)
      day = "0${date.day}";
    else
      day = date.day.toString();
    if (date.month < 10)
      month = "0${date.month}";
    else
      month = date.month.toString();
    year = date.year.toString();
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        subtitle: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[Text("DATA:"), Text("SUA AVALIAÇÃO:")],
              ),
              SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Icon(Icons.access_time, color: Colors.black54, size: 20),
                      SizedBox(width: 6),
                      Text(
                        "$day/$month/$year",
                        style: TextStyle(color: Colors.black, fontSize: 18),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 4),
                    child: SmoothStarRating(
                      rating: document['pickerRating'].toDouble(),
                      borderColor: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              Text("RESÍDUO:"),
              SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Icon(Icons.delete_outline, color: Colors.black54, size: 20),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      "${document['trashAmount']} DE ${document['trashType']}",
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text("ENDEREÇO:"),
              SizedBox(height: 4),
              Row(
                children: <Widget>[
                  Icon(Icons.my_location, color: Colors.black54, size: 20),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      document['address'],
                      style: TextStyle(color: Colors.black, fontSize: 18),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> confirmation(DocumentSnapshot document, BuildContext context,
      PanelController controller, String userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(4.0)),
          ),
          contentPadding: EdgeInsets.only(top: 12.0),
          content: Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(bottom: 8.0),
                  child: Icon(
                    FontAwesomeIcons.questionCircle,
                    color: Colors.black54,
                    size: 64,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 0.0),
                  child: Text(
                    "ACEITAR PEDIDO?",
                    style: TextStyle(
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.fromLTRB(24.0, 8.0, 24.0, 20.0),
                  child: Text(
                    "TENHA CERTEZA QUE DESEJA REALIZAR A COLETA.",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                          controller.open();
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color: Colors.redAccent.withAlpha(200),
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(4.0)),
                          ),
                          child: Icon(
                            FontAwesomeIcons.timesCircle,
                            color: Colors.white,
                          ),
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
                                for (DocumentSnapshot ds
                                    in snapshot.documents) {
                                  ds.reference.delete();
                                }
                              });
                            }).catchError((error) {
                              Flushbar(
                                message: "Não foi possível aceitar a coleta",
                                duration: Duration(seconds: 3),
                              )..show(context);
                            });
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).primaryColor.withAlpha(200),
                            borderRadius: BorderRadius.only(
                              bottomRight: Radius.circular(4.0),
                            ),
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
          ),
        );
      },
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
      )..show(context);
      return false;
    }
  }
}
